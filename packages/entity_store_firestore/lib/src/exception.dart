abstract class FirestoreRepoFailure implements Exception {}

class JsonConverterFailure extends FirestoreRepoFailure {
  final Type entityType;
  final String method;
  final dynamic fetched;
  final Exception? exception;

  JsonConverterFailure({
    required this.entityType,
    required this.method,
    required this.fetched,
    required this.exception,
  });
}

class FirestoreRequestFailure extends FirestoreRepoFailure {
  final Type entityType;
  final String method;
  final String code;
  final String? message;
  final Exception? exception;

  FirestoreRequestFailure({
    required this.entityType,
    required this.code,
    required this.method,
    required this.message,
    required this.exception,
  });
}
