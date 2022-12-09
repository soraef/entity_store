import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';

import 'entity_json_converter.dart';

abstract class FirestoreRepo<Id, E extends Entity<Id>> extends IRepo {
  final EntityJsonConverter<Id, E> converter;
  FirestoreCollection<Id, E> getCollection(Id id);

  FirestoreRepo(super.eventDispatcher, this.converter);
}

// class FirestoreRepositoryAll<Id, E extends Entity<Id>,
//         Params extends FirestoreListParams<Id, E>>
//     with
//         FirestoreGet<Id, E>,
//         FirestoreList<Id, E, Params>,
//         FirestoreSave<Id, E>,
//         FirestoreDelete<Id, E>
//     implements FirestoreRepository<Id, E>, RepositoryAll<Id, E, Params> {
//   FirestoreRepositoryAll(this.converter, this.getCollectionFunc);

//   @override
//   final RepositoryConverter<Id, E> converter;
//   final FirestoreCollection<Id, E> Function(Id id) getCollectionFunc;

//   @override
//   FirestoreCollection<Id, E> getCollection(Id id) {
//     return getCollectionFunc(id);
//   }
// }

// abstract class FirestoreMapFieldRepository<Id, E extends Entity<Id>>
//     with
//         FirestoreMapFieldList<Id, E>,
//         FirestoreMapFieldSave<Id, E>,
//         FirestoreMapFieldDelete<Id, E>
//     implements FirestoreRepository<Id, E> {
//   FirestoreMapFieldRepository(this.converter, this.getCollectionFunc);
//   @override
//   final RepositoryConverter<Id, E> converter;

//   final FirestoreCollection<Id, E> Function(Id id) getCollectionFunc;

//   @override
//   FirestoreCollection<Id, E> getCollection(Id id) {
//     return getCollectionFunc(id);
//   }
// }
