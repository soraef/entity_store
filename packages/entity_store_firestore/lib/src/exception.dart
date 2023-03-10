abstract class FirestoreRepositoryFailure implements Exception {}

class JsonConverterFailure extends FirestoreRepositoryFailure {
  final Type entityType;
  final dynamic fetched;
  final Exception? exception;

  JsonConverterFailure({
    required this.entityType,
    required this.fetched,
    required this.exception,
  });
}

class FirestoreRequestFailure extends FirestoreRepositoryFailure {
  final Type entityType;
  final String code;
  final String? message;
  final Exception? exception;

  FirestoreRequestFailure({
    required this.entityType,
    required this.code,
    required this.message,
    required this.exception,
  });
}
