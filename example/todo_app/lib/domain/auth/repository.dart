import 'package:entity_store/entity_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

import 'entity.dart';

final authRepo = Provider((ref) => AuthRepo(ref.read(dispater)));

class AuthRepo extends InMemoryRepo<CommonId, Auth> {
  AuthRepo(super.dispater);

  Future<Auth?> getAuth() async {
    Auth? auth;
    await get(CommonId.singleton()).then(
      (value) => value.result(
        (value) {
          auth = value;
        },
        (value) {
          auth = null;
        },
      ),
    );
    return auth;
  }
}
