import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/src/store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/domain/todo/repository.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

import 'entity.dart';
import 'id.dart';

final userRepo = Provider(
  (ref) => UserRepository(
    ref.read(entityStoreController),
  )..bindRepo(
      (parent, id) => TodoRepository(
        controller: parent.controller,
        parentRepository: parent,
        parentDocumentId: id.value,
      ),
    ),
);

class UserRepository extends RootCollectionRepository<UserId, User> {
  UserRepository(this.controller)
      : super(
          instance: FirebaseFirestore.instance,
        );

  @override
  final EntityStoreController controller;

  @override
  User fromJson(Map<String, dynamic> json) {
    return User.fromJson(json);
  }

  @override
  String toDocumentId(UserId id) {
    return id.value;
  }

  @override
  Map<String, dynamic> toJson(User entity) {
    return entity.toJson();
  }

  @override
  String get collectionId => "User";
}
