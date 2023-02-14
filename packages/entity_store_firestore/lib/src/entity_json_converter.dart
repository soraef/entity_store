import 'package:entity_store/entity_store.dart';

class EntityJsonConverter<Id, E extends Entity<Id>> {
  final E Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(E) toJson;

  EntityJsonConverter({
    required this.fromJson,
    required this.toJson,
  });
}

class CollectionType<Id, E extends Entity<Id>> {
  final E Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(E) toJson;
  final String Function(Id id) idToString;
  final String collectionName;

  CollectionType({
    required this.fromJson,
    required this.toJson,
    required this.idToString,
    required this.collectionName,
  });

  Type get type => E;
  Type get idType => Id;
}
