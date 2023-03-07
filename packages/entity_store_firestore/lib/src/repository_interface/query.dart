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

class Filter {
  final Object field;
  final FilterOperator operator;
  final dynamic value;

  Filter(this.field, this.operator, this.value);

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

class Sort {
  final Object field;
  final bool descending;

  Sort(this.field, this.descending);
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

  IRepositoryQuery<Id, E> startAfterId(Id id);

  bool test(Map<String, dynamic> object);

  Future<Result<List<E>, Exception>> findAll();
}
