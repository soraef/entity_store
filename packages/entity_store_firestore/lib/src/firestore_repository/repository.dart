part of '../firestore_repository.dart';

abstract class RootCollectionRepository<Id, E extends Entity<Id>>
    extends FirestoreRepository<Id, E> {
  String get collectionId;
  final FirebaseFirestore instance;

  RootCollectionRepository({
    required this.instance,
  });

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef =>
      instance.collection(collectionId);
}

abstract class SubCollectionRepository<Id, E extends Entity<Id>>
    extends FirestoreRepository<Id, E> {
  final String parentDocumentId;
  final FirestoreRepository parentRepository;

  SubCollectionRepository({
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

abstract class FirestoreRepository<Id, E extends Entity<Id>>
    with EntityChangeNotifier<Id, E>, FirestoreEntityNotifier<Id, E>
    implements IRepository<Id, E> {
  CollectionReference<Map<String, dynamic>> get collectionRef;

  final Map<Type, Object Function(FirestoreRepository parent, Id id)>
      _container = {};

  TRepo getRepo<TRepo extends SubCollectionRepository<dynamic, dynamic>>(
    Id id,
  ) {
    return _container[TRepo]!(this, id) as TRepo;
  }

  void bindRepo<TRepo extends SubCollectionRepository<dynamic, dynamic>>(
    TRepo Function(FirestoreRepository parent, Id id) repo,
  ) {
    _container[TRepo] = repo;
  }

  @override
  Future<Result<Id, Exception>> delete(
    Id id, {
    IDeleteOptions? options,
  }) async {
    return protectedDeleteAndNotify(collectionRef, id);
  }

  @override
  Future<Result<List<E>, Exception>> findAll() {
    return query().findAll();
  }

  @override
  Future<Result<E?, Exception>> findById(
    Id id, {
    IGetOptions? options,
  }) async {
    return protectedGetAndNotify(collectionRef, id);
  }

  @override
  IRepositoryQuery<Id, E> query() {
    return FirestoreRepositoryQuery(this);
  }

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    ISaveOptions? options,
  }) {
    return protectedSaveAndNotify(collectionRef, entity);
  }

  DocumentReference getDocumentRef(Id id) {
    return collectionRef.doc(toDocumentId(id));
  }
}
