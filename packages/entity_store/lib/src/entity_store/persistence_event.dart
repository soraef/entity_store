part of '../entity_store.dart';

abstract class IPersistenceEventHandler {
  void handleEvent<E extends Entity>(PersistenceEvent<E> event);
  bool shouldListenTo<E extends Entity>(PersistenceEvent<E> event);
}

abstract class PersistenceEvent<E extends Entity> {
  const PersistenceEvent({
    required this.eventTime,
  });

  Type get entityType => E;
  Type get idType => String;
  final DateTime eventTime;

  void apply(IPersistenceEventHandler handler) {
    if (handler.shouldListenTo<E>(this)) {
      handler.handleEvent<E>(this);
    }
  }
}

class GetEvent<E extends Entity> extends PersistenceEvent<E> {
  final String id;
  final E? entity;
  GetEvent({
    required this.id,
    required this.entity,
    required super.eventTime,
  }) : assert(entity == null || id == entity.id);

  factory GetEvent.now(String id, E? entity) {
    return GetEvent(
      id: id,
      entity: entity,
      eventTime: DateTime.now(),
    );
  }
}

class ListEvent<E extends Entity> extends PersistenceEvent<E> {
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

class SaveEvent<E extends Entity> extends PersistenceEvent<E> {
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

class DeleteEvent<E extends Entity> extends PersistenceEvent<E> {
  final String entityId;
  const DeleteEvent({
    required this.entityId,
    required super.eventTime,
  });

  factory DeleteEvent.now(String entityId) {
    return DeleteEvent(
      entityId: entityId,
      eventTime: DateTime.now(),
    );
  }
}
