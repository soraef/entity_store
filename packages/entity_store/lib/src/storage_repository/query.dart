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
  Future<List<E>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException(
        'Transaction is not supported in LocalStorageRepository',
      );
    }

    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

    final objects = _repository.controller
        .getAll<Id, E>()
        .map((e) => _repository.toJson(e))
        .toList();
    var storeEntities = IRepositoryQuery.findEntities(objects, this)
        .map((e) => _repository.fromJson(e))
        .toList();

    if (fetchPolicy == FetchPolicy.storeOnly) {
      return storeEntities;
    }

    if (fetchPolicy == FetchPolicy.storeFirst) {
      if (storeEntities.isNotEmpty) {
        return storeEntities;
      }
    }

    try {
      final result = await _repository.dataSourceHandler.loadAll();
      var entities = result.where((e) => test(_repository.toJson(e))).toList();

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
      return entities;
    } catch (e) {
      throw QueryException('Failed to execute query: ${e.toString()}');
    }
  }

  @override
  Future<E?> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException(
        'Transaction is not supported in LocalStorageRepository',
      );
    }

    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

    final entities = await findAll(
      options: StorageFindAllOptions(
        fetchPolicy: fetchPolicy,
      ),
    );

    return entities.firstOrNull;
  }

  @override
  Future<int> count({
    CountOptions? options,
  }) async {
    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

    final entities = await findAll(
      options: StorageFindAllOptions(fetchPolicy: fetchPolicy),
    );

    return entities.length;
  }

  @override
  Stream<List<EntityChange<E>>> observeAll({
    ObserveAllOptions? options,
  }) {
    throw UnimplementedError('observeAll is not implemented');
  }
}
