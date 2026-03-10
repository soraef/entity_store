part of '../repository_interface.dart';

/// Base exception class for repository operations.
class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}

/// Exception thrown when an entity is not found.
class EntityNotFoundException extends RepositoryException {
  final dynamic id;
  final Type? entityType;

  EntityNotFoundException(this.id, {this.entityType})
      : super(
            'Entity not found: ${entityType != null ? '$entityType' : ''}[$id]');
}

/// Exception thrown when saving an entity fails.
class EntitySaveException extends RepositoryException {
  final dynamic entity;

  EntitySaveException(this.entity, {String? reason})
      : super('Failed to save entity${reason != null ? ': $reason' : ''}');
}

/// Exception thrown when deleting an entity fails.
class EntityDeleteException extends RepositoryException {
  final dynamic id;

  EntityDeleteException(this.id, {String? reason})
      : super(
            'Failed to delete entity[$id]${reason != null ? ': $reason' : ''}');
}

/// Exception thrown when a data source operation fails.
class DataSourceException extends RepositoryException {
  DataSourceException(String message) : super(message);
}

/// Exception thrown when a transaction operation fails.
class TransactionException extends RepositoryException {
  TransactionException(String message) : super(message);
}

/// Exception thrown when a query execution fails.
class QueryException extends RepositoryException {
  QueryException(String message) : super(message);
}
