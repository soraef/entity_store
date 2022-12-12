import 'package:entity_store/entity_store.dart';
import 'package:result_type/result_type.dart';

mixin InMemorySave<Id, E extends Entity<Id>> on InMemoryRepo<Id, E> {
  Future<Result<E, Exception>> save(E entity) async {
    entities[entity.id] = entity;
    return Success(entity);
  }
}
