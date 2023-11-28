part of '../entity_store.dart';

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
  T selectAll<Id, E extends Entity<Id>, T>(
    T Function(EntityMap<Id, E>) selector,
  ) {
    return select<EntityStoreNotifier, T>(
      (value) => selector(value.state.where<Id, E>()),
    );
  }

  T? selectOne<Id, E extends Entity<Id>, T>(
    Id id,
    T Function(E) selector,
  ) {
    return select<EntityStoreNotifier, T?>((value) {
      final entity = value.state.get<Id, E>(id);
      return entity != null ? selector(entity) : null;
    });
  }

  EntityMap<Id, E> watchAll<Id, E extends Entity<Id>>([
    bool Function(E) test = testAlwaysTrue,
  ]) {
    return selectAll<Id, E, EntityMap<Id, E>>((value) => value.where(test));
  }

  E? watchOne<Id, E extends Entity<Id>>(Id id) {
    return selectOne<Id, E, E?>(id, (value) => value);
  }

  EntityMap<Id, E> readAll<Id, E extends Entity<Id>>([
    bool Function(E) test = testAlwaysTrue,
  ]) {
    return read<EntityStoreNotifier>().value.where<Id, E>(test);
  }

  E? readOne<Id, E extends Entity<Id>>(Id id) {
    return read<EntityStoreNotifier>().value.get<Id, E>(id);
  }
}
