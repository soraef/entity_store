import 'package:entity_store/entity_store.dart';
export 'in_memory_repo_get.dart';
export 'in_memory_repo_list.dart';
export 'in_memory_repo_save.dart';
export 'in_memory_repo_delete.dart';

abstract class InMemoryRepo<Id, E extends Entity<Id>> extends IRepo {
  final Map<Id, E> entities = {};
  InMemoryRepo(super.eventDispatcher);
}
