import 'package:entity_store/src/entity.dart';
import 'package:result_type/result_type.dart';

import 'in_memory_repo.dart';

mixin InMemoryGet<Id, E extends Entity<Id>> on InMemoryRepo<Id, E> {
  Future<Result<E?, Exception>> get(Id id) async {
    return Success(entities[id]);
  }
}
