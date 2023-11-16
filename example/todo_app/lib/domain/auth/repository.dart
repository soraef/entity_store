import 'package:entity_store/entity_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

import 'entity.dart';

final authRepo = Provider(
  (ref) => AuthRepo(ref.read(entityStoreController), InMemoryStorageHandler()),
);

class AuthRepo extends LocalStorageRepository<CommonId, Auth> {
  AuthRepo(super.controller, super.localStorageHandler);

  @override
  Auth fromJson(Map<String, dynamic> json) {
    return Auth(json["userId"]);
  }

  @override
  Map<String, dynamic> toJson(Auth entity) {
    return entity.toJson();
  }
}
