import 'package:entity_store/entity_store.dart';
import 'package:skyreach_result/skyreach_result.dart';

class InMemoryRepo<Id, E extends Entity<Id>> extends IRepo<Id, E> {
  InMemoryRepo(super.dispater);

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions options = const SaveOptions(),
  }) async {
    dispater.dispatch(SaveEvent<Id, E>.now(entity));
    return Result.ok(entity);
  }

  @override
  Future<Result<List<E>, Exception>> list(Query query) async {
    return Result.ok(dispater.where<Id, E>().toList());
  }

  @override
  Future<Result<E, Exception>> delete(
    E entity, {
    DeleteOptions options = const DeleteOptions(),
  }) async {
    dispater.dispatch(DeleteEvent<Id, E>.now(entity.id));
    return Result.ok(entity);
  }

  @override
  Future<Result<E?, Exception>> get(
    Id id, {
    GetOptions options = const GetOptions(),
  }) async {
    return Result.ok(dispater.get(id));
  }
}

class InMemoryRepoFactory implements IRepoFactory {
  final StoreEventDispatcher dispatcher;

  InMemoryRepoFactory(this.dispatcher);

  @override
  InMemoryRepoFactory fromSubCollection<Id, E extends Entity<Id>>(Id id) {
    return this;
  }

  @override
  InMemoryRepo<Id, E> getRepo<Id, E extends Entity<Id>>() {
    return InMemoryRepo<Id, E>(dispatcher);
  }
}

// abstract class IQuery<TIn, TOut> {
//   TOut handle(TIn data);
// }

// class FirestoreQuery<Id, E extends Entity<Id>> {

// }
