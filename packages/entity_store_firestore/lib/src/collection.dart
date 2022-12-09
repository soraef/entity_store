import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:equatable/equatable.dart';

abstract class FirestoreCollection<Id, E extends Entity<Id>> extends Equatable {
  CollectionReference<dynamic> collectionRef();

  DocumentReference<dynamic> documentRef(Id id) {
    return collectionRef().doc(toDocumentId(id));
  }

  String toDocumentId(Id id);
}

mixin FirestoreCollection1<Id, E extends Entity<Id>>
    implements FirestoreCollection<Id, E> {
  String get collection1;

  @override
  CollectionReference<dynamic> collectionRef() {
    return FirebaseFirestore.instance.collection(collection1);
  }

  @override
  DocumentReference<dynamic> documentRef(Id id) {
    return collectionRef().doc(toDocumentId(id));
  }

  @override
  List<Object?> get props => [collection1];

  @override
  bool? get stringify => true;
}

mixin FirestoreCollection2<Id, E extends Entity<Id>>
    implements FirestoreCollection<Id, E> {
  String get collection1;
  String get document1;
  String get collection2;

  @override
  CollectionReference<dynamic> collectionRef() {
    return FirebaseFirestore.instance
        .collection(collection1)
        .doc(document1)
        .collection(collection2);
  }

  @override
  DocumentReference<dynamic> documentRef(Id id) {
    return collectionRef().doc(toDocumentId(id));
  }
}
