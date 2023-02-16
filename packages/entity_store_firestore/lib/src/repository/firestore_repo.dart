import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as f;

abstract class FirestoreRepo<Id, E extends Entity<Id>>
    extends IRepository<Id, E> {
  final EntityStoreController dispatcher;
  final f.CollectionReference collection;
  final CollectionType<Id, E> collectionType;

  FirestoreRepo(
    this.collectionType,
    this.collection,
    this.dispatcher,
  ) : super(dispatcher);
}
