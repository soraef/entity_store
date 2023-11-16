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

  @override
  String toString() {
    return 'JsonConverterFailure{entityType: $entityType, fetched: $fetched, exception: $exception}';
  }
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

  @override
  String toString() {
    return 'FirestoreRequestFailure{entityType: $entityType, code: $code, message: $message, exception: $exception}';
  }
}
