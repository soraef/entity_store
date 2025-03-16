import 'package:entity_store/entity_store.dart';
import 'package:sembast/sembast.dart';
import 'package:type_result/type_result.dart';

import 'repository.dart';

class SembastRepositoryQuery<Id, E extends Entity<Id>>
    implements IRepositoryQuery<Id, E> {
  final SembastRepository<Id, E> repository;
  final Database db;
  final StoreRef<String, Map<String, Object?>> store;
  final Map<String, dynamic> Function(E entity) toJson;
  final E Function(Map<String, dynamic> json) fromJson;

  final List<Filter> _filters = [];
  final List<SortOrder> _sorts = [];
  int? _limit;
  Id? _startAfterId;

  SembastRepositoryQuery({
    required this.repository,
    required this.db,
    required this.store,
    required this.toJson,
    required this.fromJson,
  });

  @override
  List<RepositoryFilter> get filters => [];

  @override
  int? get limitNum => _limit;

  @override
  List<RepositorySort> get sorts => [];

  @override
  Id? get startAfterId => _startAfterId;

  @override
  IRepositoryQuery<Id, E> limit(int limit) {
    _limit = limit;
    return this;
  }

  @override
  IRepositoryQuery<Id, E> orderBy(Object field, {bool descending = false}) {
    _sorts.add(SortOrder(field.toString(), !descending));
    return this;
  }

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
    final fieldStr = field.toString();
    if (isEqualTo != null) {
      _filters.add(Filter.equals(fieldStr, isEqualTo));
    }
    if (isNotEqualTo != null) {
      _filters.add(Filter.notEquals(fieldStr, isNotEqualTo));
    }
    if (isLessThan != null) {
      _filters.add(Filter.lessThan(fieldStr, isLessThan));
    }
    if (isLessThanOrEqualTo != null) {
      _filters.add(Filter.lessThanOrEquals(fieldStr, isLessThanOrEqualTo));
    }
    if (isGreaterThan != null) {
      _filters.add(Filter.greaterThan(fieldStr, isGreaterThan));
    }
    if (isGreaterThanOrEqualTo != null) {
      _filters.add(
        Filter.greaterThanOrEquals(fieldStr, isGreaterThanOrEqualTo),
      );
    }
    if (isNull != null) {
      if (isNull) {
        _filters.add(Filter.isNull(fieldStr));
      } else {
        _filters.add(Filter.notNull(fieldStr));
      }
    }
    return this;
  }

  Finder _createFinder() {
    return Finder(
      filter: _filters.isEmpty ? null : Filter.and(_filters),
      sortOrders: _sorts,
      limit: _limit,
    );
  }

  Filter? _createFilter() {
    return _filters.isEmpty ? null : Filter.and(_filters);
  }

  @override
  Future<Result<List<E>, Exception>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

      final objects = repository.controller
          .getAll<Id, E>()
          .map((e) => repository.toJson(e))
          .toList();
      var storeEntities = IRepositoryQuery.findEntities(objects, this)
          .map((e) => repository.fromJson(e))
          .toList();

      if (fetchPolicy == FetchPolicy.storeOnly) {
        return Result.success(storeEntities);
      }

      if (fetchPolicy == FetchPolicy.storeFirst && storeEntities.isNotEmpty) {
        return Result.success(storeEntities);
      }

      final finder = _createFinder();
      final records = await store.find(db, finder: finder);
      var entities = records
          .map((r) => fromJson(Map<String, dynamic>.from(r.value)))
          .toList();

      repository.notifyListComplete(entities);
      return Result.success(entities);
    } catch (e) {
      return Result.failure(Exception('Failed to find all entities: $e'));
    }
  }

  @override
  Future<Result<E?, Exception>> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final finder = _createFinder();
      final record = await store.findFirst(db, finder: finder);
      if (record == null) {
        return Result.success(null);
      }

      final entity = fromJson(Map<String, dynamic>.from(record.value));
      return Result.success(entity);
    } catch (e) {
      return Result.failure(Exception('Failed to find one entity: $e'));
    }
  }

  @override
  Future<Result<int, Exception>> count({CountOptions? options}) async {
    try {
      final count = await store.count(db, filter: _createFilter());
      return Result.success(count);
    } catch (e) {
      return Result.failure(Exception('Failed to count entities: $e'));
    }
  }

  @override
  Stream<Result<List<EntityChange<E>>, Exception>> observeAll({
    ObserveAllOptions? options,
  }) {
    final finder = _createFinder();
    return store.query(finder: finder).onSnapshots(db).map((snapshots) {
      try {
        final entities = snapshots
            .map(
              (s) => EntityChange(
                entity: fromJson(Map<String, dynamic>.from(s.value)),
                changeType: ChangeType.updated,
              ),
            )
            .toList();
        return Result.success(entities);
      } catch (e) {
        return Result.failure(Exception('Failed to observe all entities: $e'));
      }
    });
  }

  @override
  IRepositoryQuery<Id, E> startAfter(Id id) {
    return this;
  }

  @override
  bool test(Map<String, dynamic> data) {
    return filters.map((e) => e.test(data)).every((e) => e);
  }
}
