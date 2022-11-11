import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';

abstract class FirestoreRepository<Id, E extends Entity<Id>> {
  final RepositoryConverter<Id, E> converter;
  FirestoreCollection<Id, E> getCollection(Id id);

  FirestoreRepository(this.converter);
}

class FirestoreRepositoryAll<Id, E extends Entity<Id>,
        Params extends FirestoreListParams<Id, E>>
    with
        FirestoreGet<Id, E>,
        FirestoreList<Id, E, Params>,
        FirestoreCursor<Id, E>,
        FirestoreSave<Id, E>,
        FirestoreDelete<Id, E>
    implements FirestoreRepository<Id, E>, RepositoryAll<Id, E, Params> {
  FirestoreRepositoryAll(this.converter, this.getCollectionFunc);

  @override
  final RepositoryConverter<Id, E> converter;
  final FirestoreCollection<Id, E> Function(Id id) getCollectionFunc;

  @override
  FirestoreCollection<Id, E> getCollection(Id id) {
    return getCollectionFunc(id);
  }
}

abstract class FirestoreMapFieldRepository<Id, E extends Entity<Id>>
    with
        FirestoreMapFieldList<Id, E>,
        FirestoreMapFieldSave<Id, E>,
        FirestoreMapFieldDelete<Id, E>
    implements FirestoreRepository<Id, E> {
  FirestoreMapFieldRepository(this.converter, this.getCollectionFunc);
  @override
  final RepositoryConverter<Id, E> converter;

  final FirestoreCollection<Id, E> Function(Id id) getCollectionFunc;

  @override
  FirestoreCollection<Id, E> getCollection(Id id) {
    return getCollectionFunc(id);
  }
}
