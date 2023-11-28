part of '../entity_store.dart';

/// An abstract class representing an entity with a unique identifier.
///
/// The `Entity` class provides a common interface for entities in the entity store.
/// It requires implementing classes to define a getter for the `id` property,
/// which represents the unique identifier of the entity.
///
/// Example usage:
/// ```dart
/// class User extends Entity<int> {
///  final int id;
///  final String name;
///  final String email;
///
///  User({
///   required this.id,
///   required this.name,
///   required this.email,
///  });
/// }
/// ```
abstract class Entity<Id> {
  /// The unique identifier of the entity.
  Id get id;
}

class EntityJsonConverter<Id, E extends Entity<Id>> {
  final E Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(E) toJson;

  EntityJsonConverter({
    required this.fromJson,
    required this.toJson,
  });
}
