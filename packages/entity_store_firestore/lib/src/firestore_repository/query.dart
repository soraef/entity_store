// ignore_for_file: invalid_use_of_protected_member

part of '../firestore_repository.dart';

class FirestoreRepositoryQuery<Id, E extends Entity<Id>>
    implements IRepositoryQuery<Id, E> {
  final BaseFirestoreRepository<Id, E> _repository;
  final List<Filter> _filters;
  final List<Sort> _sorts;
  final int? _limitNum;
  final Id? _startAfterId;

  List<Filter> get getFilters => _filters;
  List<Sort> get getSorts => _sorts;
  int? get getLimit => _limitNum;
  Id? get getStartAfterId => _startAfterId;

  FirestoreRepositoryQuery._(
    this._repository,
    this._filters,
    this._sorts,
    this._limitNum,
    this._startAfterId,
  );

  const FirestoreRepositoryQuery(this._repository)
      : _filters = const [],
        _sorts = const [],
        _limitNum = null,
        _startAfterId = null;

  @override
  FirestoreRepositoryQuery<Id, E> where(
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
    return FirestoreRepositoryQuery._(
      _repository,
      [
        ..._filters,
        if (isEqualTo != null)
          Filter(
            field,
            FilterOperator.isEqualTo,
            isEqualTo,
          ),
        if (isNotEqualTo != null)
          Filter(
            field,
            FilterOperator.isNotEqualTo,
            isNotEqualTo,
          ),
        if (isLessThan != null)
          Filter(
            field,
            FilterOperator.isLessThan,
            isLessThan,
          ),
        if (isLessThanOrEqualTo != null)
          Filter(
            field,
            FilterOperator.isLessThanOrEqualTo,
            isLessThanOrEqualTo,
          ),
        if (isGreaterThan != null)
          Filter(
            field,
            FilterOperator.isGreaterThan,
            isGreaterThan,
          ),
        if (isGreaterThanOrEqualTo != null)
          Filter(
            field,
            FilterOperator.isGreaterThanOrEqualTo,
            isGreaterThanOrEqualTo,
          ),
        if (arrayContainsAny != null)
          Filter(
            field,
            FilterOperator.arrayContains,
            arrayContains,
          ),
        if (arrayContainsAny != null)
          Filter(
            field,
            FilterOperator.arrayContainsAny,
            arrayContainsAny,
          ),
        if (whereIn != null)
          Filter(
            field,
            FilterOperator.whereIn,
            whereIn,
          ),
        if (whereNotIn != null)
          Filter(
            field,
            FilterOperator.whereNotIn,
            whereNotIn,
          ),
        if (isNull != null)
          Filter(
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
  FirestoreRepositoryQuery<Id, E> orderBy(
    Object field, {
    bool descending = false,
  }) {
    return FirestoreRepositoryQuery<Id, E>._(
      _repository,
      _filters,
      [..._sorts, Sort(field, descending)],
      _limitNum,
      _startAfterId,
    );
  }

  @override
  FirestoreRepositoryQuery<Id, E> limit(int num) {
    return FirestoreRepositoryQuery<Id, E>._(
      _repository,
      _filters,
      _sorts,
      num,
      _startAfterId,
    );
  }

  @override
  FirestoreRepositoryQuery<Id, E> startAfterId(Id id) {
    return FirestoreRepositoryQuery<Id, E>._(
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

  Query _buildFilterQuery(Query query) {
    for (final filter in getFilters) {
      switch (filter.operator) {
        case FilterOperator.isEqualTo:
          query = query.where(filter.field, isEqualTo: filter.value);
          break;
        case FilterOperator.isNotEqualTo:
          query = query.where(filter.field, isNotEqualTo: filter.value);
          break;
        case FilterOperator.isLessThan:
          query = query.where(filter.field, isLessThan: filter.value);
          break;
        case FilterOperator.isLessThanOrEqualTo:
          query = query.where(filter.field, isLessThanOrEqualTo: filter.value);
          break;
        case FilterOperator.isGreaterThan:
          query = query.where(filter.field, isGreaterThan: filter.value);
          break;
        case FilterOperator.isGreaterThanOrEqualTo:
          query =
              query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
          break;
        case FilterOperator.arrayContains:
          query = query.where(filter.field, arrayContains: filter.value);
          break;
        case FilterOperator.arrayContainsAny:
          query = query.where(filter.field, arrayContainsAny: filter.value);
          break;
        case FilterOperator.whereIn:
          query = query.where(filter.field, whereIn: filter.value);
          break;
        case FilterOperator.whereNotIn:
          query = query.where(filter.field, whereNotIn: filter.value);
          break;
        case FilterOperator.isNull:
          query = query.where(filter.field, isNull: filter.value);
          break;
      }
    }
    return query;
  }

  Query _buildSortQuery(Query query) {
    for (final sort in getSorts) {
      query = query.orderBy(sort.field, descending: sort.descending);
    }
    return query;
  }

  Query _buildLimitQuery(Query query) {
    final lim = getLimit;
    if (lim != null) {
      return query.limit(lim);
    }
    return query;
  }

  Future<Query> _build() async {
    var ref = _buildFilterQuery(_repository.collectionRef);
    if (_startAfterId != null) {
      final doc = await _repository.getDocumentRef(_startAfterId as Id).get();
      ref = ref.startAfterDocument(doc);
    }
    ref = _buildSortQuery(ref);
    ref = _buildLimitQuery(ref);
    return ref;
  }

  @override
  Future<Result<List<E>, Exception>> findAll() async {
    final ref = await _build();
    return _repository.protectedListAndNotify(ref);
  }

  @override
  Future<Result<E?, Exception>> findOne() async {
    final ref = await _build();
    return (await _repository.protectedListAndNotify(ref.limit(1)))
        .mapOk((ok) => ok.firstOrNull);
  }
}
