import 'entity.dart';

abstract class RepositoryGet<Id, R extends Entity<Id>> {
  Future<R?> get(Id id);
  Future<List<R>> getByIds(List<Id> ids);
}

abstract class ListParams {}

abstract class RepositoryList<R extends Entity> {
  Future<List<R>> list(ListParams params);
}

abstract class RepositorySave<E extends Entity> {
  Future<void> save(E entity);
}

abstract class RepositoryPartialSave<Id, E extends Entity<Id>> {
  Future<void> partialSave(PartialEntity<Id, E> partial);
}

abstract class RepositoryDelete<T> {
  Future<void> delete(T entity);
}

abstract class CursorParams {}

abstract class RepositoryCursor<R extends Entity> {
  Future<List<R>> cursor(CursorParams params);
}

abstract class RepositoryAll<Id, E extends Entity<Id>>
    with
        RepositoryGet<Id, E>,
        RepositoryList<E>,
        RepositoryCursor<E>,
        RepositorySave<E>,
        RepositoryDelete<E> {}

class RepositoryConverter<Id, E extends Entity<Id>> {
  final E Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(E) toJson;

  RepositoryConverter({
    required this.fromJson,
    required this.toJson,
  });
}
