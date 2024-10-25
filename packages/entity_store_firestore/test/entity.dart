import 'package:entity_store/entity_store.dart';
import 'package:type_result/src/result.dart';

class User extends Entity {
  @override
  final String id;
  final String name;
  final int age;

  User({
    required this.id,
    required this.name,
    required this.age,
  });

  @override
  String toString() {
    return "User(id: $id, name: $name, age: $age)";
  }
}

final userConverter = EntityJsonConverter<User>(
  fromJson: (json) => User(
    id: json["id"],
    name: json["name"],
    age: json["age"],
  ),
  toJson: (e) => {
    "id": e.id,
    "name": e.name,
    "age": e.age,
  },
);

class Store with EntityStoreMixin {
  EntityStore state = EntityStore.empty();

  @override
  void update(Updater<EntityStore> updater) {
    state = updater(state);
  }

  @override
  EntityStore get value => state;
}

final users = [
  User(id: "1", name: "aaa", age: 1),
  User(id: "2", name: "aab", age: 1),
  User(id: "3", name: "aba", age: 1),
  User(id: "4", name: "abb", age: 2),
  User(id: "5", name: "baa", age: 2),
  User(id: "6", name: "bab", age: 2),
  User(id: "7", name: "bba", age: 3),
  User(id: "8", name: "bbb", age: 3),
  User(id: "9", name: "aac", age: 3),
  User(id: "10", name: "aca", age: 4),
];

class InMemoryLocalStorageHandler implements ILocalStorageHandler {
  final Map<String, String> _map = {};

  @override
  Future<Result<void, Exception>> clear() {
    _map.clear();
    return Future.value(Result.ok(null));
  }

  @override
  Future<Result<void, Exception>> delete(String key) {
    _map.remove(key);
    return Future.value(Result.ok(null));
  }

  @override
  Future<Result<String?, Exception>> load(String key) {
    return Future.value(Result.ok(_map[key]));
  }

  @override
  Future<Result<void, Exception>> save(String key, String value) {
    _map[key] = value;
    return Future.value(Result.ok(null));
  }
}

class UserRepo extends LocalStorageRepository<User> {
  UserRepo(super.controller, super.localStorageHandler);

  @override
  User fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      age: json["age"],
    );
  }

  @override
  Map<String, dynamic> toJson(User entity) {
    return {
      "id": entity.id,
      "name": entity.name,
      "age": entity.age,
    };
  }
}
