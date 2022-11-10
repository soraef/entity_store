import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';

import 'collection.dart';

// abstract class FirestoreId extends Id {
//   const FirestoreId(String value, this.collection) : super(value);
//   final FirestoreCollection collection;

//   CollectionReference<dynamic> collectionRef() {
//     return collection.collectionRef();
//   }

//   DocumentReference<dynamic> documentRef() {
//     return collection.documentRef(value);
//   }

//   String get idString => collection.toId(value);
// }

mixin FirestoreId implements Id {
  FirestoreCollection get collection;

  CollectionReference<dynamic> collectionRef() {
    return collection.collectionRef();
  }

  DocumentReference<dynamic> documentRef() {
    return collection.documentRef(value);
  }

  String get idString => collection.toId(value);
}
