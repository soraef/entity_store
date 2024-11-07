part of '../storage_repository.dart';

class StorageRepositoryQuery<Id, E extends Entity<Id>>
    implements IRepositoryQuery<Id, E> {
  final StorageRepository<Id, E> _repository;

  @override
  final List<RepositoryFilter> filters;
  @override
  final List<RepositorySort> sorts;
  @override
  final int? limitNum;
  @override
  final Id? startAfterId;

  List<RepositoryFilter> get getFilters => filters;
  List<RepositorySort> get getSorts => sorts;
  int? get getLimit => limitNum;
  Id? get getStartAfterId => startAfterId;

  StorageRepositoryQuery._(
    this._repository,
    this.filters,
    this.sorts,
    this.limitNum,
    this.startAfterId,
  );

  const StorageRepositoryQuery(this._repository)
      : filters = const [],
        sorts = const [],
        limitNum = null,
        startAfterId = null;

  @override
  StorageRepositoryQuery<Id, E> where(
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
    return StorageRepositoryQuery._(
      _repository,
      [
        ...filters,
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
      sorts,
      limitNum,
      startAfterId,
    );
  }

  @override
  StorageRepositoryQuery<Id, E> orderBy(
    Object field, {
    bool descending = false,
  }) {
    return StorageRepositoryQuery._(
      _repository,
      filters,
      [
        ...sorts,
        RepositorySort(
          field,
          descending,
        ),
      ],
      limitNum,
      startAfterId,
    );
  }

  @override
  StorageRepositoryQuery<Id, E> limit(int count) {
    return StorageRepositoryQuery._(
      _repository,
      filters,
      sorts,
      count,
      startAfterId,
    );
  }

  @override
  StorageRepositoryQuery<Id, E> startAfter(Id id) {
    return StorageRepositoryQuery._(
      _repository,
      filters,
      sorts,
      limitNum,
      id,
    );
  }

  @override
  bool test(Map<String, dynamic> object) {
    return filters.map((e) => e.test(object)).every((e) => e);
  }

  @override
  Future<Result<List<E>, Exception>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw UnimplementedError(
        'Transaction is not supported in LocalStorageRepository',
      );
    }

    final skipSyncCheck = switch (options) {
      StorageFindAllOptions(skipSyncCheck: true) => true,
      _ => false,
    };

    if (!skipSyncCheck) {
      final syncResult = await _repository.syncRemoteDataIfUpdated();
      if (syncResult.isExcept) {
        return Result.except(syncResult.except);
      }
    }

    options = options ?? const FindAllOptions();
    final objects = _repository.controller
        .getAll<Id, E>()
        .map((e) => _repository.toJson(e))
        .toList();
    var storeEntities = IRepositoryQuery.findEntities(objects, this)
        .map((e) => _repository.fromJson(e))
        .toList();

    if (options.fetchPolicy == FetchPolicy.storeOnly) {
      return Result.ok(storeEntities);
    }

    if (options.fetchPolicy == FetchPolicy.storeFirst) {
      if (storeEntities.isNotEmpty) {
        return Result.ok(storeEntities);
      }
    }

    final result = await _repository.dataSourceHandler.loadAll();

    if (result.isExcept) {
      return Result.except(result.except);
    }

    var entities =
        result.ok!.where((e) => test(_repository.toJson(e))).toList();

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
  Future<Result<E?, Exception>> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw UnimplementedError(
        'Transaction is not supported in LocalStorageRepository',
      );
    }

    final skipSyncCheck = switch (options) {
      StorageFindOneOptions(skipSyncCheck: true) => true,
      _ => false,
    };

    if (!skipSyncCheck) {
      final syncResult = await _repository.syncRemoteDataIfUpdated();
      if (syncResult.isExcept) {
        return Result.except(syncResult.except);
      }
    }

    options ??= const FindOneOptions();

    return (await findAll(
            options: FindAllOptions(fetchPolicy: options.fetchPolicy)))
        .mapOk((ok) => ok.firstOrNull);
  }

  @override
  Future<Result<int, Exception>> count({
    CountOptions? options,
  }) async {
    final skipSyncCheck = switch (options) {
      StorageCountOptions(skipSyncCheck: true) => true,
      _ => false,
    };

    if (!skipSyncCheck) {
      final syncResult = await _repository.syncRemoteDataIfUpdated();
      if (syncResult.isExcept) {
        return Result.except(syncResult.except);
      }
    }

    return (await findAll()).mapOk((ok) => ok.length);
  }

  @override
  Stream<Result<List<EntityChange<E>>, Exception>> observeAll({
    ObserveAllOptions? options,
  }) {
    throw UnimplementedError();
  }
}
