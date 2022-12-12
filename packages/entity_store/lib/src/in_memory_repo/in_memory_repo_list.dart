import 'package:entity_store/entity_store.dart';
import 'package:result_type/result_type.dart';

mixin InMemoryList<Id, E extends Entity<Id>> on InMemoryRepo<Id, E> {
  Future<Result<List<E>, Exception>> list(bool Function(E) test) async {
    return Success(entities.values.where(test).toList());
  }
}
