abstract class Entity<Id> {
  Id get id;
}

abstract class HasMany<Id> {
  List<T> hasMany<T extends Id>();
}

abstract class BelongsToBase {
  Id belongsTo<Id, E extends Entity<Id>>();
}
