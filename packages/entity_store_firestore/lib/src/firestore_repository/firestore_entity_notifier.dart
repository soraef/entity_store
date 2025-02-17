// part of '../firestore_repository.dart';

// abstract class IFirestoreEntityNotifier<Id, E extends Entity<Id>> {
//   @protected
//   Future<Result<E?, Exception>> protectedGetAndNotify(
//     CollectionReference collection,
//     Id id, {
//     FetchPolicy fetchPolicy = FetchPolicy.persistent,
//     FirestoreTransactionContext? transaction,
//   });

//   @protected
//   Future<Result<Id, Exception>> protectedDeleteAndNotify(
//     CollectionReference collection,
//     Id id, {
//     FirestoreTransactionContext? transaction,
//   });
//   @protected
//   Future<Result<List<E>, Exception>> protectedListAndNotify(Query ref);

//   @protected
//   Future<Result<E, Exception>> protectedSaveAndNotify(
//     CollectionReference collection,
//     E entity, {
//     bool? merge,
//     List<Object>? mergeFields,
//     FirestoreTransactionContext? transaction,
//   });

//   @protected
//   Future<Result<E?, Exception>> protectedCreateOrUpdateAndNotify(
//     CollectionReference collection,
//     Id id,
//     E? Function() creater,
//     E? Function(E prev) updater, {
//     FetchPolicy fetchPolicy = FetchPolicy.persistent,
//     bool? merge,
//     bool? useTransaction,
//     List<Object>? mergeFields,
//   });

//   @protected
//   Stream<Result<E?, Exception>> protectedObserveById(
//     CollectionReference<Map<String, dynamic>> collectionRef,
//     Id id,
//   );

//   @protected
//   Stream<Result<List<EntityChange<E>>, Exception>> protectedObserveCollection(
//     Query collection,
//   );
// }

// mixin FirestoreEntityNotifier<Id, E extends Entity<Id>>
//     on EntityChangeNotifier<Id, E> implements IFirestoreEntityNotifier<Id, E> {
//   Map<String, dynamic> toJson(E entity);
//   E fromJson(Map<String, dynamic> json);
//   String idToString(Id id);

//   @override
//   Future<Result<E?, Exception>> protectedGetAndNotify(
//     CollectionReference collection,
//     Id id, {
//     FetchPolicy fetchPolicy = FetchPolicy.persistent,
//     FirestoreTransactionContext? transaction,
//   }) async {
//     late DocumentSnapshot<dynamic> doc;

//     var entity = controller.getById<Id, E>(id);

//     /// get using transaction
//     if (transaction != null) {
//       final ref = collection.doc(idToString(id));
//       doc = await transaction.value.get(ref);
//     } else {
//       /// get using no transaction
//       if (fetchPolicy == FetchPolicy.storeOnly) {
//         return Result.success(entity);
//       }

//       if (fetchPolicy == FetchPolicy.storeFirst) {
//         if (entity != null) {
//           return Result.success(entity);
//         }
//       }

//       try {
//         doc = await collection.doc(idToString(id)).get();
//       } on FirebaseException catch (e) {
//         return Result.failure(
//           FirestoreRequestFailure(
//             entityType: E,
//             code: e.code,
//             message: e.message,
//             exception: e,
//           ),
//         );
//       }
//     }

//     if (doc.exists) {
//       try {
//         final entity = fromJson(doc.data());
//         notifyGetComplete(entity);
//         return Result.success(entity);
//       } on Exception catch (e) {
//         return Result.failure(
//           JsonConverterFailure(
//             entityType: E,
//             fetched: doc.data(),
//             exception: e,
//           ),
//         );
//       }
//     } else {
//       notifyEntityNotFound(id);
//     }

//     return Result.success(null);
//   }

//   @override
//   Future<Result<Id, Exception>> protectedDeleteAndNotify(
//     CollectionReference collection,
//     Id id, {
//     FirestoreTransactionContext? transaction,
//   }) async {
//     if (transaction != null) {
//       final ref = collection.doc(idToString(id));
//       transaction.value.delete(ref);

//       // notify after commit
//       transaction.addOnCommitFunction(() {
//         notifyDeleteComplete(id);
//       });
//       return Result.success(id);
//     } else {
//       try {
//         await collection.doc(idToString(id)).delete();
//         notifyDeleteComplete(id);
//         return Result.success(id);
//       } on FirebaseException catch (e) {
//         return Result.failure(
//           FirestoreRequestFailure(
//             entityType: E,
//             code: e.code,
//             message: e.message,
//             exception: e,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Future<Result<List<E>, Exception>> protectedListAndNotify(Query ref) async {
//     late QuerySnapshot<dynamic> snapshot;
//     try {
//       snapshot = await ref.get();
//     } on FirebaseException catch (e) {
//       // failed-preconditionの場合
//       if (e.code == 'failed-precondition') {
//         if (e.message?.contains('The query requires an index') == true) {
//           // ignore: avoid_print
//           print(e.message);
//         }
//       }
//       return Result.failure(
//         FirestoreRequestFailure(
//           entityType: E,
//           code: e.code,
//           message: e.message,
//           exception: e,
//         ),
//       );
//     }

//     try {
//       final data = _convert(snapshot.docs).toList();
//       notifyListComplete(data);
//       return Result.success(data);
//     } on Exception catch (e) {
//       return Result.failure(
//         JsonConverterFailure(
//           entityType: E,
//           fetched: snapshot.docs.map((e) => e.data()).toList(),
//           exception: e,
//         ),
//       );
//     }
//   }

//   @override
//   Future<Result<E, Exception>> protectedSaveAndNotify(
//     CollectionReference collection,
//     E entity, {
//     bool? merge,
//     List<Object>? mergeFields,
//     FirestoreTransactionContext? transaction,
//   }) async {
//     if (transaction != null) {
//       final ref = collection.doc(idToString(entity.id));
//       transaction.value.set(
//         ref,
//         toJson(entity),
//         SetOptions(merge: merge, mergeFields: mergeFields),
//       );

//       // notify after commit
//       transaction.addOnCommitFunction(() {
//         notifySaveComplete(entity);
//       });

//       return Result.success(entity);
//     } else {
//       try {
//         await collection.doc(idToString(entity.id)).set(
//               toJson(entity),
//               merge != null || mergeFields != null
//                   ? SetOptions(merge: merge, mergeFields: mergeFields)
//                   : null,
//             );
//         notifySaveComplete(entity);
//         return Result.success(entity);
//       } on FirebaseException catch (e) {
//         return Result.failure(
//           FirestoreRequestFailure(
//             entityType: E,
//             code: e.code,
//             message: e.message,
//             exception: e,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Future<Result<E?, Exception>> protectedCreateOrUpdateAndNotify(
//     CollectionReference collection,
//     Id id,
//     E? Function() creater,
//     E? Function(E prev) updater, {
//     FetchPolicy fetchPolicy = FetchPolicy.persistent,
//     bool? merge,
//     bool? useTransaction,
//     List<Object>? mergeFields,
//   }) async {
//     /// get and set using transaction
//     Future<E?> getAndSetTransaction() async {
//       return await collection.firestore.runTransaction((transaction) async {
//         final doc = await transaction.get(collection.doc(idToString(id)));
//         final entity = doc.exists ? fromJson(doc.data() as dynamic) : null;
//         final newEntity = entity == null ? creater() : updater(entity);
//         if (newEntity != null) {
//           transaction.set(
//             collection.doc(idToString(id)),
//             toJson(newEntity),
//             merge != null || mergeFields != null
//                 ? SetOptions(merge: merge, mergeFields: mergeFields)
//                 : null,
//           );
//         }

//         return newEntity;
//       });
//     }

//     /// get and set using no transaction
//     Future<E?> getAndSetNoTransaction() async {
//       E? entity;

//       if (fetchPolicy == FetchPolicy.storeOnly ||
//           fetchPolicy == FetchPolicy.storeFirst) {
//         entity = controller.getById<Id, E>(id);
//       }

//       if (fetchPolicy == FetchPolicy.persistent ||
//           (entity == null && fetchPolicy == FetchPolicy.storeFirst)) {
//         final doc = await collection.doc(idToString(id)).get();
//         entity = doc.exists ? fromJson(doc.data() as dynamic) : null;
//       }

//       final newEntity = entity == null ? creater() : updater(entity);
//       if (newEntity != null) {
//         await collection.doc(idToString(id)).set(
//               toJson(newEntity),
//               merge != null || mergeFields != null
//                   ? SetOptions(merge: merge, mergeFields: mergeFields)
//                   : null,
//             );
//       }

//       return newEntity;
//     }

//     try {
//       final entity = await useTransaction.orTrue.ifMap(
//         ifTrue: getAndSetTransaction,
//         ifFalse: getAndSetNoTransaction,
//       );

//       if (entity == null) {
//         notifyEntityNotFound(id);
//       } else {
//         notifySaveComplete(entity);
//       }

//       return Result.success(entity);
//     } on FirebaseException catch (e) {
//       return Result.failure(
//         FirestoreRequestFailure(
//           entityType: E,
//           code: e.code,
//           message: e.message,
//           exception: e,
//         ),
//       );
//     }
//   }

//   @override
//   Stream<Result<E?, Exception>> protectedObserveById(
//     CollectionReference<Map<String, dynamic>> collectionRef,
//     Id id,
//   ) {
//     return collectionRef.doc(idToString(id)).snapshots().map((event) {
//       if (event.exists) {
//         try {
//           final entity = fromJson(event.data() as dynamic);
//           notifyGetComplete(entity);
//           return Result.success(entity);
//         } on Exception catch (e) {
//           return Result.failure(
//             JsonConverterFailure(
//               entityType: E,
//               fetched: event.data(),
//               exception: e,
//             ),
//           );
//         }
//       } else {
//         notifyEntityNotFound(id);
//         return Result.success(null);
//       }
//     });
//   }

//   @override
//   Stream<Result<List<EntityChange<E>>, Exception>> protectedObserveCollection(
//     Query collection,
//   ) {
//     return collection.snapshots().map((event) {
//       final changes = event.docChanges.map((e) {
//         final entity = fromJson(e.doc.data() as dynamic);
//         if (e.type == DocumentChangeType.added) {
//           return EntityChange<E>(
//             entity: entity,
//             changeType: ChangeType.created,
//           );
//         } else if (e.type == DocumentChangeType.modified) {
//           return EntityChange<E>(
//             entity: entity,
//             changeType: ChangeType.updated,
//           );
//         } else if (e.type == DocumentChangeType.removed) {
//           return EntityChange<E>(
//             entity: entity,
//             changeType: ChangeType.deleted,
//           );
//         } else {
//           throw UnimplementedError();
//         }
//       }).toList();

//       for (final change in changes) {
//         if (change.changeType == ChangeType.created) {
//           notifyGetComplete(change.entity);
//         } else if (change.changeType == ChangeType.updated) {
//           notifyGetComplete(change.entity);
//         } else if (change.changeType == ChangeType.deleted) {
//           notifyDeleteComplete(change.entity.id);
//         }
//       }
//       return Result.success(changes);
//     });
//   }

//   List<E> _convert(List<QueryDocumentSnapshot<dynamic>> docs) {
//     return docs
//         .map((e) => e.data())
//         .map((data) {
//           if (data == null) return null;
//           return fromJson(data);
//         })
//         .whereType<E>()
//         .toList();
//   }
// }

// extension _BoolX on bool {
//   T ifMap<T>({
//     required T Function() ifTrue,
//     required T Function() ifFalse,
//   }) {
//     if (this) {
//       return ifTrue();
//     } else {
//       return ifFalse();
//     }
//   }
// }

// extension _BoolOrNullX on bool? {
//   bool get orTrue => this ?? true;
// }
