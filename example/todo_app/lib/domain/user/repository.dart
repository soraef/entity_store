import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/domain/task/repository.dart';
import 'package:todo_app/domain/weekly_activity/repository.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

import 'entity.dart';
import 'id.dart';

final userRepo = Provider((ref) => UserRepository(
      ref.read(entityStoreController),
    ));

class UserRepository extends FirestoreRepository<UserId, User> {
  UserRepository(EntityStoreController controller)
      : super(
          controller: controller,
          instance: FirebaseFirestore.instance,
        ) {
    registRepository(
      (parent, id) => TaskRepository(
        controller: parent.controller,
        parentRepository: parent,
        parentDocumentId: id.value,
      ),
    );
    registRepository(
      (parent, id) => WeeklyActivityRepository(
        controller: parent.controller,
        parentRepository: parent,
        parentDocumentId: id.value,
      ),
    );
  }

  @override
  User fromJson(Map<String, dynamic> json) {
    return User.fromJson(json);
  }

  @override
  String idToString(UserId id) {
    return id.value;
  }

  @override
  Map<String, dynamic> toJson(User entity) {
    return entity.toJson();
  }

  @override
  String get collectionId => "User";
}
