import 'package:entity_store/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RepositoryFilter', () {
    final object = <String, dynamic>{
      'name': 'Alice',
      'age': 30,
      'score': 85.5,
      'tags': ['admin', 'user'],
      'email': null,
    };

    test('isEqualTo matches equal value', () {
      final filter = RepositoryFilter('name', FilterOperator.isEqualTo, 'Alice');
      expect(filter.test(object), true);
    });

    test('isEqualTo rejects non-equal value', () {
      final filter = RepositoryFilter('name', FilterOperator.isEqualTo, 'Bob');
      expect(filter.test(object), false);
    });

    test('isNotEqualTo rejects equal value', () {
      final filter =
          RepositoryFilter('name', FilterOperator.isNotEqualTo, 'Alice');
      expect(filter.test(object), false);
    });

    test('isNotEqualTo matches non-equal value', () {
      final filter =
          RepositoryFilter('name', FilterOperator.isNotEqualTo, 'Bob');
      expect(filter.test(object), true);
    });

    test('isLessThan works correctly', () {
      final filter = RepositoryFilter('age', FilterOperator.isLessThan, 40);
      expect(filter.test(object), true);

      final filter2 = RepositoryFilter('age', FilterOperator.isLessThan, 20);
      expect(filter2.test(object), false);
    });

    test('isLessThanOrEqualTo works correctly', () {
      final filter =
          RepositoryFilter('age', FilterOperator.isLessThanOrEqualTo, 30);
      expect(filter.test(object), true);

      final filter2 =
          RepositoryFilter('age', FilterOperator.isLessThanOrEqualTo, 29);
      expect(filter2.test(object), false);
    });

    test('isGreaterThan works correctly', () {
      final filter = RepositoryFilter('age', FilterOperator.isGreaterThan, 20);
      expect(filter.test(object), true);

      final filter2 = RepositoryFilter('age', FilterOperator.isGreaterThan, 30);
      expect(filter2.test(object), false);
    });

    test('isGreaterThanOrEqualTo works correctly', () {
      final filter =
          RepositoryFilter('age', FilterOperator.isGreaterThanOrEqualTo, 30);
      expect(filter.test(object), true);

      final filter2 =
          RepositoryFilter('age', FilterOperator.isGreaterThanOrEqualTo, 31);
      expect(filter2.test(object), false);
    });

    test('arrayContains checks list membership', () {
      final filter =
          RepositoryFilter('tags', FilterOperator.arrayContains, 'admin');
      expect(filter.test(object), true);

      final filter2 =
          RepositoryFilter('tags', FilterOperator.arrayContains, 'guest');
      expect(filter2.test(object), false);
    });

    test('arrayContainsAny checks any match in list', () {
      final filter = RepositoryFilter(
          'tags', FilterOperator.arrayContainsAny, ['admin', 'guest']);
      expect(filter.test(object), true);

      final filter2 = RepositoryFilter(
          'tags', FilterOperator.arrayContainsAny, ['guest', 'moderator']);
      expect(filter2.test(object), false);
    });

    test('whereIn checks value in list', () {
      final filter = RepositoryFilter(
          'name', FilterOperator.whereIn, ['Alice', 'Bob']);
      expect(filter.test(object), true);

      final filter2 = RepositoryFilter(
          'name', FilterOperator.whereIn, ['Bob', 'Charlie']);
      expect(filter2.test(object), false);
    });

    test('whereNotIn checks value not in list', () {
      final filter = RepositoryFilter(
          'name', FilterOperator.whereNotIn, ['Bob', 'Charlie']);
      expect(filter.test(object), true);

      final filter2 = RepositoryFilter(
          'name', FilterOperator.whereNotIn, ['Alice', 'Bob']);
      expect(filter2.test(object), false);
    });

    test('isNull checks for null value', () {
      final filter = RepositoryFilter('email', FilterOperator.isNull, true);
      expect(filter.test(object), true);

      final filter2 = RepositoryFilter('name', FilterOperator.isNull, true);
      expect(filter2.test(object), false);
    });
  });
}
