import 'package:entity_store/entity_store.dart';
import 'package:result_type/result_type.dart';

mixin InMemoryDelete<Id, E extends Entity<Id>> on InMemoryRepo<Id, E> {
  Future<Result<E, Exception>> delete(E entity) async {
    entities.remove(entity.id);
    return Success(entity);
  }
}
