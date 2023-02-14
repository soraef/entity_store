// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:entity_store/entity_store.dart';
// import 'package:entity_store_firestore/entity_store_firestore.dart';
// import 'package:result_type/result_type.dart';

// mixin FirestoreBatchingList<Id, E extends Entity<Id>>
//     implements FirestoreRepo<Id, E> {
//   Future<Result<List<E>, Exception>> list({
//     required FirestoreCollection<Id, E> collection,
//     required String documentId,
//   }) async {
//     late DocumentSnapshot<dynamic> snapshot;
//     try {
//       final query = collection.collectionRef().doc(documentId);
//       snapshot = await query.get();
//     } on FirebaseException catch (e) {
//       return Failure(
//         FirestoreRequestFailure(
//             entityType: E,
//             code: e.code,
//             method: "firestore.batching.list",
//             message: e.message,
//             exception: e),
//       );
//     }

//     try {
//       final data = _convert(snapshot);
//       dispater.dispatch(ListEvent<Id, E>.now(data));
//       return Success(data);
//     } on Exception catch (e) {
//       return Failure(
//         JsonConverterFailure(
//           entityType: E,
//           method: "firestore.batching.list",
//           fetched: snapshot.data(),
//           exception: e,
//         ),
//       );
//     }
//   }

//   List<E> _convert(DocumentSnapshot<dynamic> doc) {
//     final data = doc.data();
//     if (data == null) return [];
//     var json = data as Map<String, dynamic>;
//     var result = <E>[];

//     final entities = json[fieldName] as Map<String, dynamic>?;

//     for (final entityJson in entities?.values ?? []) {
//       result.add(converter.fromJson(entityJson));
//     }

//     return result;
//   }

//   String get fieldName;
// }
