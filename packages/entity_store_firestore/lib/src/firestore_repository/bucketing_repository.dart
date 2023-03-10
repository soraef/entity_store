part of '../firestore_repository.dart';

abstract class RootCollectionBucketRepository<Id, E extends Entity<Id>>
    extends FirestoreBucketRepository<Id, E> {
  @override
  final EntityStoreController controller;
  final FirebaseFirestore instance;
  String get collectionId;

  RootCollectionBucketRepository({
    required this.controller,
    required this.instance,
  });

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef =>
      instance.collection(collectionId);
}

abstract class SubCollectionBucketRepository<Id, E extends Entity<Id>>
    extends FirestoreBucketRepository<Id, E> implements SubCollection {
  @override
  final EntityStoreController controller;
  final String parentDocumentId;
  final BaseFirestoreRepository parentRepository;

  SubCollectionBucketRepository({
    required this.controller,
    required this.parentRepository,
    required this.parentDocumentId,
  });

  String get collectionId;

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef =>
      parentRepository.collectionRef
          .doc(parentDocumentId)
          .collection(collectionId);
}

abstract class FirestoreBucketRepository<Id, E extends Entity<Id>>
    extends BaseFirestoreRepository<Id, E>
    with EntityChangeNotifier<Id, E>, FirestoreBucketEntityNotifier<Id, E>
    implements IRepository<Id, E> {
  final Map<Type, CreateRepository<Object?, String>> _container = {};

  TRepo getRepository<TRepo extends SubCollection>(
    String bucketId,
  ) {
    if (_container[TRepo] == null) {
      throw ArgumentError("$TRepo is Not regist in $runtimeType");
    }

    return _container[TRepo]!(this, bucketId) as TRepo;
  }

  void registRepository<TRepo extends SubCollection>(
      CreateRepository<TRepo, String> repo) {
    _container[TRepo] = repo;
  }

  @override
  DocumentReference getDocumentRef(Id id) {
    throw UnsupportedError(
      "DocumentReference cannot get from $Id in $runtimeType",
    );
  }
}
