import 'package:result_type/result_type.dart';

import 'entity.dart';

abstract class RepositoryGet<Id, E extends Entity<Id>> {
  Future<Result<E?, Exception>> get(Id id);
  Future<Result<List<E>, Exception>> getByIds(List<Id> ids);
}

abstract class IListParams<Id, E extends Entity<Id>> {}

abstract class RepositoryList<Id, E extends Entity<Id>,
    Params extends IListParams<Id, E>> {
  Future<Result<List<E>, Exception>> list(Params params);
}

class SaveOptions {
  final bool merge;
  const SaveOptions({this.merge = false});
}

abstract class RepositorySave<Id, E extends Entity<Id>> {
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions options = const SaveOptions(),
  });
}

abstract class RepositoryDelete<Id, E extends Entity<Id>> {
  Future<Result<E, Exception>> delete(E entity);
}

abstract class RepositoryAll<Id, E extends Entity<Id>,
        ListParams extends IListParams<Id, E>>
    with
        RepositoryGet<Id, E>,
        RepositoryList<Id, E, ListParams>,
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
