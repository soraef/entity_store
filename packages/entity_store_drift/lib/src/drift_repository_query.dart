import 'package:drift/drift.dart' hide isNull;
import 'package:entity_store/entity_store.dart';

import 'drift_repository.dart';

class EntityStoreDriftRepositoryQuery<Id, E extends Entity<Id>>
    implements IRepositoryQuery<Id, E> {
  final EntityStoreDriftRepository<Id, E> repository;

  final List<RepositoryFilter> _filters = [];
  final List<RepositorySort> _sorts = [];
  int? _limit;
  Id? _startAfterId;

  EntityStoreDriftRepositoryQuery({
    required this.repository,
  });

  @override
  List<RepositoryFilter> get filters => _filters;

  @override
  List<RepositorySort> get sorts => _sorts;

  @override
  int? get limitNum => _limit;

  @override
  Id? get startAfterId => _startAfterId;

  @override
  IRepositoryQuery<Id, E> where(
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
    if (isEqualTo != null) {
      _filters.add(RepositoryFilter(field, FilterOperator.isEqualTo, isEqualTo));
    }
    if (isNotEqualTo != null) {
      _filters.add(
        RepositoryFilter(field, FilterOperator.isNotEqualTo, isNotEqualTo),
      );
    }
    if (isLessThan != null) {
      _filters.add(RepositoryFilter(field, FilterOperator.isLessThan, isLessThan));
    }
    if (isLessThanOrEqualTo != null) {
      _filters.add(
        RepositoryFilter(
          field,
          FilterOperator.isLessThanOrEqualTo,
          isLessThanOrEqualTo,
        ),
      );
    }
    if (isGreaterThan != null) {
      _filters.add(
        RepositoryFilter(field, FilterOperator.isGreaterThan, isGreaterThan),
      );
    }
    if (isGreaterThanOrEqualTo != null) {
      _filters.add(
        RepositoryFilter(
          field,
          FilterOperator.isGreaterThanOrEqualTo,
          isGreaterThanOrEqualTo,
        ),
      );
    }
    if (arrayContains != null) {
      _filters.add(
        RepositoryFilter(field, FilterOperator.arrayContains, arrayContains),
      );
    }
    if (arrayContainsAny != null) {
      _filters.add(
        RepositoryFilter(
          field,
          FilterOperator.arrayContainsAny,
          arrayContainsAny,
        ),
      );
    }
    if (whereIn != null) {
      _filters.add(RepositoryFilter(field, FilterOperator.whereIn, whereIn));
    }
    if (whereNotIn != null) {
      _filters.add(
        RepositoryFilter(field, FilterOperator.whereNotIn, whereNotIn),
      );
    }
    if (isNull != null) {
      _filters.add(RepositoryFilter(field, FilterOperator.isNull, isNull));
    }
    return this;
  }

  @override
  IRepositoryQuery<Id, E> orderBy(Object field, {bool descending = false}) {
    _sorts.add(RepositorySort(field, descending));
    return this;
  }

  @override
  IRepositoryQuery<Id, E> limit(int count) {
    _limit = count;
    return this;
  }

  @override
  IRepositoryQuery<Id, E> startAfter(Id id) {
    _startAfterId = id;
    return this;
  }

  @override
  bool test(Map<String, dynamic> object) {
    return _filters.every((filter) => filter.test(object));
  }

  @override
  Future<List<E>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);
      final storeObjects = repository.controller
          .getAll<Id, E>()
          .map(repository.toJson)
          .toList();
      final storeEntities = IRepositoryQuery.findEntities<E, Id>(storeObjects, this)
          .map(repository.fromJson)
          .toList();

      if (fetchPolicy == FetchPolicy.storeOnly) {
        return storeEntities;
      }
      if (fetchPolicy == FetchPolicy.storeFirst && storeEntities.isNotEmpty) {
        return storeEntities;
      }

      final query = repository.buildBaseQuery();

      for (final filter in _filters) {
        final column = repository.columnFor(filter.field.toString());
        final expr = _buildFilterExpression(column, filter);
        if (expr != null) {
          query.where(expr);
        }
      }

      if (_sorts.isNotEmpty) {
        query.orderBy(
          _sorts.map((sort) {
            final column = repository.columnFor(sort.field.toString());
            return OrderingTerm(
              expression: column,
              mode: sort.descending ? OrderingMode.desc : OrderingMode.asc,
            );
          }).toList(),
        );
      }

      if (_startAfterId != null) {
        final column = repository.columnFor('id');
        final startAfterExpr =
            _buildFilterExpression(
              column,
              RepositoryFilter(
                'id',
                FilterOperator.isGreaterThan,
                repository.idToString(_startAfterId as Id),
              ),
            );
        if (startAfterExpr != null) {
          query.where(startAfterExpr);
        }
      }

      if (_limit != null) {
        query.limit(_limit!);
      }

      final rows = await query.get();
      final entities = rows.map(repository.fromRow).toList();
      repository.notifyListComplete(entities);
      return entities;
    } catch (e) {
      throw QueryException('Failed to find all entities: $e');
    }
  }

  @override
  Future<E?> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    final originalLimit = _limit;
    _limit = 1;
    try {
      final entities = await findAll(options: null, transaction: transaction);
      if (entities.isEmpty) {
        return null;
      }
      final entity = entities.first;
      repository.notifyGetComplete(entity);
      return entity;
    } finally {
      _limit = originalLimit;
    }
  }

  @override
  Future<int> count({
    CountOptions? options,
  }) async {
    final results = await findAll(options: null);
    return results.length;
  }

  @override
  Stream<List<EntityChange<E>>> observeAll({
    ObserveAllOptions? options,
  }) {
    return repository.controller.eventStream
        .where((event) => event is PersistenceEvent<Id, E>)
        .asyncMap((_) async {
      final entities = await findAll(options: null);
      return entities
          .map((entity) => EntityChange(entity: entity, changeType: ChangeType.updated))
          .toList();
    });
  }

  Expression<bool>? _buildFilterExpression(
    GeneratedColumn column,
    RepositoryFilter filter,
  ) {
    return switch (filter.operator) {
      FilterOperator.isEqualTo => column.equals(filter.value),
      FilterOperator.isNotEqualTo => column.equals(filter.value).not(),
      FilterOperator.isLessThan => _compareExpression(column, filter.value, '<'),
      FilterOperator.isLessThanOrEqualTo =>
        _compareExpression(column, filter.value, '<='),
      FilterOperator.isGreaterThan =>
        _compareExpression(column, filter.value, '>'),
      FilterOperator.isGreaterThanOrEqualTo =>
        _compareExpression(column, filter.value, '>='),
      FilterOperator.isNull => filter.value == true
          ? column.isNull()
          : column.isNotNull(),
      FilterOperator.whereIn => _isInExpression(column, filter.value as List, false),
      FilterOperator.whereNotIn => _isInExpression(column, filter.value as List, true),
      _ => null,
    };
  }

  Expression<bool> _compareExpression(
    GeneratedColumn column,
    dynamic value,
    String op,
  ) {
    if (column is GeneratedColumn<int>) {
      final typed = value as int;
      return switch (op) {
        '<' => column.isSmallerThanValue(typed),
        '<=' => column.isSmallerOrEqualValue(typed),
        '>' => column.isBiggerThanValue(typed),
        '>=' => column.isBiggerOrEqualValue(typed),
        _ => throw ArgumentError('Unknown op: $op'),
      };
    }
    if (column is GeneratedColumn<String>) {
      final typed = value as String;
      return switch (op) {
        '<' => column.isSmallerThanValue(typed),
        '<=' => column.isSmallerOrEqualValue(typed),
        '>' => column.isBiggerThanValue(typed),
        '>=' => column.isBiggerOrEqualValue(typed),
        _ => throw ArgumentError('Unknown op: $op'),
      };
    }
    if (column is GeneratedColumn<double>) {
      final typed = (value as num).toDouble();
      return switch (op) {
        '<' => column.isSmallerThanValue(typed),
        '<=' => column.isSmallerOrEqualValue(typed),
        '>' => column.isBiggerThanValue(typed),
        '>=' => column.isBiggerOrEqualValue(typed),
        _ => throw ArgumentError('Unknown op: $op'),
      };
    }
    if (column is GeneratedColumn<DateTime>) {
      final typed = value as DateTime;
      return switch (op) {
        '<' => column.isSmallerThanValue(typed),
        '<=' => column.isSmallerOrEqualValue(typed),
        '>' => column.isBiggerThanValue(typed),
        '>=' => column.isBiggerOrEqualValue(typed),
        _ => throw ArgumentError('Unknown op: $op'),
      };
    }
    throw ArgumentError('Unsupported column type for comparison: ${column.runtimeType}');
  }

  Expression<bool> _isInExpression(
    GeneratedColumn column,
    List<dynamic> values,
    bool negate,
  ) {
    if (column is GeneratedColumn<String>) {
      final typed = values.cast<String>();
      return negate ? column.isNotIn(typed) : column.isIn(typed);
    }
    if (column is GeneratedColumn<int>) {
      final typed = values.cast<int>();
      return negate ? column.isNotIn(typed) : column.isIn(typed);
    }
    if (column is GeneratedColumn<double>) {
      final typed = values.map((value) => (value as num).toDouble()).toList();
      return negate ? column.isNotIn(typed) : column.isIn(typed);
    }
    if (column is GeneratedColumn<DateTime>) {
      final typed = values.cast<DateTime>();
      return negate ? column.isNotIn(typed) : column.isIn(typed);
    }
    throw ArgumentError('Unsupported column type for isIn: ${column.runtimeType}');
  }
}
