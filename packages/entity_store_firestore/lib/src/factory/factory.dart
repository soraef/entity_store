// import 'package:cloud_firestore/cloud_firestore.dart' as f;
// import 'package:entity_store/entity_store.dart';
// import 'package:entity_store_firestore/entity_store_firestore.dart';
// import 'package:entity_store_firestore/src/collection_type.dart';
// import 'package:entity_store_firestore/src/firestore_repository/firestore_bucketing_repository.dart';
// import 'package:entity_store_firestore/src/firestore_repository/firestore_general_repository.dart';

// class FirestoreRepositoryFactorySettings {
//   final Map<Type, CollectionType> _collectionTypeMap;
//   final EntityStoreController controller;

//   factory FirestoreRepositoryFactorySettings.init(
//       EntityStoreController controller) {
//     return FirestoreRepositoryFactorySettings._({}, controller);
//   }

//   FirestoreRepositoryFactorySettings._(
//     this._collectionTypeMap,
//     this.controller,
//   );

//   FirestoreRepositoryFactorySettings regist<Id, E extends Entity<Id>>(
//     CollectionType<Id, E> collectionType,
//   ) {
//     return FirestoreRepositoryFactorySettings._(
//       {..._collectionTypeMap, E: collectionType},
//       controller,
//     );
//   }

//   String collectionName<Id, E extends Entity<Id>>() {
//     return collectionType<Id, E>().collectionName;
//   }

//   CollectionType<Id, E> collectionType<Id, E extends Entity<Id>>() {
//     return _collectionTypeMap[E] as CollectionType<Id, E>;
//   }
// }

// class FirestoreRepositoryFactory implements IRepositoryFactory {
//   final FirestoreRepositoryFactorySettings settings;
//   late final f.CollectionReference Function(String collectionPath)
//       getCollectionRef;

//   factory FirestoreRepositoryFactory.init(
//     FirestoreRepositoryFactorySettings settings,
//     f.FirebaseFirestore firestore,
//   ) {
//     return FirestoreRepositoryFactory._(settings, firestore);
//   }

//   FirestoreRepositoryFactory._(
//     this.settings,
//     f.FirebaseFirestore firestore,
//   ) {
//     getCollectionRef = (path) => firestore.collection(path);
//   }

//   FirestoreRepositoryFactory._document(
//     this.settings,
//     f.DocumentReference document,
//   ) {
//     getCollectionRef = (path) => document.collection(path);
//   }

//   @override
//   FirestoreRepositoryFactory fromSubCollection<Id, E extends Entity<Id>>(
//       Id id) {
//     final collectionName = settings.collectionName<Id, E>();
//     final entityType = settings.collectionType<Id, E>();
//     final documentRef = getCollectionRef(collectionName).doc(
//       entityType.idToString(id),
//     );
//     return FirestoreRepositoryFactory._document(
//       settings,
//       documentRef,
//     );
//   }

//   @override
//   FirestoreRepository<Id, E> getRepo<Id, E extends Entity<Id>>() {
//     final collectionName = settings.collectionName<Id, E>();
//     final collectionRef = getCollectionRef(collectionName);
//     final collectionType = settings.collectionType<Id, E>();

//     if (collectionType.isGeneral) {
//       return FirestoreGeneralRepository<Id, E>(
//         settings.collectionType<Id, E>(),
//         collectionRef,
//         settings.controller,
//       );
//     } else if (collectionType.isBucketing) {
//       return FirestoreBucketingRepository<Id, E>(
//         settings.collectionType<Id, E>(),
//         collectionRef,
//         settings.controller,
//       );
//     } else {
//       throw AssertionError(
//         "CollectionType ${collectionType.runtimeType} is unknown",
//       );
//     }
//   }
// }
