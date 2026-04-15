import 'package:drift/drift.dart' hide isNull;
import 'package:entity_store/entity_store.dart';

import 'drift_repository_query.dart';

abstract class EntityStoreDriftRepository<Id, E extends Entity<Id>>
    with EntityChangeNotifier<Id, E>
    implements Repository<Id, E>, EntityStoreRepository<Id, E> {
  @override
  final EntityStoreController controller;
  final GeneratedDatabase db;

  EntityStoreDriftRepository({
    required this.controller,
    required this.db,
  });

  @override
  Map<String, dynamic> toJson(E entity);

  @override
  E fromJson(Map<String, dynamic> json);

  @override
  String idToString(Id id);

  Id idFromString(String idString);

  GeneratedColumn columnFor(String fieldName);

  JoinedSelectStatement buildBaseQuery();

  E fromRow(TypedResult row);

  Future<void> insertOnConflictUpdate(
    E entity, {
    TransactionContext? transaction,
  });

  Future<void> deleteFromStore(
    Id id, {
    TransactionContext? transaction,
  });

  @override
  Future<E> save(
    E entity, {
    SaveOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      await insertOnConflictUpdate(entity, transaction: transaction);
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
      await deleteFromStore(id, transaction: transaction);
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
    await deleteById(entity.id, options: options, transaction: transaction);
    return entity;
  }

  @override
  Future<E?> findById(
    Id id, {
    FindByIdOptions? options,
    TransactionContext? transaction,
  }) async {
    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);
    final storeEntity = controller.getById<Id, E>(id);
    if (fetchPolicy == FetchPolicy.storeOnly) {
      return storeEntity;
    }
    if (fetchPolicy == FetchPolicy.storeFirst && storeEntity != null) {
      return storeEntity;
    }

    final entity = await query()
        .where('id', isEqualTo: idToString(id))
        .findOne(options: null, transaction: transaction);
    if (entity == null) {
      notifyEntityNotFound(id);
      return null;
    }
    notifyGetComplete(entity);
    return entity;
  }

  @override
  Future<List<E>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  }) {
    return query().findAll(options: options, transaction: transaction);
  }

  @override
  Future<E?> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) {
    return query().findOne(options: options, transaction: transaction);
  }

  @override
  Future<int> count({
    CountOptions? options,
  }) {
    return query().count(options: options);
  }

  @override
  IRepositoryQuery<Id, E> query() {
    return EntityStoreDriftRepositoryQuery<Id, E>(repository: this);
  }

  @override
  Future<E?> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  }) async {
    final existing = await findById(id);
    final entity = existing == null ? creater() : updater(existing);
    if (entity == null) {
      return null;
    }
    await save(entity);
    return entity;
  }

  @override
  Stream<E?> observeById(
    Id id, {
    ObserveByIdOptions? options,
  }) {
    return controller.eventStream
        .where((event) => event is PersistenceEvent<Id, E>)
        .asyncMap((_) => findById(id));
  }

  Future<List<E>> findAllLocal() async {
    final rows = await buildBaseQuery().get();
    return rows.map(fromRow).toList();
  }
}
