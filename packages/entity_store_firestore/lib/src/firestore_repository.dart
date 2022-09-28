import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';

abstract class FirestoreRepository<Id extends FirestoreId,
    E extends Entity<Id>> {
  final RepositoryConverter<Id, E> converter;

  FirestoreRepository(this.converter);
}

class FirestoreRepositoryAll<Id extends FirestoreId, E extends Entity<Id>>
    with
        FirestoreGet<Id, E>,
        FirestoreList<Id, E>,
        FirestoreCursor<Id, E>,
        FirestoreSave<Id, E>,
        FirestoreDelete<Id, E>
    implements FirestoreRepository<Id, E>, RepositoryAll<Id, E> {
  FirestoreRepositoryAll(this.converter);

  @override
  final RepositoryConverter<Id, E> converter;
}

abstract class FirestoreMapFieldRepository<Id extends FirestoreId,
        E extends Entity<Id>>
    with
        FirestoreMapFieldList<Id, E>,
        FirestoreMapFieldSave<Id, E>,
        FirestoreMapFieldDelete<Id, E>
    implements FirestoreRepository<Id, E> {
  FirestoreMapFieldRepository(this.converter);
  @override
  final RepositoryConverter<Id, E> converter;
}
