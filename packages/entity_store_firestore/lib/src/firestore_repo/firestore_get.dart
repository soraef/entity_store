// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:entity_store/entity_store.dart';
// import 'package:entity_store_firestore/entity_store_firestore.dart';
// import 'package:result_type/result_type.dart';

// mixin FirestoreGet<Id, E extends Entity<Id>> implements FirestoreRepo<Id, E> {
//   Future<Result<E?, Exception>> get(
//     Id id, {
//     bool useStoreCache = false,
//   }) async {
//     if (useStoreCache) {
//       final entity = dispater.get<Id, E>(id);
//       if (entity != null) {
//         return Success(entity);
//       }
//     }

//     late DocumentSnapshot<dynamic> doc;
//     try {
//       doc = await getCollection(id).documentRef(id).get();
//     } on FirebaseException catch (e) {
//       return Failure(
//         FirestoreRequestFailure(
//           entityType: E,
//           code: e.code,
//           method: "get",
//           message: e.message,
//           exception: e,
//         ),
//       );
//     }

//     if (doc.exists) {
//       try {
//         final entity = converter.fromJson(doc.data());
//         dispater.dispatch(GetEvent<Id, E>.now(id, entity));
//         return Success(entity);
//       } on Exception catch (e) {
//         return Failure(
//           JsonConverterFailure(
//             entityType: E,
//             method: "get",
//             fetched: doc.data(),
//             exception: e,
//           ),
//         );
//       }
//     }

//     return Success(null);
//   }

//   Future<List<E>> getByIds(List<Id> ids) async {
//     final future = ids.map((id) => get(id));
//     final docs = await Future.wait(future);

//     return docs.map((e) => e.mapError((p0) => null)).whereType<E>().toList();
//   }
// }
