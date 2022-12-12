abstract class FirestoreRepoException implements Exception {}

class JsonConverterException extends FirestoreRepoException {
  final Type entityType;
  final String method;
  final dynamic fetched;

  JsonConverterException({
    required this.entityType,
    required this.method,
    required this.fetched,
  });
}

class FirestoreRequestException extends FirestoreRepoException {
  final Type entityType;
  final String code;
  final String method;

  FirestoreRequestException({
    required this.entityType,
    required this.code,
    required this.method,
  });
}
