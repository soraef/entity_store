import 'package:entity_store/entity_store.dart';

abstract class StoreEvent<Id, E extends Entity<Id>> {
  const StoreEvent();
}

class GetEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final E? entity;
  const GetEvent({
    required this.entity,
  });
}

class ListEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final List<E> entities;
  const ListEvent({
    required this.entities,
  });
}

class SaveEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final E entity;
  const SaveEvent({
    required this.entity,
  });
}

class DeleteEvent<Id, E extends Entity<Id>> extends StoreEvent<Id, E> {
  final Id entityId;
  const DeleteEvent({
    required this.entityId,
  });
}
