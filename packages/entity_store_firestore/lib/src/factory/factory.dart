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

// class FirestoreRepo<Id, E extends Entity<Id>> extends IRepository<Id, E> {
//   final StoreEventDispatcher dispatcher;
//   final f.CollectionReference collection;
//   final CollectionType<Id, E> collectionType;

//   FirestoreRepo(
//     this.collectionType,
//     this.collection,
//     this.dispatcher,
//   ) : super(dispatcher);

//   @override
//   Future<Result<E?, Exception>> get(
//     Id id, {
//     GetOptions options = const GetOptions(),
//   }) async {
//     if (options.useCache) {
//       final entity = controller.get<Id, E>(id);
//       if (entity != null) {
//         return Result.ok(entity);
//       }
//     }

//     if (collectionType.isGeneral) {
//       late f.DocumentSnapshot<dynamic> doc;
//       try {
//         doc = await collection.doc(collectionType.idToString(id)).get();
//       } on f.FirebaseException catch (e) {
//         return Result.err(
//           FirestoreRequestFailure(
//             entityType: E,
//             code: e.code,
//             method: "get",
//             message: e.message,
//             exception: e,
//           ),
//         );
//       }
//       if (doc.exists) {
//         try {
//           final entity = collectionType.fromJson(doc.data());
//           controller.dispatch(GetEvent<Id, E>.now(id, entity));
//           return Result.ok(entity);
//         } on Exception catch (e) {
//           return Result.err(
//             JsonConverterFailure(
//               entityType: E,
//               method: "get",
//               fetched: doc.data(),
//               exception: e,
//             ),
//           );
//         }
//       }
//       return Result.ok(null);
//     } else if (collectionType.isBucketing) {
//       final bucketingType = collectionType.bucketing;
//       late f.QuerySnapshot<Object?> snapshot;
//       try {
//         snapshot = await collection
//             .where("_ids", arrayContains: collectionType.idToString(id))
//             .get();
//       } on f.FirebaseException catch (e) {
//         return Result.err(
//           FirestoreRequestFailure(
//             entityType: E,
//             code: e.code,
//             method: "get.bucketing",
//             message: e.message,
//             exception: e,
//           ),
//         );
//       }

//       final result = <E>[];
//       try {
//         for (final doc in snapshot.docs) {
//           result.addAll(
//             _convertBucketingResult(doc, bucketingType.bucketingFieldName),
//           );
//         }
//       } on Exception catch (e) {
//         return Result.err(
//           JsonConverterFailure(
//             entityType: E,
//             method: "get.bucketing",
//             fetched: snapshot.docs.map((e) => e.data()),
//             exception: e,
//           ),
//         );
//       }
//       controller.dispatch(ListEvent<Id, E>.now(result));
//       final entity = result.firstWhereOrNull((e) => e.id == id);
//       return Result.ok(entity);
//     } else {
//       throw AssertionError("UNKNOWN CollectionType");
//     }
//   }

//   Future<Result<List<E>, Exception>> listWhere({
//     FirestoreWhere? where,
//     Id? afterId,
//   }) async {
//     var ref = collection;
//     f.Query<dynamic> query = ref;

//     if (where != null) {
//       query = where(ref);
//     }

//     if (afterId != null) {
//       late f.DocumentSnapshot<dynamic> snapshot;
//       try {
//         snapshot = await collection
//             .doc(
//               collectionType.idToString(afterId),
//             )
//             .get();
//       } on f.FirebaseException catch (e) {
//         return Result.err(
//           FirestoreRequestFailure(
//             entityType: E,
//             code: e.code,
//             method: "list",
//             message: e.message,
//             exception: e,
//           ),
//         );
//       }
//       query = query.startAfterDocument(snapshot);
//     }

//     late f.QuerySnapshot<dynamic> snapshot;
//     try {
//       snapshot = await query.get();
//     } on f.FirebaseException catch (e) {
//       return Result.err(
//         FirestoreRequestFailure(
//           entityType: E,
//           code: e.code,
//           method: "list",
//           message: e.message,
//           exception: e,
//         ),
//       );
//     }

//     try {
//       final data = _convert(snapshot.docs).toList();
//       controller.dispatch(ListEvent<Id, E>.now(data));
//       return Result.ok(data);
//     } on Exception catch (e) {
//       return Result.err(
//         JsonConverterFailure(
//           entityType: E,
//           method: "list",
//           fetched: snapshot.docs.map((e) => e.data()).toList(),
//           exception: e,
//         ),
//       );
//     }
//   }

//   @override
//   Future<Result<Id, Exception>> delete(
//     Id id, {
//     DeleteOptions options = const DeleteOptions(),
//   }) async {
//     try {
//       await collection.doc(collectionType.idToString(id)).delete();
//       controller.dispatch(DeleteEvent<Id, E>.now(id));
//       return Result.ok(id);
//     } on f.FirebaseException catch (e) {
//       return Result.err(
//         FirestoreRequestFailure(
//           entityType: E,
//           code: e.code,
//           method: "delete",
//           message: e.message,
//           exception: e,
//         ),
//       );
//     }
//   }

//   @override
//   Future<Result<E, Exception>> save(
//     E entity, {
//     SaveOptions options = const SaveOptions(),
//   }) async {
//     if (collectionType.isGeneral) {
//       try {
//         await collection.doc(collectionType.idToString(entity.id)).set(
//               collectionType.toJson(entity),
//               f.SetOptions(merge: options.merge),
//             );
//         controller.dispatch(SaveEvent<Id, E>.now(entity));
//         return Result.ok(entity);
//       } on f.FirebaseException catch (e) {
//         return Result.err(
//           FirestoreRequestFailure(
//             entityType: E,
//             code: e.code,
//             method: "save",
//             message: e.message,
//             exception: e,
//           ),
//         );
//       }
//     } else if (collectionType.isBucketing) {
//       final bucketingType = collectionType.bucketing;
//       try {
//         await collection.doc(bucketingType.bucketIdToString(entity)).set(
//           {
//             bucketingType.bucketingFieldName: {
//               bucketingType.idToString(entity.id): bucketingType.toJson(entity),
//             },
//             ...bucketingType.toDocumentFields(entity),
//             "_count": f.FieldValue.increment(1),
//             "_ids": f.FieldValue.arrayUnion([
//               bucketingType.idToString(entity.id),
//             ])
//           },
//           f.SetOptions(merge: true),
//         );
//         controller.dispatch(SaveEvent<Id, E>.now(entity));
//         return Result.ok(entity);
//       } on f.FirebaseException catch (e) {
//         return Result.err(
//           FirestoreRequestFailure(
//             entityType: E,
//             code: e.code,
//             method: "firestore.batching.save",
//             message: e.message,
//             exception: e,
//           ),
//         );
//       }
//     } else {
//       throw AssertionError("UNKNOWN CollectionType");
//     }
//   }

//   Future<Result<Iterable<E>, Exception>> saveAll(
//     Iterable<E> entities, {
//     bool merge = false,
//   }) async {
//     if (entities.isEmpty) {
//       return Result.err(Exception());
//     }
//     if (collectionType.isGeneral) {
//       final futureList = entities.map((e) => save(e));
//       final results = await Future.wait(futureList);
//       if (results.every((e) => e.isOk)) {
//         return Result.ok(results.map((e) => e.ok));
//       } else {
//         return results.firstWhere((e) => e.isErr).mapOk((p0) => []);
//       }
//     } else if (collectionType.isBucketing) {
//       final bucketingType = collectionType.bucketing;
//       try {
//         final entity = entities.first;

//         await collection.doc((bucketingType.bucketIdToString(entity))).set(
//           {
//             bucketingType.bucketingFieldName: {
//               for (final e in entities)
//                 bucketingType.idToString(e.id): bucketingType.toJson(e),
//             },
//             ...bucketingType.toDocumentFields(entity),
//             "_count": f.FieldValue.increment(entities.length),
//             "_ids": f.FieldValue.arrayUnion([
//               for (final e in entities) bucketingType.idToString(e.id),
//             ])
//           },
//           f.SetOptions(merge: true),
//         );

//         for (final entity in entities) {
//           controller.dispatch(SaveEvent<Id, E>.now(entity));
//         }

//         return Result.ok(entities.toList());
//       } on f.FirebaseException catch (e) {
//         return Result.err(
//           FirestoreRequestFailure(
//             entityType: E,
//             code: e.code,
//             method: "firestore.batching.saveAll",
//             message: e.message,
//             exception: e,
//           ),
//         );
//       }
//     } else {
//       throw AssertionError("UNKNOWN CollectionType");
//     }
//   }

//   @experimental
//   Future<Result<E, Exception>> update(
//     Id id,
//     E Function(E prev) updater,
//   ) async {
//     try {
//       final entity = await collection.firestore.runTransaction<E>(
//         (transaction) async {
//           final ref = collection.doc(collectionType.idToString(id));
//           final doc = await transaction.get<dynamic>(ref);
//           final entity = collectionType.fromJson(doc.data());
//           final newEntity = updater(entity);
//           transaction.update(ref, collectionType.toJson(newEntity));
//           return newEntity;
//         },
//       );
//       controller.dispatch(SaveEvent<Id, E>.now(entity));
//       return Result.ok(entity);
//     } catch (e) {
//       return Result.err(Exception());
//     }
//   }

//   List<E> _convert(List<f.QueryDocumentSnapshot<dynamic>> docs) {
//     return docs
//         .map((e) => e.data())
//         .map((data) {
//           if (data == null) return null;
//           return collectionType.fromJson(data);
//         })
//         .whereType<E>()
//         .toList();
//   }

//   List<E> _convertBucketingResult(
//     f.DocumentSnapshot<dynamic> doc,
//     String fieldName,
//   ) {
//     final data = doc.data();
//     if (data == null) return [];
//     var json = data as Map<String, dynamic>;
//     var result = <E>[];

//     final entities = json[fieldName] as Map<String, dynamic>?;

//     for (final entityJson in entities?.values ?? []) {
//       result.add(collectionType.fromJson(entityJson));
//     }

//     return result;
//   }

//   @override
//   Future<Result<List<E>, Exception>> list(Query query) {
//     // TODO: implement list
//     throw UnimplementedError();
//   }
// }
