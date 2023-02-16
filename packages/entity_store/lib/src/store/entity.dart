part of "../store.dart";

// import 'id.dart';

abstract class Entity<Id> {
  Id get id;
}

abstract class SingletonEntity extends Entity<CommonId> {
  @override
  CommonId get id => SingletonEntity.getId();
  static CommonId getId() => CommonId.singleton();
}
