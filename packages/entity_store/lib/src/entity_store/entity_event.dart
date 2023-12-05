// Entity操作に関連する基本イベントクラス
part of '../entity_store.dart';

abstract class EntityEvent<Id, E extends Entity<Id>> {
  final E entity;
  EntityEvent(this.entity);

  Type get entityType => E;
}

// Entity追加イベント
class EntityCreatedEvent<Id, E extends Entity<Id>> extends EntityEvent<Id, E> {
  EntityCreatedEvent(super.entity);
}

// Entity変更イベント
class EntityUpdatedEvent<Id, E extends Entity<Id>> extends EntityEvent<Id, E> {
  EntityUpdatedEvent(super.entity);
}

// Entity削除イベント
class EntityDeletedEvent<Id, E extends Entity<Id>> extends EntityEvent<Id, E> {
  EntityDeletedEvent(super.entity);
}

abstract class EntityEventListener {
  EntityStoreController? controller;

  void setController(EntityStoreController controller) {
    this.controller = controller;
  }

  E? getById<Id, E extends Entity<Id>>(Id id) {
    return controller?.getById<Id, E>(id);
  }

  void put<Id, E extends Entity<Id>>(E entity) {
    controller?.put<Id, E>(entity);
  }

  void delete<Id, E extends Entity<Id>>(Id id) {
    controller?.delete<Id, E>(id);
  }

  bool shouldListenTo<Id, E extends Entity<Id>>(EntityEvent<Id, E> event);
  void handleEvent<Id, E extends Entity<Id>>(EntityEvent<Id, E> event);
}
