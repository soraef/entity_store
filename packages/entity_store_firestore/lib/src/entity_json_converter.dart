import 'package:entity_store/entity_store.dart';

class EntityJsonConverter<Id, E extends Entity<Id>> {
  final E Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(E) toJson;

  EntityJsonConverter({
    required this.fromJson,
    required this.toJson,
  });
}

abstract class CollectionType<Id, E extends Entity<Id>> {
  const CollectionType({
    required this.collectionName,
    required this.fromJson,
    required this.toJson,
    required this.idToString,
  });
  final String collectionName;
  final E Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(E) toJson;
  final String Function(Id id) idToString;

  factory CollectionType.general({
    required String collectionName,
    required String Function(Id id) idToString,
    required E Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(E) toJson,
  }) {
    return GeneralCollection(
      fromJson: fromJson,
      toJson: toJson,
      idToString: idToString,
      collectionName: collectionName,
    );
  }

  factory CollectionType.bucketing({
    required String collectionName,
    required String bucketingFieldName,
    required String Function(E entity) bucketIdToString,
    required String Function(Id id) idToString,
    required E Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(E entity) toJson,
    required Map<String, dynamic> Function(E entity) toDocumentFields,
  }) {
    return BucketingCollection(
      fromJson: fromJson,
      toJson: toJson,
      idToString: idToString,
      bucketIdToString: bucketIdToString,
      bucketingFieldName: bucketingFieldName,
      collectionName: collectionName,
      toDocumentFields: toDocumentFields,
    );
  }

  bool get isGeneral => this is GeneralCollection<Id, E>;
  bool get isBucketing => this is BucketingCollection<Id, E>;
  GeneralCollection<Id, E> get general => this as GeneralCollection<Id, E>;
  BucketingCollection<Id, E> get bucketing =>
      this as BucketingCollection<Id, E>;

  Type get type => E;
  Type get idType => Id;
}

class GeneralCollection<Id, E extends Entity<Id>>
    extends CollectionType<Id, E> {
  const GeneralCollection({
    required super.collectionName,
    required super.fromJson,
    required super.toJson,
    required super.idToString,
  });
}

class BucketingCollection<Id, E extends Entity<Id>>
    extends CollectionType<Id, E> {
  final String bucketingFieldName;
  final String Function(E id) bucketIdToString;
  final Map<String, dynamic> Function(E) toDocumentFields;

  const BucketingCollection({
    required super.collectionName,
    required super.fromJson,
    required super.toJson,
    required super.idToString,
    required this.bucketingFieldName,
    required this.bucketIdToString,
    required this.toDocumentFields,
  });
}
