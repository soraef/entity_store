part of "../store.dart";

class EntityStoreProviderScope extends StatelessWidget {
  final Widget child;
  final EntityStoreNotifier entityStoreNotifier;

  // コンストラクタを通じてEntityStoreNotifierのインスタンスを受け取る
  const EntityStoreProviderScope({
    Key? key,
    required this.child,
    required this.entityStoreNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Providerを使用してEntityStoreNotifierを提供する
    return ChangeNotifierProvider<EntityStoreNotifier>.value(
      value: entityStoreNotifier,
      child: child,
    );
  }
}

extension BuildContextEntityStoreProviderScope on BuildContext {
  EntityMap<Id, E> watchEntities<Id, E extends Entity<Id>>([
    bool Function(E) test = testAlwaysTrue,
  ]) {
    return select<EntityStoreNotifier, EntityMap<Id, E>>(
      (value) => value.state.where<Id, E>(test),
    );
  }

  E? watchEntity<Id, E extends Entity<Id>>(Id id) {
    return select<EntityStoreNotifier, E?>(
      (value) => value.state.get<Id, E>(id),
    );
  }

  EntityMap<Id, E> readEntities<Id, E extends Entity<Id>>([
    bool Function(E) test = testAlwaysTrue,
  ]) {
    return read<EntityStoreNotifier>().value.where<Id, E>(test);
  }

  E? readEntity<Id, E extends Entity<Id>>(Id id) {
    return read<EntityStoreNotifier>().value.get<Id, E>(id);
  }
}