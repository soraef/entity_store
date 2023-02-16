part of "../store.dart";

abstract class Entity<Id> {
  Id get id;
}

abstract class SingletonEntity extends Entity<CommonId> {
  @override
  CommonId get id => SingletonEntity.getId();
  static CommonId getId() => CommonId.singleton();
}

class EntityJsonConverter<Id, E extends Entity<Id>> {
  final E Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(E) toJson;

  EntityJsonConverter({
    required this.fromJson,
    required this.toJson,
  });
}
