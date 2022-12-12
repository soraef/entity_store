import 'package:entity_store/entity_store.dart';
import 'package:flutter/foundation.dart';

abstract class StoreEvent<Id, E extends Entity<Id>> {
  const StoreEvent();

  void debugPrint();
}

class GetEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final E? entity;
  const GetEvent({
    required this.entity,
  });

  @override
  void debugPrint() {
    if (kDebugMode) {
      print("[StoreEvent] GetEvent $entity");
    }
  }
}

class ListEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final List<E> entities;
  const ListEvent({
    required this.entities,
  });

  @override
  void debugPrint() {
    if (kDebugMode) {
      print("[StoreEvent] ListEvent $entities");
    }
  }
}

class SaveEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final E entity;
  const SaveEvent({
    required this.entity,
  });

  @override
  void debugPrint() {
    if (kDebugMode) {
      print("[StoreEvent] SaveEvent $entity");
    }
  }
}

class DeleteEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final Id entityId;
  const DeleteEvent({
    required this.entityId,
  });

  @override
  void debugPrint() {
    if (kDebugMode) {
      print("[StoreEvent] DeleteEvent $entityId");
    }
  }
}
