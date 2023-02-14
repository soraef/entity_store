import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

// final todoRepo = Provider((ref) => TodoRepo(ref.read(dispater)));

final todoCollectionType = CollectionType<TodoId, Todo>(
  fromJson: Todo.fromJson,
  toJson: (e) => e.toJson(),
  idToString: (e) => e.value,
  collectionName: "Todo",
);



// class TodoRepo extends FirestoreRepo
//     with
//         FirestoreGet<TodoId, Todo>,
//         FirestoreSave<TodoId, Todo>,
//         FirestoreUpdate<TodoId, Todo>,
//         FirestoreDelete<TodoId, Todo>,
//         FirestoreList<TodoId, Todo> {
//   @override
//   FirestoreCollection<TodoId, Todo> getCollection(TodoId id) {
//     return TodoCollection();
//   }

//   @override
//   EntityJsonConverter<TodoId, Todo> get converter => EntityJsonConverter(
//         fromJson: Todo.fromJson,
//         toJson: (todo) => todo.toJson(),
//       );

//   TodoRepo(super.dispater);

//   Future<Result<List<Todo>, Exception>> listUserTodo(UserId userId) async {
//     return list(
//       collection: TodoCollection(),
//       where: (ref) => ref.where("userId", isEqualTo: userId.value),
//     );
//   }
// }

// class TodoCollection with FirestoreCollection1<TodoId, Todo> {
//   @override
//   String get collection1 => "Todo";

//   @override
//   String toDocumentId(TodoId id) {
//     return id.value;
//   }
// }
