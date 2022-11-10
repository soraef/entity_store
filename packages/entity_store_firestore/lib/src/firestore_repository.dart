import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';

abstract class FirestoreRepository<Id, E extends Entity<Id>> {
  final RepositoryConverter<Id, E> converter;
  final FirestoreCollection<Id, E> Function(Id id) getCollection;

  FirestoreRepository(this.converter, this.getCollection);
}

class FirestoreRepositoryAll<Id, E extends Entity<Id>>
    with
        FirestoreGet<Id, E>,
        FirestoreList<Id, E>,
        FirestoreCursor<Id, E>,
        FirestoreSave<Id, E>,
        FirestoreDelete<Id, E>
    implements FirestoreRepository<Id, E>, RepositoryAll<Id, E> {
  FirestoreRepositoryAll(this.converter, this.getCollection);

  @override
  final RepositoryConverter<Id, E> converter;

  @override
  final FirestoreCollection<Id, E> Function(Id id) getCollection;
}

abstract class FirestoreMapFieldRepository<Id, E extends Entity<Id>>
    with
        FirestoreMapFieldList<Id, E>,
        FirestoreMapFieldSave<Id, E>,
        FirestoreMapFieldDelete<Id, E>
    implements FirestoreRepository<Id, E> {
  FirestoreMapFieldRepository(this.converter, this.getCollection);
  @override
  final RepositoryConverter<Id, E> converter;

  @override
  final FirestoreCollection<Id, E> Function(Id id) getCollection;
}
