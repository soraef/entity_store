import 'package:cloud_firestore/cloud_firestore.dart' as f;
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:entity_store_firestore/src/repository/firestore_bucketing_repo.dart';
import 'package:entity_store_firestore/src/repository/firestore_general_repo.dart';

class FirestoreRepoFactorySettings {
  final Map<Type, CollectionType> _collectionTypeMap;
  final EntityStoreController dispatcher;

  factory FirestoreRepoFactorySettings.init(EntityStoreController dispatcher) {
    return FirestoreRepoFactorySettings._({}, dispatcher);
  }

  FirestoreRepoFactorySettings._(
    this._collectionTypeMap,
    this.dispatcher,
  );

  FirestoreRepoFactorySettings regist<Id, E extends Entity<Id>>(
    CollectionType<Id, E> collectionType,
  ) {
    return FirestoreRepoFactorySettings._(
      {..._collectionTypeMap, E: collectionType},
      dispatcher,
    );
  }

  String collectionName<Id, E extends Entity<Id>>() {
    return collectionType<Id, E>().collectionName;
  }

  CollectionType<Id, E> collectionType<Id, E extends Entity<Id>>() {
    return _collectionTypeMap[E] as CollectionType<Id, E>;
  }
}

class FirestoreRepoFactory implements IRepositoryFactory {
  final FirestoreRepoFactorySettings settings;
  late final f.CollectionReference Function(String collectionPath)
      getCollectionRef;

  factory FirestoreRepoFactory.init(
    FirestoreRepoFactorySettings settings,
    f.FirebaseFirestore firestore,
  ) {
    return FirestoreRepoFactory._(settings, firestore);
  }

  FirestoreRepoFactory._(
    this.settings,
    f.FirebaseFirestore firestore,
  ) {
    getCollectionRef = (path) => firestore.collection(path);
  }

  FirestoreRepoFactory._document(
    this.settings,
    f.DocumentReference document,
  ) {
    getCollectionRef = (path) => document.collection(path);
  }

  @override
  FirestoreRepoFactory fromSubCollection<Id, E extends Entity<Id>>(Id id) {
    final collectionName = settings.collectionName<Id, E>();
    final entityType = settings.collectionType<Id, E>();
    final documentRef = getCollectionRef(collectionName).doc(
      entityType.idToString(id),
    );
    return FirestoreRepoFactory._document(
      settings,
      documentRef,
    );
  }

  @override
  FirestoreRepo<Id, E> getRepo<Id, E extends Entity<Id>>() {
    final collectionName = settings.collectionName<Id, E>();
    final collectionRef = getCollectionRef(collectionName);
    final collectionType = settings.collectionType<Id, E>();

    if (collectionType.isGeneral) {
      return FirestoreGeneralRepo<Id, E>(
        settings.collectionType<Id, E>(),
        collectionRef,
        settings.dispatcher,
      );
    } else if (collectionType.isBucketing) {
      return FirestoreBucketingRepo<Id, E>(
        settings.collectionType<Id, E>(),
        collectionRef,
        settings.dispatcher,
      );
    } else {
      throw AssertionError(
        "CollectionType ${collectionType.runtimeType} is unknown",
      );
    }
  }
}
