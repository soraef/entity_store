import 'package:entity_store/src/entity.dart';
import 'package:entity_store/src/entity_map.dart';
import 'package:entity_store/src/repository.dart';
import 'package:entity_store/src/store.dart';
import 'package:result_type/result_type.dart';

mixin GetEntitiesStore<Id, E extends Entity<Id>> on Store<EntityMap<Id, E>> {
  RepositoryGet<Id, E> get repositoryGet;

  Future<Result<E?, Exception>> get(
    Id id, {
    bool searchStore = false,
  }) async {
    if (searchStore) {
      final entity = value.byId(id);
      if (entity != null) return Success(entity);
    }

    final result = await repositoryGet.get(id);

    if (result.isFailure) {
      return result;
    }

    final entity = result.success;
    update((prev) => entity != null ? prev.put(entity) : prev.removeById(id));
    return Success(entity);
  }

  Future<Result<List<E>, Exception>> getByIds(List<Id> ids) async {
    final result = await repositoryGet.getByIds(ids);
    if (result.isFailure) {
      return result;
    }
    final entities = result.success;
    update((prev) => prev.putAll(entities));
    return Success(entities);
  }
}

mixin ListEntitiesStore<Id, E extends Entity<Id>,
    Params extends IListParams<Id, E>> on Store<EntityMap<Id, E>> {
  RepositoryList<Id, E, Params> get repositoryList;

  Future<Result<List<E>, Exception>> list(Params params) async {
    final result = await repositoryList.list(params);
    if (result.isFailure) {
      return result;
    }
    final entities = result.success;
    update((prev) => prev.putAll(entities));
    return Success(entities);
  }
}

mixin SaveEntitiesStore<Id, E extends Entity<Id>> on Store<EntityMap<Id, E>> {
  RepositorySave<Id, E> get repositorySave;

  Future<Result<E, Exception>> save(E entity) async {
    final result = await repositorySave.save(entity);
    if (result.isFailure) {
      return result;
    }

    update((prev) => prev.put(result.success));
    return result;
  }
}

mixin DeleteEntitiesStore<Id, E extends Entity<Id>> on Store<EntityMap<Id, E>> {
  RepositoryDelete<Id, E> get repositoryDelete;

  Future<Result<E, Exception>> delete(E entity) async {
    final result = await repositoryDelete.delete(entity);
    if (result.isFailure) {
      return result;
    }

    update((prev) => prev.removeById(entity.id));
    return result;
  }
}

abstract class EntitiesStore<Id, E extends Entity<Id>,
        Params extends IListParams<Id, E>> extends Store<EntityMap<Id, E>>
    with
        GetEntitiesStore<Id, E>,
        ListEntitiesStore<Id, E, Params>,
        SaveEntitiesStore<Id, E>,
        DeleteEntitiesStore<Id, E> {
  EntitiesStore(this.repository);
  final RepositoryAll<Id, E, Params> repository;

  @override
  RepositoryDelete<Id, E> get repositoryDelete => repository;

  @override
  RepositoryGet<Id, E> get repositoryGet => repository;

  @override
  RepositoryList<Id, E, Params> get repositoryList => repository;

  @override
  RepositorySave<Id, E> get repositorySave => repository;
}
