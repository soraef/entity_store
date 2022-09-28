abstract class Entity<Id> {
  Id get id;
}

/// Entityのプロパティの一部を持つEntityクラスをPartialEntityと呼ぶ
/// PartialEntityはEntityを更新するためのupdateメソッドを持つ
abstract class PartialEntity<Id, E extends Entity<Id>> extends Entity<Id> {
  E update(E old);
  E? create();
  Map<String, dynamic> toJson();
  bool get canCreate => create() != null;
}

mixin MargeablePartialEntity<Id, E extends Entity<Id>> implements Entity<Id> {
  E merge(PartialEntity<Id, E> partialEntity) {
    return partialEntity.update(this as E);
  }
}

abstract class GroupEntity<EntityId, Id, E extends Entity<Id>>
    extends Entity<EntityId> {
  Map<Id, E> get entities;
}
