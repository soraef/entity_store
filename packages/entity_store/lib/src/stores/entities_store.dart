import 'package:entity_store/src/entity.dart';
import 'package:entity_store/src/entity_map.dart';
import 'package:entity_store/src/repository.dart';
import 'package:entity_store/src/store.dart';

mixin GetEntitiesStore<Id, E extends Entity<Id>> on Store<EntityMap<Id, E>> {
  RepositoryGet<Id, E> get repositoryGet;

  Future<E?> get(
    Id id, {
    bool searchStore = false,
  }) async {
    if (searchStore) {
      final entity = value.byId(id);
      if (entity != null) return entity;
    }
    final entity = await repositoryGet.get(id);
    update((prev) => entity != null ? prev.put(entity) : prev.removeById(id));
    return entity;
  }

  Future<List<E>> getByIds(List<Id> ids) async {
    final entities = await repositoryGet.getByIds(ids);
    update((prev) => prev.putAll(entities));
    return entities;
  }
}

mixin ListEntitiesStore<Id, E extends Entity<Id>, Params extends IListParams>
    on Store<EntityMap<Id, E>> {
  RepositoryList<E, Params> get repositoryList;

  Future<List<E>> list(Params params) async {
    final entities = await repositoryList.list(params);
    update((prev) => prev.putAll(entities));
    return entities;
  }
}

mixin CursorEntitiesStore<Id, E extends Entity<Id>> on Store<EntityMap<Id, E>> {
  RepositoryCursor<E> get repositoryCursor;

  /// 取得したEntityの一覧を返す
  Future<List<E>> cursor(CursorParams params) async {
    final entities = await repositoryCursor.cursor(params);
    update((prev) => prev.putAll(entities));
    return entities;
  }
}

mixin SaveEntitiesStore<Id, E extends Entity<Id>> on Store<EntityMap<Id, E>> {
  RepositorySave<Id, E> get repositorySave;

  Future<E> save(E entity) async {
    await repositorySave.save(entity);
    update((prev) => prev.put(entity));
    return entity;
  }
}

mixin SavePartialEntitiesStore<Id, E extends MargeablePartialEntity<Id, E>>
    on Store<EntityMap<Id, E>> {
  RepositoryPartialSave<Id, E> get repositoryPartialSave;
  RepositoryGet<Id, E> get repositoryGet;

  Future<E> savePartial(PartialEntity<Id, E> entity) async {
    final e = await repositoryGet.get(entity.id);
    if (e == null && !entity.canCreate) {
      throw Exception('Entity cannot save because entity does not exist.');
    }

    await repositoryPartialSave.partialSave(entity);

    late E newEntity;
    if (e == null) {
      newEntity = entity.create()!;
    } else {
      newEntity = e.merge(entity);
    }

    update((prev) => prev.put(newEntity));

    return newEntity;
  }
}

mixin DeleteEntitiesStore<Id, E extends Entity<Id>> on Store<EntityMap<Id, E>> {
  RepositoryDelete<Id, E> get repositoryDelete;

  Future<E> delete(E entity) async {
    await repositoryDelete.delete(entity);
    update((prev) => prev.removeById(entity.id));
    return entity;
  }
}

abstract class EntitiesStore<Id, E extends Entity<Id>,
        Params extends IListParams> extends Store<EntityMap<Id, E>>
    with
        GetEntitiesStore<Id, E>,
        ListEntitiesStore<Id, E, Params>,
        CursorEntitiesStore<Id, E>,
        SaveEntitiesStore<Id, E>,
        DeleteEntitiesStore<Id, E> {
  EntitiesStore(this.repository);
  final RepositoryAll<Id, E, Params> repository;

  @override
  RepositoryCursor<E> get repositoryCursor => repository;

  @override
  RepositoryDelete<Id, E> get repositoryDelete => repository;

  @override
  RepositoryGet<Id, E> get repositoryGet => repository;

  @override
  RepositoryList<E, Params> get repositoryList => repository;

  @override
  RepositorySave<Id, E> get repositorySave => repository;
}
