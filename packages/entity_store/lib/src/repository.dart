import 'entity.dart';

abstract class RepositoryGet<Id, E extends Entity<Id>> {
  Future<E?> get(Id id);
  Future<List<E>> getByIds(List<Id> ids);
}

abstract class IListParams<Id, E extends Entity<Id>> {}

abstract class RepositoryList<Id, E extends Entity<Id>,
    Params extends IListParams<Id, E>> {
  Future<List<E>> list(Params params);
}

abstract class RepositorySave<Id, E extends Entity<Id>> {
  Future<void> save(E entity);
}

abstract class RepositoryPartialSave<Id, E extends Entity<Id>> {
  Future<void> partialSave(PartialEntity<Id, E> partial);
}

abstract class RepositoryDelete<Id, E extends Entity<Id>> {
  Future<void> delete(E entity);
}

abstract class CursorParams {}

abstract class RepositoryCursor<R extends Entity> {
  Future<List<R>> cursor(CursorParams params);
}

abstract class RepositoryAll<Id, E extends Entity<Id>,
        ListParams extends IListParams<Id, E>>
    with
        RepositoryGet<Id, E>,
        RepositoryList<Id, E, ListParams>,
        RepositoryCursor<E>,
        RepositorySave<Id, E>,
        RepositoryDelete<Id, E> {}

class RepositoryConverter<Id, E extends Entity<Id>> {
  final E Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(E) toJson;

  RepositoryConverter({
    required this.fromJson,
    required this.toJson,
  });
}
