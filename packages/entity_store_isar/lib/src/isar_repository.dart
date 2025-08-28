import 'package:entity_store/entity_store.dart' as e;
import 'package:entity_store/entity_store.dart';
import 'package:isar/isar.dart';

import 'isar_repository_query.dart';

abstract class IsarRepository<Id, E extends e.Entity<Id>, IsarModel>
    with e.EntityChangeNotifier<Id, E>
    implements e.Repository<Id, E> {
  final Isar isar;
  
  @override
  final e.EntityStoreController controller;

  IsarRepository(this.isar, this.controller);

  @override
  Stream<E?> observeById(
    Id id, {
    e.ObserveByIdOptions? options,
  }) {
    throw UnimplementedError('observeById is not yet implemented for IsarRepository');
  }

  @override
  Future<int> count({
    e.CountOptions? options,
  }) {
    return query().count();
  }

  @override
  Future<Id> deleteById(
    Id id, {
    e.DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    await isar.writeTxn(
      () async {
        final collection = getCollection();
        await collection.buildQuery<IsarModel>(
          whereClauses: [
            IndexWhereClause.equalTo(
              indexName: 'id',
              value: [idToString(id)],
            ),
          ],
        ).deleteFirst();
      },
    );
    notifyDeleteComplete(id);
    return id;
  }

  Future<List<Id>> deleteByIds(
    List<Id> ids, {
    e.DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    await isar.writeTxn(() async {
      final collection = getCollection();
      for (var id in ids) {
        await collection.buildQuery<IsarModel>(
          whereClauses: [
            IndexWhereClause.equalTo(
              indexName: 'id',
              value: [idToString(id)],
            ),
          ],
        ).deleteFirst();
      }
    });

    for (var id in ids) {
      notifyDeleteComplete(id);
    }
    return ids;
  }

  @override
  Future<E> delete(
    E entity, {
    e.DeleteOptions? options,
    e.TransactionContext? transaction,
  }) async {
    await deleteById(entity.id, options: options, transaction: transaction);
    return entity;
  }

  @override
  Future<List<E>> findAll({
    e.FindAllOptions? options,
    TransactionContext? transaction,
  }) {
    return query().findAll(options: options, transaction: transaction);
  }

  @override
  Future<E?> findById(
    Id id, {
    e.FindByIdOptions? options,
    TransactionContext? transaction,
  }) async {
    final model = await getCollection().buildQuery<IsarModel>(
      whereClauses: [
        IndexWhereClause.equalTo(
          indexName: 'id',
          value: [idToString(id)],
        ),
      ],
    ).findFirst();

    if (model == null) {
      notifyEntityNotFound(id);
      return null;
    }

    final entity = toEntity(model);
    notifyGetComplete(entity);

    return entity;
  }

  @override
  Future<E?> findOne({
    e.FindOneOptions? options,
    TransactionContext? transaction,
  }) {
    return query().findOne(options: options, transaction: transaction);
  }

  @override
  IsarRepositoryQuery<Id, E, IsarModel> query() {
    return IsarRepositoryQuery(this);
  }

  @override
  Future<E> save(
    E entity, {
    e.SaveOptions? options,
    TransactionContext? transaction,
  }) async {
    final model = fromEntity(entity);
    await isar.writeTxn(() async {
      await getCollection().put(model);
    });
    notifySaveComplete(entity);
    return entity;
  }

  @override
  Future<E?> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    e.UpsertOptions? options,
  }) async {
    final findResult = await findById(id);

    final newEntity = findResult == null ? creater() : updater(findResult);

    if (newEntity != null) {
      notifySaveComplete(newEntity);
      return save(newEntity);
    } else {
      return null;
    }
  }

  Future<List<E>> saveAll(
    List<E> entities, {
    e.SaveOptions? options,
    TransactionContext? transaction,
  }) async {
    final models = entities.map((e) => fromEntity(e)).toList();
    await isar.writeTxn(() async {
      await getCollection().putAll(models);
    });
    
    for (var entity in entities) {
      notifySaveComplete(entity);
    }
    
    return entities;
  }

  Future<List<Id>> deleteAll({
    e.DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    final entities = await findAll();
    final ids = entities.map((e) => e.id).toList();
    
    await isar.writeTxn(() async {
      await getCollection().clear();
    });
    
    for (var id in ids) {
      notifyDeleteComplete(id);
    }
    
    return ids;
  }

  IsarCollection<IsarModel> getCollection();

  E toEntity(IsarModel model);

  IsarModel fromEntity(E entity);

  String idToString(Id id);
}