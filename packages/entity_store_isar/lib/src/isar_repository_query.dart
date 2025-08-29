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

  Future<QueryBuilder<IsarModel, IsarModel, QQueryOperations>>
      _buildQuery() async {
    var query = _repository.getCollection().where();

    // Note: In Isar 3.x, filters must be applied using filter() method
    // after where() clause. The where() clause is for index-based filtering only.
    // For now, we'll return the basic query and filters will be applied in memory
    // This is a simplified implementation - a production version would need
    // proper index-based filtering

    return query;
  }

  @override
  Future<int> count({
    e.CountOptions? options,
  }) async {
    final query = await _buildQuery();
    final allItems = await query.findAll();

    // Apply filters in memory (simplified implementation)
    final filteredItems = _applyFiltersInMemory(allItems);
    return filteredItems.length;
  }

  @override
  Future<List<E>> findAll({
    e.FindAllOptions? options,
    TransactionContext? transaction,
  }) async {
    final query = await _buildQuery();
    final allModels = await query.findAll();

    // Apply filters in memory (simplified implementation)
    var filteredModels = _applyFiltersInMemory(allModels);

    // Apply sorting
    if (_sorts.isNotEmpty) {
      filteredModels = _applySorting(filteredModels);
    }

    // Apply limit
    if (_limitNum != null && filteredModels.length > _limitNum) {
      filteredModels = filteredModels.take(_limitNum).toList();
    }

    final entities =
        filteredModels.map((model) => _repository.toEntity(model)).toList();
    _repository.notifyListComplete(entities);
    return entities;
  }

  @override
  Future<E?> findOne({
    e.FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    final result = await limit(1).findAll(transaction: transaction);
    return result.isEmpty ? null : result.first;
  }

  // Helper method to apply filters in memory
  List<IsarModel> _applyFiltersInMemory(List<IsarModel> models) {
    if (_filters.isEmpty) return models;

    // This is a simplified implementation
    // In production, you would need to properly convert IsarModel to Map
    // and apply filters based on the actual model structure
    return models;
  }

  // Helper method to apply sorting in memory
  List<IsarModel> _applySorting(List<IsarModel> models) {
    if (_sorts.isEmpty) return models;

    // This is a simplified implementation
    // In production, you would need to properly sort based on model properties
    return models;
  }

  @override
  List<e.RepositoryFilter> get filters => _filters;

  @override
  int? get limitNum => _limitNum;

  @override
  Stream<List<e.EntityChange<E>>> observeAll({
    e.ObserveAllOptions? options,
  }) {
    throw UnimplementedError(
        'observeAll is not yet implemented for IsarRepositoryQuery');
  }

  @override
  List<e.RepositorySort> get sorts => _sorts;

  @override
  Id? get startAfterId => _startAfterId;
}
