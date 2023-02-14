import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';

abstract class AFirestoreRepo<Id, E extends Entity<Id>> extends IRepo {
  final EntityJsonConverter<Id, E> converter;
  FirestoreCollection<Id, E> getCollection(Id id);

  AFirestoreRepo(super.eventDispatcher, this.converter);
}
