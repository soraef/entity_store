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

  WatcherWhere<E?, void> watchById<Id, E extends Entity<Id>>(Id id) {
    return _watchById<Id, E, void>(null, (prevData) => id);
  }

  WatcherWhere<EntityMap<Id, E>, void> watchWhere<Id, E extends Entity<Id>>([
    bool Function(E?)? test,
  ]) {
    return _watchWhere<Id, E, void>(
      null,
      (__, entity) => test?.call(entity) ?? true,
    );
  }

  WatcherWhere<E, U> _watchById<Id, E extends Entity<Id>, U>(
    WatcherWhere<U, dynamic>? prevChain,
    Id Function(U? prevData) idSelector,
  ) {
    return WatcherWhere<E, U>._(
      this,
      (prevData) => watchOne<Id, E>(idSelector(prevData))!,
      prevChain?.value,
    );
  }

  WatcherWhere<EntityMap<Id, E>, U> _watchWhere<Id, E extends Entity<Id>, U>(
    WatcherWhere<U, dynamic>? prevChain,
    bool Function(U? prevData, E entity) test,
  ) {
    return WatcherWhere<EntityMap<Id, E>, U>._(
      this,
      (prevData) => watchAll<Id, E>(
        (entity) => test(prevData, entity),
      ),
      prevChain?.value,
    );
  }
}

class WatcherWhere<T, U> {
  final BuildContext _context;
  final U? _prevData;
  final T Function(U? prevData) _watch;

  WatcherWhere._(this._context, this._watch, this._prevData);

  T get value => _watch(_prevData);

  WatcherWhere<E, T> watchById<Id, E extends Entity<Id>>(
    Id Function(T? prevData) idSelector,
  ) {
    return _context._watchById(
      this,
      (prevData) => idSelector(prevData),
    );
  }

  WatcherWhere<EntityMap<Id, E>, T> watchWhere<Id, E extends Entity<Id>>([
    bool Function(T? prevData, E entity)? test,
  ]) {
    return _context._watchWhere<Id, E, T>(
      this,
      test ?? (__, ___) => true,
    );
  }
}
