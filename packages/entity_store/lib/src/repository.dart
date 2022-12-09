import 'store_event_dispatcher.dart';

abstract class IRepo {
  final StoreEventDispatcher eventDispatcher;

  IRepo(this.eventDispatcher);
}

// /// 取得した[Entity]を[EntityMap]に正規化して保存するRepoの抽象クラス
// abstract class IEntityMapRepo<Id, E extends Entity<Id>> {
//   final IStore<EntityMap<Id, E>> store;
//   IEntityMapRepo(this.store);

//   @protected
//   void onCompleteGet(E? entity) {
//     store.update(
//       (prev) => entity != null ? prev.put(entity) : prev.remove(entity!),
//     );
//   }

//   @protected
//   void onCompleteList(List<E> entities) {
//     store.update((prev) => prev.putAll(entities));
//   }

//   @protected
//   void onCompleteSave(E entity) {
//     store.update((prev) => prev.put(entity));
//   }

//   @protected
//   void onCompleteDelete(Id id) {
//     store.update((prev) => prev.removeById(id));
//   }
// }

// abstract class IEntityRepo<Id, E extends Entity<Id>> {
//   final IStore<E?> store;
//   IEntityRepo(this.store);

//   @protected
//   void onCompleteGet(E? entity) {
//     store.update(
//       (prev) => entity,
//     );
//   }

//   @protected
//   void onCompleteSave(E entity) {
//     store.update((prev) => entity);
//   }

//   @protected
//   void onCompleteDelete(Id id) {
//     store.update((prev) => null);
//   }
// }
