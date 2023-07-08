part of '../local_storage_repository.dart';

class LocalStorageRepositoryQuery<Id, E extends Entity<Id>>
    implements IRepositoryQuery<Id, E> {
  final LocalStorageRepository<Id, E> _repository;
  final List<RepositoryFilter> _filters;
  final List<RepositorySort> _sorts;
  final int? _limitNum;
  final Id? _startAfterId;

  List<RepositoryFilter> get getFilters => _filters;
  List<RepositorySort> get getSorts => _sorts;
  int? get getLimit => _limitNum;
  Id? get getStartAfterId => _startAfterId;

  LocalStorageRepositoryQuery._(
    this._repository,
    this._filters,
    this._sorts,
    this._limitNum,
    this._startAfterId,
  );

  const LocalStorageRepositoryQuery(this._repository)
      : _filters = const [],
        _sorts = const [],
        _limitNum = null,
        _startAfterId = null;

  @override
  LocalStorageRepositoryQuery<Id, E> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return LocalStorageRepositoryQuery._(
      _repository,
      [
        ..._filters,
        if (isEqualTo != null)
          RepositoryFilter(
            field,
            FilterOperator.isEqualTo,
            isEqualTo,
          ),
        if (isNotEqualTo != null)
          RepositoryFilter(
            field,
            FilterOperator.isNotEqualTo,
            isNotEqualTo,
          ),
        if (isLessThan != null)
          RepositoryFilter(
            field,
            FilterOperator.isLessThan,
            isLessThan,
          ),
        if (isLessThanOrEqualTo != null)
          RepositoryFilter(
            field,
            FilterOperator.isLessThanOrEqualTo,
            isLessThanOrEqualTo,
          ),
        if (isGreaterThan != null)
          RepositoryFilter(
            field,
            FilterOperator.isGreaterThan,
            isGreaterThan,
          ),
        if (isGreaterThanOrEqualTo != null)
          RepositoryFilter(
            field,
            FilterOperator.isGreaterThanOrEqualTo,
            isGreaterThanOrEqualTo,
          ),
        if (arrayContains != null)
          RepositoryFilter(
            field,
            FilterOperator.arrayContains,
            arrayContains,
          ),
        if (arrayContainsAny != null)
          RepositoryFilter(
            field,
            FilterOperator.arrayContainsAny,
            arrayContainsAny,
          ),
        if (whereIn != null)
          RepositoryFilter(
            field,
            FilterOperator.whereIn,
            whereIn,
          ),
        if (whereNotIn != null)
          RepositoryFilter(
            field,
            FilterOperator.whereNotIn,
            whereNotIn,
          ),
        if (isNull != null)
          RepositoryFilter(
            field,
            FilterOperator.isNull,
            isNull,
          ),
      ],
      _sorts,
      _limitNum,
      _startAfterId,
    );
  }

  @override
  LocalStorageRepositoryQuery<Id, E> orderBy(
    Object field, {
    bool descending = false,
  }) {
    return LocalStorageRepositoryQuery._(
      _repository,
      _filters,
      [
        ..._sorts,
        RepositorySort(
          field,
          descending,
        ),
      ],
      _limitNum,
      _startAfterId,
    );
  }

  @override
  LocalStorageRepositoryQuery<Id, E> limit(int count) {
    return LocalStorageRepositoryQuery._(
      _repository,
      _filters,
      _sorts,
      count,
      _startAfterId,
    );
  }

  @override
  LocalStorageRepositoryQuery<Id, E> startAfterId(Id id) {
    return LocalStorageRepositoryQuery._(
      _repository,
      _filters,
      _sorts,
      _limitNum,
      id,
    );
  }

  @override
  bool test(Map<String, dynamic> object) {
    return _filters.map((e) => e.test(object)).every((e) => e);
  }

  @override
  Future<Result<List<E>, Exception>> findAll() async {
    final result = await _repository.localStorageEntityHander.loadEntityList();

    if (result.isErr) {
      return Result.err(result.err);
    }

    var entities = result.ok.where((e) => test(_repository.toJson(e))).toList();

    final sorts = getSorts;
    for (final sort in sorts.reversed) {
      entities = entities.sorted(
        (a, b) {
          final fieldA = _repository.toJson(a)[sort.field] as Comparable;
          final fieldB = _repository.toJson(b)[sort.field] as Comparable;
          if (sort.descending) {
            return fieldB.compareTo(fieldA);
          } else {
            return fieldA.compareTo(fieldB);
          }
        },
      );
    }

    final startAfterId = getStartAfterId;
    if (startAfterId != null) {
      entities =
          entities.skipWhile((e) => e.id != startAfterId).skip(1).toList();
    }

    final limit = getLimit;
    if (limit != null) {
      entities = entities.take(limit).toList();
    }

    _repository.notifyListComplete(entities);
    return Result.ok(entities);
  }

  @override
  Future<Result<E?, Exception>> findOne() async {
    return (await findAll()).mapOk((ok) => ok.firstOrNull);
  }
}
