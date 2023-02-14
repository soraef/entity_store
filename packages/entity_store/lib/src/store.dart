import 'package:entity_store/entity_store.dart';
import 'package:flutter/material.dart';

typedef Updater<T> = T Function(T prev);

abstract class Updatable<T> {
  T get value;
  void update(Updater<T> updater);
}
