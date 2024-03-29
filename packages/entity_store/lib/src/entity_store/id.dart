part of '../entity_store.dart';

abstract class Id {
  final String value;

  const Id(this.value);

  @override
  bool operator ==(Object other) =>
      other is Id && other.runtimeType == runtimeType && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return "$runtimeType($value)";
  }
}
