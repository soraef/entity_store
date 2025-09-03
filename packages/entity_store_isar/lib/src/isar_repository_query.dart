import 'package:entity_store/entity_store.dart' as e;
import 'package:entity_store/entity_store.dart';
import 'package:isar_community/isar.dart';

import 'isar_repository.dart';

class IsarRepositoryQuery<Id, E extends e.Entity<Id>, IsarModel>
    extends e.IRepositoryQuery<Id, E> {
  final IsarRepository<Id, E, IsarModel> _repository;
  final List<e.RepositoryFilter> _filters;
  final List<e.RepositorySort> _sorts;
  final int? _limitNum;
  final Id? _startAfterId;

  IsarRepositoryQuery._(
    this._repository,
    this._filters,
    this._sorts,
    this._limitNum,
    this._startAfterId,
  );

  IsarRepositoryQuery(this._repository)
      : _filters = const [],
        _sorts = const [],
        _limitNum = null,
        _startAfterId = null;

  @override
  e.IRepositoryQuery<Id, E> where(
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
    return IsarRepositoryQuery._(
      _repository,
      [
        ..._filters,
        if (isEqualTo != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.isEqualTo,
            isEqualTo,
          ),
        if (isNotEqualTo != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.isNotEqualTo,
            isNotEqualTo,
          ),
        if (isLessThan != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.isLessThan,
            isLessThan,
          ),
        if (isLessThanOrEqualTo != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.isLessThanOrEqualTo,
            isLessThanOrEqualTo,
          ),
        if (isGreaterThan != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.isGreaterThan,
            isGreaterThan,
          ),
        if (isGreaterThanOrEqualTo != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.isGreaterThanOrEqualTo,
            isGreaterThanOrEqualTo,
          ),
        if (arrayContains != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.arrayContains,
            arrayContains,
          ),
        if (arrayContainsAny != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.arrayContainsAny,
            arrayContainsAny,
          ),
        if (whereIn != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.whereIn,
            whereIn,
          ),
        if (whereNotIn != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.whereNotIn,
            whereNotIn,
          ),
        if (isNull != null)
          e.RepositoryFilter(
            field,
            e.FilterOperator.isNull,
            isNull,
          ),
      ],
      _sorts,
      _limitNum,
      _startAfterId,
    );
  }

  @override
  e.IRepositoryQuery<Id, E> orderBy(
    Object field, {
    bool descending = false,
  }) {
    return IsarRepositoryQuery._(
      _repository,
      _filters,
      [
        ..._sorts,
        e.RepositorySort(
          field,
          descending,
        ),
      ],
      _limitNum,
      _startAfterId,
    );
  }

  @override
  e.IRepositoryQuery<Id, E> limit(int count) {
    return IsarRepositoryQuery._(
      _repository,
      _filters,
      _sorts,
      count,
      _startAfterId,
    );
  }

  @override
  e.IRepositoryQuery<Id, E> startAfter(Id id) {
    return IsarRepositoryQuery._(
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

  Future<QueryBuilder<IsarModel, IsarModel, dynamic>> _buildQuery() async {
    var query = _repository.getCollection().where();
    for (var filter in _filters) {
      if (filter.operator == e.FilterOperator.isEqualTo) {
        query = QueryBuilder.apply(
          query,
          (query) => query.addFilterCondition(
            FilterCondition.equalTo(
              property: filter.field as String,
              value: filter.value,
            ),
          ),
        );
      } else if (filter.operator == e.FilterOperator.isNotEqualTo) {
        query = QueryBuilder.apply(
          query,
          (query) => query.addFilterCondition(
            FilterGroup.not(
              FilterCondition.equalTo(
                property: filter.field as String,
                value: filter.value,
              ),
            ),
          ),
        );
      } else if (filter.operator == e.FilterOperator.isLessThan) {
        query = QueryBuilder.apply(
          query,
          (query) => query.addFilterCondition(
            FilterCondition.lessThan(
              property: filter.field as String,
              value: filter.value,
            ),
          ),
        );
      } else if (filter.operator == e.FilterOperator.isLessThanOrEqualTo) {
        query = QueryBuilder.apply(
          query,
          (query) => query.addFilterCondition(
            FilterGroup.or([
              FilterCondition.lessThan(
                property: filter.field as String,
                value: filter.value,
              ),
              FilterCondition.equalTo(
                property: filter.field as String,
                value: filter.value,
              ),
            ]),
          ),
        );
      } else if (filter.operator == e.FilterOperator.isGreaterThan) {
        query = QueryBuilder.apply(
          query,
          (query) => query.addFilterCondition(
            FilterCondition.greaterThan(
              property: filter.field as String,
              value: filter.value,
            ),
          ),
        );
      } else if (filter.operator == e.FilterOperator.isGreaterThanOrEqualTo) {
        query = QueryBuilder.apply(
          query,
          (query) => query.addFilterCondition(
            FilterGroup.or([
              FilterCondition.greaterThan(
                property: filter.field as String,
                value: filter.value,
              ),
              FilterCondition.equalTo(
                property: filter.field as String,
                value: filter.value,
              ),
            ]),
          ),
        );
      } else if (filter.operator == e.FilterOperator.arrayContains) {
        query = QueryBuilder.apply(
          query,
          (query) => query.addFilterCondition(
            FilterCondition.equalTo(
              property: filter.field as String,
              value: filter.value,
            ),
          ),
        );
      } else if (filter.operator == e.FilterOperator.arrayContainsAny) {
        final values = filter.value as List<Object?>;
        if (values.isEmpty) {
          // Empty list should match nothing
          throw UnimplementedError(
              'arrayContainsAny with empty list not supported');
        } else {
          var conditions = <FilterOperation>[];
          for (var value in values) {
            conditions.add(FilterCondition.equalTo(
              property: filter.field as String,
              value: value,
            ));
          }
          query = QueryBuilder.apply(
            query,
            (query) => query.addFilterCondition(
              FilterGroup.or(conditions),
            ),
          );
        }
      } else if (filter.operator == e.FilterOperator.whereIn) {
        final values = filter.value as List<Object?>;
        if (values.isEmpty) {
          // Empty list should match nothing
          throw UnimplementedError('whereIn with empty list not supported');
        } else {
          var conditions = <FilterOperation>[];
          for (var value in values) {
            conditions.add(FilterCondition.equalTo(
              property: filter.field as String,
              value: value,
            ));
          }
          query = QueryBuilder.apply(
            query,
            (query) => query.addFilterCondition(
              FilterGroup.or(conditions),
            ),
          );
        }
      } else if (filter.operator == e.FilterOperator.whereNotIn) {
        final values = filter.value as List<Object?>;
        if (values.isEmpty) {
          // No restriction when list is empty - all items match
        } else {
          var conditions = <FilterOperation>[];
          for (var value in values) {
            conditions.add(FilterCondition.equalTo(
              property: filter.field as String,
              value: value,
            ));
          }
          query = QueryBuilder.apply(
            query,
            (query) => query.addFilterCondition(
              FilterGroup.not(
                FilterGroup.or(conditions),
              ),
            ),
          );
        }
      } else if (filter.operator == e.FilterOperator.isNull) {
        if (filter.value == true) {
          query = QueryBuilder.apply(
            query,
            (query) => query.addFilterCondition(
              FilterCondition.isNull(
                property: filter.field as String,
              ),
            ),
          );
        } else {
          query = QueryBuilder.apply(
            query,
            (query) => query.addFilterCondition(
              FilterCondition.isNotNull(
                property: filter.field as String,
              ),
            ),
          );
        }
      }
    }

    for (var sort in _sorts) {
      query = QueryBuilder.apply(
        query,
        (query) => query.addSortBy(
          sort.field as String,
          sort.descending ? Sort.desc : Sort.asc,
        ),
      );
    }

    if (_startAfterId != null) {
      throw UnimplementedError();
    }

    if (_limitNum != null) {
      return query.limit(_limitNum);
    }

    return query;
  }

  @override
  Future<int> count({
    e.CountOptions? options,
  }) async {
    final query = await _buildQuery();
    if (query is QueryBuilder<IsarModel, IsarModel, QAfterLimit>) {
      final result = await query.count();
      return result;
    } else if (query is QueryBuilder<IsarModel, IsarModel, QWhere>) {
      final result = await query.count();
      return result;
    } else {
      throw UnsupportedError(
        'Query type ${query.runtimeType} is not supported for count',
      );
    }
  }

  @override
  Future<List<E>> findAll({
    e.FindAllOptions? options,
    TransactionContext? transaction,
  }) async {
    final query = await _buildQuery();
    if (query is QueryBuilder<IsarModel, IsarModel, QAfterLimit>) {
      final result = await query.findAll();
      final entities = result.map((e) => _repository.toEntity(e)).toList();
      _repository.notifyListComplete(entities);
      return entities;
    } else if (query is QueryBuilder<IsarModel, IsarModel, QWhere>) {
      final result = await query.findAll();
      final entities = result.map((e) => _repository.toEntity(e)).toList();
      _repository.notifyListComplete(entities);
      return entities;
    } else {
      throw UnsupportedError(
        'Query type ${query.runtimeType} is not supported for findAll',
      );
    }
  }

  @override
  Future<E?> findOne({
    e.FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    final result = await this.limit(1).findAll();
    if (result.isEmpty) {
      return null;
    }

    return result.firstOrNull;
  }

  @override
  List<e.RepositoryFilter> get filters => _filters;

  @override
  int? get limitNum => _limitNum;

  @override
  Stream<List<e.EntityChange<E>>> observeAll({
    e.ObserveAllOptions? options,
  }) {
    throw UnimplementedError();
  }

  @override
  List<e.RepositorySort> get sorts => _sorts;

  @override
  Id? get startAfterId => _startAfterId;
}
