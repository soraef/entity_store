part of "../repository.dart";

abstract class IRepository<Id, E extends Entity<Id>> {
  final EntityStoreController controller;
  IRepository(this.controller);

  Future<Result<E?, Exception>> get(
    Id id, {
    GetOptions options = const GetOptions(),
  });

  Future<Result<List<E>, Exception>> list(Query<Id, E> query);

  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions options = const SaveOptions(),
  });

  Future<Result<E, Exception>> delete(
    E entity, {
    DeleteOptions options = const DeleteOptions(),
  });

  Future<List<E>> getByIds(List<Id> ids) async {
    final future = ids.map((id) => get(id));
    final docs = await Future.wait(future);

    return docs.map((e) => e.mapErr((p0) => null)).whereType<E>().toList();
  }
}

class GetOptions {
  final bool useCache;

  const GetOptions({
    this.useCache = false,
  });
}

class SaveOptions {
  final bool merge;
  const SaveOptions({
    this.merge = false,
  });
}

class DeleteOptions {
  const DeleteOptions();
}

enum FilterOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}

class Filter {
  final Object field;
  final FilterOperator operator;
  final dynamic value;

  Filter(this.field, this.operator, this.value);
}

class Sort {
  final Object field;
  final bool descending;

  Sort(this.field, this.descending);
}

class Query<Id, E extends Entity<Id>> {
  final List<Filter> _filters;
  final List<Sort> _sorts;
  final int? _limitNum;
  final Id? _startAfterId;

  List<Filter> get getFilters => _filters;
  List<Sort> get getSorts => _sorts;
  int? get getLimit => _limitNum;
  Id? get getStartAfterId => _startAfterId;

  Query._(
    this._filters,
    this._sorts,
    this._limitNum,
    this._startAfterId,
  );

  Query()
      : _filters = [],
        _sorts = [],
        _limitNum = null,
        _startAfterId = null;

  Query<Id, E> where(
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
    return Query._(
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

  Query<Id, E> orderBy(Object field, {bool descending = false}) {
    return Query<Id, E>._(
      _filters,
      [..._sorts, Sort(field, descending)],
      _limitNum,
      _startAfterId,
    );
  }

  Query<Id, E> limit(int num) {
    return Query<Id, E>._(
      _filters,
      _sorts,
      num,
      _startAfterId,
    );
  }

  Query<Id, E> startAfterId(Id id) {
    return Query<Id, E>._(
      _filters,
      _sorts,
      _limitNum,
      id,
    );
  }
}
