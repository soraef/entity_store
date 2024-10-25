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
  T selectAll<E extends Entity, T>(
    T Function(EntityMap<E>) selector,
  ) {
    return select<EntityStoreNotifier, T>(
      (value) => selector(value.state.where<E>()),
    );
  }

  T? selectOne<E extends Entity, T>(
    String id,
    T Function(E) selector,
  ) {
    return select<EntityStoreNotifier, T?>((value) {
      final entity = value.state.get<E>(id);
      return entity != null ? selector(entity) : null;
    });
  }

  EntityMap<E> watchAll<E extends Entity>([
    bool Function(E) test = testAlwaysTrue,
  ]) {
    return selectAll<E, EntityMap<E>>((value) => value.where(test));
  }

  E? watchOne<E extends Entity>(String id) {
    return selectOne<E, E?>(id, (value) => value);
  }

  EntityMap<E> readAll<E extends Entity>([
    bool Function(E) test = testAlwaysTrue,
  ]) {
    return read<EntityStoreNotifier>().value.where<E>(test);
  }

  E? readOne<E extends Entity>(String id) {
    return read<EntityStoreNotifier>().value.get<E>(id);
  }

  WatcherWhere<E?, void> watchById<E extends Entity>(String id) {
    return _watchById<E, void>(null, (prevData) => id);
  }

  WatcherWhere<EntityMap<E>, void> watchWhere<E extends Entity>([
    bool Function(E?)? test,
  ]) {
    return _watchWhere<E, void>(
      null,
      (__, entity) => test?.call(entity) ?? true,
    );
  }

  WatcherWhere<E, U> _watchById<E extends Entity, U>(
    WatcherWhere<U, dynamic>? prevChain,
    String Function(U? prevData) idSelector,
  ) {
    return WatcherWhere<E, U>._(
      this,
      (prevData) => watchOne<E>(idSelector(prevData))!,
      prevChain?.value,
    );
  }

  WatcherWhere<EntityMap<E>, U> _watchWhere<E extends Entity, U>(
    WatcherWhere<U, dynamic>? prevChain,
    bool Function(U? prevData, E entity) test,
  ) {
    return WatcherWhere<EntityMap<E>, U>._(
      this,
      (prevData) => watchAll<E>(
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

  WatcherWhere<E, T> watchById<E extends Entity>(
    String Function(T? prevData) idSelector,
  ) {
    return _context._watchById(
      this,
      (prevData) => idSelector(prevData),
    );
  }

  WatcherWhere<EntityMap<E>, T> watchWhere<E extends Entity>([
    bool Function(T? prevData, E entity)? test,
  ]) {
    return _context._watchWhere<E, T>(
      this,
      test ?? (__, ___) => true,
    );
  }
}
