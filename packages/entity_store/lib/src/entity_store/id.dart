part of '../entity_store.dart';

/// An abstract class representing an ID for an entity in the entity store.
///
/// The [Id] class provides a base implementation for creating unique identifiers
/// for entities in the entity store. It contains a single property, [value],
/// which stores the actual value of the ID.
///
/// The [Id] class overrides the `==` operator to compare two IDs based on their
/// runtime type and value. It also overrides the `hashCode` getter to generate
/// a hash code based on the ID's value. The [toString] method is overridden to
/// provide a string representation of the ID.
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

/// An abstract class representing an integer-based ID.
///
/// This class provides a base implementation for integer-based IDs used in an entity store.
/// It defines equality, hash code, and string representation methods.
abstract class IntId {
  final int value;

  /// Constructs an [IntId] with the given [value].
  const IntId(this.value);

  @override
  bool operator ==(Object other) =>
      other is IntId &&
      other.runtimeType == runtimeType &&
      other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return "$runtimeType($value)";
  }
}
