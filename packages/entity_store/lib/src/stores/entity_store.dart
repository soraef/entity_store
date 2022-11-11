import 'package:entity_store/src/entity.dart';
import 'package:entity_store/src/repository.dart';
import 'package:entity_store/src/store.dart';

mixin GetEntityStore<Id, E extends Entity<Id>> implements Store<E?> {
  RepositoryGet<Id, E> get repositoryGet;

  /// RepoからEntityを取得して、Storeに保存し、Entityを返す
  Future<E?> get(Id id) async {
    final entity = await repositoryGet.get(id);
    update((prev) => entity);
    return entity;
  }

  /// StoreにEntityがなければ[get]してEntityを返す
  Future<E?> getUnlessExist(Id id) async {
    if (value != null) return value;
    return await get(id);
  }
}

mixin SaveEntityStore<Id, E extends Entity<Id>> implements Store<E?> {
  RepositorySave<Id, E> get repositorySave;

  Future<E> save(E entity) async {
    await repositorySave.save(entity);
    update((prev) => entity);
    return entity;
  }
}

mixin DeleteEntityStore<Id, E extends Entity<Id>> implements Store<E?> {
  RepositoryDelete<Id, E> get repositoryDelete;

  Future<E> delete(E entity) async {
    await repositoryDelete.delete(entity);
    update((prev) => null);
    return entity;
  }
}
