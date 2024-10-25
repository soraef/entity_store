// Entity操作に関連する基本イベントクラス
part of '../entity_store.dart';

abstract class EntityEvent<E extends Entity> {
  final E entity;
  EntityEvent(this.entity);

  Type get entityType => E;
}

// Entity追加イベント
class EntityCreatedEvent<E extends Entity> extends EntityEvent<E> {
  EntityCreatedEvent(super.entity);
}

// Entity変更イベント
class EntityUpdatedEvent<E extends Entity> extends EntityEvent<E> {
  EntityUpdatedEvent(super.entity);
}

// Entity削除イベント
class EntityDeletedEvent<E extends Entity> extends EntityEvent<E> {
  EntityDeletedEvent(super.entity);
}

abstract class EntityEventListener {
  EntityStoreController? controller;

  void setController(EntityStoreController controller) {
    this.controller = controller;
  }

  E? getById<E extends Entity>(String id) {
    return controller?.getById<E>(id);
  }

  void put<E extends Entity>(E entity) {
    controller?.put<E>(entity);
  }

  void delete<E extends Entity>(String id) {
    controller?.delete<E>(id);
  }

  bool shouldListenTo<E extends Entity>(EntityEvent<E> event);
  void handleEvent<E extends Entity>(EntityEvent<E> event);
}
