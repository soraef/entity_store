import 'package:collection/collection.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/in_memory_repository.dart';
import 'package:skyreach_result/skyreach_result.dart';

import '../repository_interface.dart';

class InMemoryRepositoryQuery<Id, E extends Entity<Id>>
    implements IRepositoryQuery<Id, E> {
  final InMemoryRepository _repository;
  final List<Filter> _filters;
  final List<Sort> _sorts;
  final int? _limitNum;
  final Id? _startAfterId;

  List<Filter> get getFilters => _filters;
  List<Sort> get getSorts => _sorts;
  int? get getLimit => _limitNum;
  Id? get getStartAfterId => _startAfterId;

  InMemoryRepositoryQuery._(
    this._repository,
    this._filters,
    this._sorts,
    this._limitNum,
    this._startAfterId,
  );

  const InMemoryRepositoryQuery(this._repository)
      : _filters = const [],
        _sorts = const [],
        _limitNum = null,
        _startAfterId = null;

  @override
  InMemoryRepositoryQuery<Id, E> where(
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
    return InMemoryRepositoryQuery._(
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
  InMemoryRepositoryQuery<Id, E> orderBy(Object field,
      {bool descending = false}) {
    return InMemoryRepositoryQuery<Id, E>._(
      _repository,
      _filters,
      [..._sorts, Sort(field, descending)],
      _limitNum,
      _startAfterId,
    );
  }

  @override
  InMemoryRepositoryQuery<Id, E> limit(int num) {
    return InMemoryRepositoryQuery<Id, E>._(
      _repository,
      _filters,
      _sorts,
      num,
      _startAfterId,
    );
  }

  @override
  InMemoryRepositoryQuery<Id, E> startAfterId(Id id) {
    return InMemoryRepositoryQuery<Id, E>._(
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
    var entities = _repository.controller
        .where<Id, E>(
          (e) => test(
            _repository.toJson(e),
          ),
        )
        .toList();

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
