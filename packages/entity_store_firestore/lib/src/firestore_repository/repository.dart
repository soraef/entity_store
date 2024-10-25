part of '../firestore_repository.dart';

typedef CreateRepository<T, Id> = T Function(
    BaseFirestoreRepository parent, Id id);

abstract class RootCollectionRepository<E extends Entity>
    extends FirestoreRepository<E> {
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

abstract class SubCollectionRepository<E extends Entity>
    extends FirestoreRepository<E> implements SubCollection {
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

abstract class FirestoreRepository<E extends Entity>
    extends BaseFirestoreRepository<E>
    with EntityChangeNotifier<E>, FirestoreEntityNotifier<E>
    implements IRepository<E> {
  final Map<Type, CreateRepository<Object?, String>> _container = {};

  TRepo getRepository<TRepo extends SubCollection>(
    String id,
  ) {
    if (_container[TRepo] == null) {
      throw ArgumentError("$TRepo is Not regist in $runtimeType");
    }

    return _container[TRepo]!(this, id) as TRepo;
  }

  void registRepository<TRepo extends SubCollection>(
      CreateRepository<TRepo, String> repo) {
    _container[TRepo] = repo;
  }

  @override
  DocumentReference getDocumentRef(String id) {
    return collectionRef.doc(idToString(id));
  }
}

abstract class BaseFirestoreRepository<E extends Entity>
    implements IFirestoreEntityNotifier<E>, IRepository<E> {
  CollectionReference<Map<String, dynamic>> get collectionRef;

  @override
  Future<Result<String, Exception>> delete(
    String id, {
    DeleteOptions? options,
  }) async {
    return protectedDeleteAndNotify(collectionRef, id);
  }

  @override
  Future<Result<List<E>, Exception>> findAll({
    FindAllOptions? options,
  }) {
    return query().findAll(
      options: options,
    );
  }

  @override
  Future<Result<E?, Exception>> findOne({
    FindOneOptions? options,
  }) {
    return query().findOne(
      options: options,
    );
  }

  @override
  Future<Result<int, Exception>> count() {
    return query().count();
  }

  @override
  Future<Result<E?, Exception>> findById(
    String id, {
    FindByIdOptions? options,
  }) async {
    options = options ?? const FindByIdOptions();
    return protectedGetAndNotify(
      collectionRef,
      id,
      fetchPolicy: options.fetchPolicy,
    );
  }

  @override
  IRepositoryQuery<E> query() {
    return FirestoreRepositoryQuery(this);
  }

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions? options,
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
        merge: false,
      );
    }
  }

  @override
  Future<Result<E?, Exception>> upsert(
    String id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
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
        merge: false,
      );
    }
  }

  @override
  Stream<Result<E?, Exception>> observeById(
    String id, {
    ObserveByIdOptions? options,
  }) {
    return protectedObserveById(collectionRef, id);
  }

  DocumentReference getDocumentRef(String id);
}
