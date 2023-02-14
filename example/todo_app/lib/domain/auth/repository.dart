import 'package:entity_store/entity_store.dart';

import 'entity.dart';

extension AuthRepoX on IRepo<CommonId, Auth> {
  Future<Auth?> getAuth() async {
    return await get(CommonId.singleton()).then(
      (value) => value.okOrNull,
    );
  }
}
