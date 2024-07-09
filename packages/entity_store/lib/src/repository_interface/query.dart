part of '../repository_interface.dart';

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

class RepositoryFilter {
  final Object field;
  final FilterOperator operator;
  final dynamic value;

  RepositoryFilter(this.field, this.operator, this.value);

  bool test(Map<String, dynamic> object) {
    switch (operator) {
      case FilterOperator.isEqualTo:
        return object[field] == value;
      case FilterOperator.isNotEqualTo:
        return object[field] != value;
      case FilterOperator.isLessThan:
        return object[field] < value;
      case FilterOperator.isLessThanOrEqualTo:
        return object[field] <= value;
      case FilterOperator.isGreaterThan:
        return object[field] > value;
      case FilterOperator.isGreaterThanOrEqualTo:
        return object[field] >= value;
      case FilterOperator.arrayContains:
        return (object[field] as List).contains(value);
      case FilterOperator.arrayContainsAny:
        return (object[field] as List).any((e) => (value as List).contains(e));
      case FilterOperator.whereIn:
        return (value as List).contains(object[field]);
      case FilterOperator.whereNotIn:
        return (value as List).every((e) => e != object[field]);
      case FilterOperator.isNull:
        return object[field] == null;
    }
  }
}

class RepositorySort {
  final Object field;
  final bool descending;

  RepositorySort(this.field, this.descending);
}

abstract class IRepositoryQuery<Id, E extends Entity<Id>> {
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
  });

  IRepositoryQuery<Id, E> orderBy(Object field, {bool descending = false});

  IRepositoryQuery<Id, E> limit(int count);

  IRepositoryQuery<Id, E> startAfter(Id id);

  bool test(Map<String, dynamic> object);

  Future<Result<List<E>, Exception>> findAll({
    FindAllOptions? options,
  });

  Future<Result<E?, Exception>> findOne({
    FindOneOptions? options,
  });

  Stream<Result<List<EntityChange<E>>, Exception>> observeAll({
    ObserveAllOptions? options,
  });

  Future<Result<int, Exception>> count();

  List<RepositoryFilter> get filters;
  List<RepositorySort> get sorts;
  int? get limitNum;
  Id? get startAfterId;

  static List<Map<String, dynamic>> findEntities<E extends Entity<Id>, Id>(
    List<Map<String, dynamic>> objects,
    IRepositoryQuery<Id, E> query,
  ) {
    bool test(Map<String, dynamic> object) {
      return query.filters.map((e) => e.test(object)).every((e) => e);
    }

    var entites = objects.where(test);

    if (query.startAfterId != null) {
      entites = entites.skipWhile((e) => e['id'] != query.startAfterId);
    }

    if (query.limitNum != null) {
      entites = entites.take(query.limitNum!);
    }

    if (query.sorts.isNotEmpty) {
      final sort = query.sorts.first;
      entites = entites.toList()
        ..sort((a, b) {
          if (sort.descending) {
            return b[sort.field]!.compareTo(a[sort.field]);
          } else {
            return a[sort.field]!.compareTo(b[sort.field]);
          }
        });
    }

    return entites.toList();
  }
}

class EntityChange<E> {
  final E entity;
  final ChangeType changeType;

  EntityChange({
    required this.entity,
    required this.changeType,
  });
}

enum ChangeType {
  created,
  updated,
  deleted,
}
