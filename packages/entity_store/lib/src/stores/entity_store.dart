import 'package:entity_store/src/entity.dart';
import 'package:entity_store/src/repository.dart';
import 'package:entity_store/src/store.dart';
import 'package:result_type/result_type.dart';

mixin GetEntityStore<Id, E extends Entity<Id>> implements Store<E?> {
  RepositoryGet<Id, E> get repositoryGet;

  /// RepoからEntityを取得して、Storeに保存し、Entityを返す
  Future<Result<E?, Exception>> get(Id id) async {
    final entity = await repositoryGet.get(id);
    if (entity.isFailure) {
      return entity;
    }

    update((prev) => entity.success);
    return entity;
  }

  /// StoreにEntityがなければ[get]してEntityを返す
  Future<Result<E?, Exception>> getUnlessExist(Id id) async {
    if (value != null) return Success(value);
    return await get(id);
  }
}

mixin SaveEntityStore<Id, E extends Entity<Id>> implements Store<E?> {
  RepositorySave<Id, E> get repositorySave;

  Future<Result<E, Exception>> save(E entity) async {
    final result = await repositorySave.save(entity);

    if (result.isFailure) {
      return result;
    }

    update((prev) => entity);
    return Success(entity);
  }
}

mixin DeleteEntityStore<Id, E extends Entity<Id>> implements Store<E?> {
  RepositoryDelete<Id, E> get repositoryDelete;

  Future<Result<E, Exception>> delete(E entity) async {
    final result = await repositoryDelete.delete(entity);
    if (result.isFailure) {
      return result;
    }

    update((prev) => null);
    return Success(entity);
  }
}
