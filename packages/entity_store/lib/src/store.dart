typedef Updater<T> = T Function(T prev);

abstract class Updatable<T> {
  T get value;
  void update(Updater<T> updater);
}
