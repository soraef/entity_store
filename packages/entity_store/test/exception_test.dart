import 'package:entity_store/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RepositoryException', () {
    test('toString includes message', () {
      final ex = RepositoryException('something failed');
      expect(ex.toString(), 'RepositoryException: something failed');
    });

    test('implements Exception', () {
      expect(RepositoryException('test'), isA<Exception>());
    });
  });

  group('EntityNotFoundException', () {
    test('message includes id', () {
      final ex = EntityNotFoundException('123');
      expect(ex.toString(), contains('123'));
    });

    test('message includes entity type when provided', () {
      final ex = EntityNotFoundException('123', entityType: String);
      expect(ex.toString(), contains('String'));
      expect(ex.toString(), contains('123'));
    });

    test('inherits from RepositoryException', () {
      expect(EntityNotFoundException('1'), isA<RepositoryException>());
    });
  });

  group('EntitySaveException', () {
    test('message without reason', () {
      final ex = EntitySaveException('entity');
      expect(ex.toString(), contains('Failed to save entity'));
    });

    test('message with reason', () {
      final ex = EntitySaveException('entity', reason: 'network error');
      expect(ex.toString(), contains('network error'));
    });
  });

  group('EntityDeleteException', () {
    test('message includes id', () {
      final ex = EntityDeleteException('123');
      expect(ex.toString(), contains('123'));
    });

    test('message with reason', () {
      final ex = EntityDeleteException('123', reason: 'not found');
      expect(ex.toString(), contains('not found'));
    });
  });

  group('DataSourceException', () {
    test('preserves message', () {
      final ex = DataSourceException('connection failed');
      expect(ex.toString(), contains('connection failed'));
    });
  });

  group('TransactionException', () {
    test('preserves message', () {
      final ex = TransactionException('rollback failed');
      expect(ex.toString(), contains('rollback failed'));
    });
  });

  group('QueryException', () {
    test('preserves message', () {
      final ex = QueryException('invalid query');
      expect(ex.toString(), contains('invalid query'));
    });
  });
}
