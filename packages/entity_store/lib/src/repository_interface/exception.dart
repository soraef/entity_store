part of '../repository_interface.dart';

/// リポジトリ操作に関連する基本例外クラス
class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}

/// エンティティが見つからない場合の例外
class EntityNotFoundException extends RepositoryException {
  final dynamic id;
  final Type? entityType;

  EntityNotFoundException(this.id, {this.entityType})
      : super('エンティティが見つかりません: ${entityType != null ? entityType : ''}[$id]');
}

/// エンティティの保存に失敗した場合の例外
class EntitySaveException extends RepositoryException {
  final dynamic entity;

  EntitySaveException(this.entity, {String? reason})
      : super('エンティティの保存に失敗しました${reason != null ? ': $reason' : ''}');
}

/// エンティティの削除に失敗した場合の例外
class EntityDeleteException extends RepositoryException {
  final dynamic id;

  EntityDeleteException(this.id, {String? reason})
      : super('エンティティの削除に失敗しました[$id]${reason != null ? ': $reason' : ''}');
}

/// データソースアクセスに失敗した場合の例外
class DataSourceException extends RepositoryException {
  DataSourceException(String message) : super(message);
}

/// トランザクション操作に失敗した場合の例外
class TransactionException extends RepositoryException {
  TransactionException(String message) : super(message);
}

/// クエリ実行に失敗した場合の例外
class QueryException extends RepositoryException {
  QueryException(String message) : super(message);
}
