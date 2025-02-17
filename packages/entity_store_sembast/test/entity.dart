import 'package:entity_store/entity_store.dart';

// テスト用のエンティティ
class TestUser implements Entity<String> {
  @override
  final String id;
  final String name;
  final int age;

  TestUser({required this.id, required this.name, required this.age});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'age': age};

  factory TestUser.fromJson(Map<String, dynamic> json) => TestUser(
    id: json['id'] as String,
    name: json['name'] as String,
    age: json['age'] as int,
  );
}

// テストデータ
final users = [
  TestUser(id: '1', name: 'User 1', age: 1),
  TestUser(id: '2', name: 'User 2', age: 1),
  TestUser(id: '3', name: 'User 3', age: 1),
  TestUser(id: '4', name: 'User 4', age: 2),
  TestUser(id: '5', name: 'User 5', age: 2),
];
