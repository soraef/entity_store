part of '../firestore_repository.dart';

typedef CreateRepository<T, Id> = T Function(
    BaseFirestoreRepository parent, Id id);

abstract class RootCollectionRepository<Id, E extends Entity<Id>>
    extends FirestoreRepository<Id, E> {
  @override
  final EntityStoreController controller;
  final FirebaseFirestore instance;
  String get collectionId;

  RootCollectionRepository({
    required this.controller,
    required this.instance,
  });

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef =>
      instance.collection(collectionId);
}

abstract class SubCollectionRepository<Id, E extends Entity<Id>>
    extends FirestoreRepository<Id, E> implements SubCollection {
  @override
  final EntityStoreController controller;
  final String parentDocumentId;
  final BaseFirestoreRepository parentRepository;

  SubCollectionRepository({
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

abstract class SubCollection {}

abstract class FirestoreRepository<Id, E extends Entity<Id>>
    extends BaseFirestoreRepository<Id, E>
    with EntityChangeNotifier<Id, E>, FirestoreEntityNotifier<Id, E>
    implements IRepository<Id, E> {
  final Map<Type, CreateRepository<Object?, Id>> _container = {};

  TRepo getRepository<TRepo extends SubCollection>(
    Id id,
  ) {
    if (_container[TRepo] == null) {
      throw ArgumentError("$TRepo is Not regist in $runtimeType");
    }

    return _container[TRepo]!(this, id) as TRepo;
  }

  void registRepository<TRepo extends SubCollection>(
      CreateRepository<TRepo, Id> repo) {
    _container[TRepo] = repo;
  }

  @override
  DocumentReference getDocumentRef(Id id) {
    return collectionRef.doc(idToString(id));
  }
}

abstract class BaseFirestoreRepository<Id, E extends Entity<Id>>
    implements IFirestoreEntityNotifier<Id, E>, IRepository<Id, E> {
  CollectionReference<Map<String, dynamic>> get collectionRef;

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
  Future<Result<E?, Exception>> findOne() {
    return query().findOne();
  }

  @override
  Future<Result<E?, Exception>> findById(
    Id id, {
    IGetOptions? options,
  }) async {
    return protectedGetAndNotify(
      collectionRef,
      id,
      useCache: options?.useCache,
    );
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
    if (options is FirestoreSaveOptions) {
      return protectedSaveAndNotify(
        collectionRef,
        entity,
        merge: options.merge,
      );
    } else {
      return protectedSaveAndNotify(
        collectionRef,
        entity,
        merge: true,
      );
    }
  }

  @override
  Future<Result<E?, Exception>> createOrUpdate(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    ICreateOrUpdateOptions? options,
  }) {
    if (options is FirestoreCreateOrUpdateOptions) {
      return protectedCreateOrUpdateAndNotify(
        collectionRef,
        id,
        creater,
        updater,
        merge: options.merge,
      );
    } else {
      return protectedCreateOrUpdateAndNotify(
        collectionRef,
        id,
        creater,
        updater,
        merge: true,
      );
    }
  }

  DocumentReference getDocumentRef(Id id);
}
