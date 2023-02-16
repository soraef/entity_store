part of "../store.dart";

abstract class StoreEventHandler {
  void handleEvent<Id, E extends Entity<Id>>(StoreEvent<Id, E> event);
  bool shouldListenTo<Id, E extends Entity<Id>>(StoreEvent<Id, E> event);
}

abstract class StoreEvent<Id, E extends Entity<Id>> {
  const StoreEvent({
    required this.eventTime,
  });

  Type get entityType => E;
  Type get idType => Id;
  final DateTime eventTime;

  void apply(StoreEventHandler handler) {
    if (handler.shouldListenTo<Id, E>(this)) {
      handler.handleEvent<Id, E>(this);
    }
  }
}

class GetEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final Id id;
  final E? entity;
  GetEvent({
    required this.id,
    required this.entity,
    required super.eventTime,
  }) : assert(entity == null || id == entity.id);

  factory GetEvent.now(Id id, E? entity) {
    return GetEvent(
      id: id,
      entity: entity,
      eventTime: DateTime.now(),
    );
  }
}

class ListEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final List<E> entities;
  const ListEvent({
    required this.entities,
    required super.eventTime,
  });

  factory ListEvent.now(List<E> entities) {
    return ListEvent(
      entities: entities,
      eventTime: DateTime.now(),
    );
  }
}

class SaveEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final E entity;
  const SaveEvent({
    required this.entity,
    required super.eventTime,
  });

  factory SaveEvent.now(E entity) {
    return SaveEvent(
      entity: entity,
      eventTime: DateTime.now(),
    );
  }
}

class DeleteEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final Id entityId;
  const DeleteEvent({
    required this.entityId,
    required super.eventTime,
  });

  factory DeleteEvent.now(Id entityId) {
    return DeleteEvent(
      entityId: entityId,
      eventTime: DateTime.now(),
    );
  }
}
