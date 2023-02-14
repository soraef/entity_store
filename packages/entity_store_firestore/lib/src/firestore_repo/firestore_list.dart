// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:entity_store/entity_store.dart';
// import 'package:entity_store_firestore/entity_store_firestore.dart';
// import 'package:result_type/result_type.dart';

// mixin FirestoreList<Id, E extends Entity<Id>> implements FirestoreRepo<Id, E> {
//   Future<Result<List<E>, Exception>> list({
//     required FirestoreCollection<Id, E> collection,
//     int? limit,
//     String? orderByField,
//     FirestoreWhere? where,
//     Id? afterId,
//   }) async {
//     var ref = collection.collectionRef();
//     Query<dynamic> query = ref;

//     if (where != null) {
//       query = where(ref);
//     }

//     if (afterId != null) {
//       late DocumentSnapshot<dynamic> snapshot;
//       try {
//         snapshot = await collection.documentRef(afterId).get();
//       } on FirebaseException catch (e) {
//         return Failure(
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

//     if (orderByField != null) {
//       query = query.orderBy(orderByField);
//     }

//     if (limit != null) {
//       query = query.limit(limit);
//     }

//     late QuerySnapshot<dynamic> snapshot;
//     try {
//       snapshot = await query.get();
//     } on FirebaseException catch (e) {
//       return Failure(
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
//       dispater.dispatch(ListEvent<Id, E>.now(data));
//       return Success(data);
//     } on Exception catch (e) {
//       return Failure(
//         JsonConverterFailure(
//           entityType: E,
//           method: "list",
//           fetched: snapshot.docs.map((e) => e.data()).toList(),
//           exception: e,
//         ),
//       );
//     }
//   }

//   List<E> _convert(List<QueryDocumentSnapshot<dynamic>> docs) {
//     return docs
//         .map((e) => e.data())
//         .map((data) {
//           if (data == null) return null;

//           return converter.fromJson(data);
//         })
//         .whereType<E>()
//         .toList();
//   }
// }
