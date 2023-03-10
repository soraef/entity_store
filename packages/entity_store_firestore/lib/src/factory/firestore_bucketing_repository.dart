// import 'package:collection/collection.dart';
// import 'package:entity_store/entity_store.dart';
// import 'package:entity_store_firestore/entity_store_firestore.dart';
// import 'package:entity_store_firestore/src/repository/query.dart';
// import 'package:cloud_firestore/cloud_firestore.dart' as f;
// import 'package:skyreach_result/skyreach_result.dart';

// class FirestoreBucketingRepository<Id, E extends Entity<Id>>
//     extends FirestoreRepository<Id, E> {
//   FirestoreBucketingRepository(
//     super.collection,
//     super.controller,
//     super.collectionType,
//   );

//   @override
//   Future<Result<E, Exception>> delete(
//     E entity, {
//     DeleteOptions options = const DeleteOptions(),
//   }) async {
//     final bucketingType = collectionType.bucketing;
//     try {
//       await collection.doc(bucketingType.bucketIdToString(entity)).set(
//         {
//           bucketingType.bucketingFieldName: {
//             bucketingType.idToString(entity.id): f.FieldValue.delete(),
//           },
//           "_ids": f.FieldValue.arrayRemove([
//             bucketingType.idToString(entity.id),
//           ]),
//         },
//         f.SetOptions(merge: true),
//       );
//       controller.dispatch(DeleteEvent<Id, E>.now(entity.id));
//       return Result.ok(entity);
//     } on f.FirebaseException catch (e) {
//       return Result.err(
//         FirestoreRequestFailure(
//           entityType: E,
//           code: e.code,
//           method: "firestore.batching.delete",
//           message: e.message,
//           exception: e,
//         ),
//       );
//     }
//   }

//   @override
//   Future<Result<E?, Exception>> get(
//     Id id, {
//     GetOptions options = const GetOptions(),
//   }) async {
//     final bucketingType = collectionType.bucketing;
//     late f.QuerySnapshot<Object?> snapshot;
//     try {
//       snapshot = await collection
//           .where("_ids", arrayContains: collectionType.idToString(id))
//           .get();
//     } on f.FirebaseException catch (e) {
//       return Result.err(
//         FirestoreRequestFailure(
//           entityType: E,
//           code: e.code,
//           method: "get.bucketing",
//           message: e.message,
//           exception: e,
//         ),
//       );
//     }

//     final result = <E>[];
//     try {
//       for (final doc in snapshot.docs) {
//         result.addAll(
//           _convertBucketingResult(doc, bucketingType.bucketingFieldName),
//         );
//       }
//     } on Exception catch (e) {
//       return Result.err(
//         JsonConverterFailure(
//           entityType: E,
//           method: "get.bucketing",
//           fetched: snapshot.docs.map((e) => e.data()),
//           exception: e,
//         ),
//       );
//     }
//     controller.dispatch(ListEvent<Id, E>.now(result));
//     final entity = result.firstWhereOrNull((e) => e.id == id);
//     return Result.ok(entity);
//   }

//   @override
//   Future<Result<List<E>, Exception>> list([
//     RepositoryQuery<Id, E> Function(RepositoryQuery<Id, E> query)? buildQuery,
//   ]) async {
//     var query = RepositoryQuery<Id, E>();
//     if (buildQuery != null) {
//       query = buildQuery(query);
//     }

//     final bucketingType = collectionType.bucketing;
//     f.Query<dynamic> ref = collection;
//     ref = query.buildFilterQuery(ref);

//     final startAfterId = query.getStartAfterId;
//     if (startAfterId != null) {
//       throw AssertionError("startAfter Operation not supported");
//     }

//     ref = query.buildSortQuery(ref);
//     ref = query.buildLimitQuery(ref);

//     late f.QuerySnapshot<dynamic> snapshot;
//     try {
//       snapshot = await ref.get();
//     } on f.FirebaseException catch (e) {
//       return Result.err(
//         FirestoreRequestFailure(
//           entityType: E,
//           code: e.code,
//           method: "list.bucketing",
//           message: e.message,
//           exception: e,
//         ),
//       );
//     }

//     final result = <E>[];
//     try {
//       for (final doc in snapshot.docs) {
//         result.addAll(
//           _convertBucketingResult(doc, bucketingType.bucketingFieldName),
//         );
//       }
//     } on Exception catch (e) {
//       return Result.err(
//         JsonConverterFailure(
//           entityType: E,
//           method: "list.bucketing",
//           fetched: snapshot.docs.map((e) => e.data()),
//           exception: e,
//         ),
//       );
//     }
//     controller.dispatch(ListEvent<Id, E>.now(result));
//     return Result.ok(result);
//   }

//   @override
//   Future<Result<E, Exception>> save(
//     E entity, {
//     SaveOptions options = const SaveOptions(),
//   }) async {
//     final bucketingType = collectionType.bucketing;
//     try {
//       await collection.doc(bucketingType.bucketIdToString(entity)).set(
//         {
//           bucketingType.bucketingFieldName: {
//             bucketingType.idToString(entity.id): bucketingType.toJson(entity),
//           },
//           ...bucketingType.toDocumentFields(entity),
//           "_ids": f.FieldValue.arrayUnion([
//             bucketingType.idToString(entity.id),
//           ])
//         },
//         f.SetOptions(merge: true),
//       );
//       controller.dispatch(SaveEvent<Id, E>.now(entity));
//       return Result.ok(entity);
//     } on f.FirebaseException catch (e) {
//       return Result.err(
//         FirestoreRequestFailure(
//           entityType: E,
//           code: e.code,
//           method: "firestore.batching.save",
//           message: e.message,
//           exception: e,
//         ),
//       );
//     }
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
// }
