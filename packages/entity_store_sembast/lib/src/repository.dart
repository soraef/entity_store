import 'package:entity_store/entity_store.dart';
import 'package:entity_store_sembast/src/query.dart';
import 'package:sembast/sembast.dart';
import 'storage_repository.dart'; // Entity, RepositoryFilter, RepositorySort などの定義済みとする

/// Sembast 用に直接 Sembast の API を利用する Repository 実装
abstract class SembastRepository<Id, E extends Entity<Id>>
    with EntityChangeNotifier<Id, E>
    implements Repository<Id, E>, EntityStoreRepository<Id, E> {
  @override
  final EntityStoreController controller;

  final Database db;

  SembastRepository({required this.controller, required this.db});

  String get storeName;

  StoreRef<String, Map<String, Object?>> get store =>
      stringMapStoreFactory.store(storeName);

  @override
  Map<String, dynamic> toJson(E entity);

  @override
  E fromJson(Map<String, dynamic> json);

  @override
  Future<E?> findById(
    Id id, {
    FindByIdOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

      final storeEntity = controller.getById<Id, E>(id);
      if (fetchPolicy == FetchPolicy.storeOnly) {
        return storeEntity;
      }

      if (fetchPolicy == FetchPolicy.storeFirst && storeEntity != null) {
        return storeEntity;
      }

      final record = await store.record(idToString(id)).get(db);
      if (record == null) {
        notifyEntityNotFound(id);
        return null;
      }

      var entity = fromJson(Map<String, dynamic>.from(record));

      notifyGetComplete(entity);
      return entity;
    } catch (e) {
      throw RepositoryException('Failed to find entity: $e');
    }
  }

  @override
  Future<List<E>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

      final storeEntities = controller.getAll<Id, E>();
      if (fetchPolicy == FetchPolicy.storeOnly) {
        return storeEntities;
      }

      if (fetchPolicy == FetchPolicy.storeFirst && storeEntities.isNotEmpty) {
        return storeEntities;
      }

      final records = await store.find(db);
      final entities = records
          .map((r) => fromJson(Map<String, dynamic>.from(r.value)))
          .toList();
      notifyListComplete(entities);
      return entities;
    } catch (e) {
      throw RepositoryException('Failed to find all entities: $e');
    }
  }

  @override
  Future<E> save(
    E entity, {
    SaveOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final json = toJson(entity);
      await store.record(idToString(entity.id)).put(db, json);
      notifySaveComplete(entity);
      return entity;
    } catch (e) {
      throw EntitySaveException(entity, reason: e.toString());
    }
  }

  @override
  Future<Id> deleteById(
    Id id, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      await store.record(idToString(id)).delete(db);
      notifyDeleteComplete(id);
      return id;
    } catch (e) {
      throw EntityDeleteException(id, reason: e.toString());
    }
  }

  @override
  Future<E> delete(
    E entity, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    await deleteById(entity.id, options: options);
    return entity;
  }

  @override
  Future<int> count({CountOptions? options}) async {
    try {
      final count = await store.count(db);
      return count;
    } catch (e) {
      throw RepositoryException('Failed to count entities: $e');
    }
  }

  /// クエリ処理は SembastRepositoryQuery 経由で行います
  @override
  IRepositoryQuery<Id, E> query() {
    return SembastRepositoryQuery<Id, E>(
      repository: this,
      db: db,
      store: store,
      toJson: toJson,
      fromJson: fromJson,
    );
  }

  @override
  Future<E?> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

      final storeEntities = controller.getAll<Id, E>();
      if (fetchPolicy == FetchPolicy.storeOnly) {
        return storeEntities.firstOrNull;
      }

      if (fetchPolicy == FetchPolicy.storeFirst &&
          storeEntities.isNotEmpty) {
        return storeEntities.first;
      }

      final record = await store.findFirst(db);
      if (record == null) {
        return null;
      }

      final entity = fromJson(Map<String, dynamic>.from(record.value));
      notifyGetComplete(entity);
      return entity;
    } catch (e) {
      throw RepositoryException('Failed to find one entity: $e');
    }
  }

  @override
  Stream<E?> observeById(
    Id id, {
    ObserveByIdOptions? options,
  }) {
    try {
      final record = store.record(idToString(id));
      return record.onSnapshot(db).map((snapshot) {
        if (snapshot == null) {
          notifyEntityNotFound(id);
          return null;
        }

        final entity = fromJson(Map<String, dynamic>.from(snapshot.value));
        notifyGetComplete(entity);
        return entity;
      });
    } catch (e) {
      throw RepositoryException('Failed to observe entity: $e');
    }
  }

  @override
  Future<E?> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  }) async {
    try {
      final existingEntity = await findById(id);
      final newEntity =
          existingEntity == null ? creater() : updater(existingEntity);

      if (newEntity == null) {
        return null;
      }

      await save(newEntity);
      return newEntity;
    } catch (e) {
      throw RepositoryException('Failed to upsert entity: $e');
    }
  }
}
