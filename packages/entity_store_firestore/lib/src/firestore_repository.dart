import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';

import 'entity_json_converter.dart';

abstract class FirestoreRepo<Id, E extends Entity<Id>> extends IRepo {
  final EntityJsonConverter<Id, E> converter;
  FirestoreCollection<Id, E> getCollection(Id id);

  FirestoreRepo(super.eventDispatcher, this.converter);
}
