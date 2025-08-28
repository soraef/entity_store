# EntityStore エコシステム

## 概要

**EntityStore**は、エンティティ中心の設計思想に基づく、Flutter アプリケーション開発のための包括的な状態管理エコシステムです。ビジネスロジックを不変なエンティティに封じ込め、リポジトリパターンによる抽象化されたデータアクセス、そしてリアクティブなUI同期を実現します。

### 🎯 設計思想

EntityStoreは以下の3つの核となる思想に基づいて設計されています：

1. **エンティティファースト**: アプリケーションの中核となるビジネスオブジェクト（エンティティ）を中心とした設計
2. **不変性の原則**: 状態変更は新しいインスタンスの生成によってのみ行い、予期せぬ副作用を防止
3. **リアクティブな同期**: データの変更がUIに自動的に反映される、シームレスな開発体験

## 📦 パッケージ構成

EntityStoreエコシステムは、用途に応じて選択できる3つのパッケージで構成されています：

### 🏛️ entity_store (コアパッケージ)
```yaml
dependencies:
  entity_store: ^6.0.0-dev.13
```
- **役割**: エンティティベース状態管理の基盤機能
- **機能**: Entity抽象化、リアクティブUI同期、基本的なリポジトリパターン
- **適用場面**: インメモリでの状態管理、プロトタイピング、テスト環境

### 🔥 entity_store_firestore
```yaml
dependencies:
  entity_store_firestore: ^6.0.0-dev.15
```
- **役割**: Firebase Firestore との統合
- **機能**: クラウド同期、リアルタイム更新、オフライン対応、トランザクション処理
- **適用場面**: マルチデバイス同期、リアルタイムコラボレーション、スケーラブルなWebアプリ

### 💾 entity_store_sembast  
```yaml
dependencies:
  entity_store_sembast: ^6.0.0-dev.13
```
- **役割**: Sembast（NoSQLローカルDB）との統合
- **機能**: 高性能ローカルストレージ、複雑なクエリ、データ暗号化対応
- **適用場面**: オフラインファースト、高速ローカル処理、プライバシー重視アプリ

## ✨ 主要メリット

### 🚀 開発効率の向上
```dart
// シンプルなエンティティ操作
final todo = context.watchOne<int, Todo>(todoId)!;
return CheckboxListTile(
  title: Text(todo.name),
  value: todo.isDone,
  onChanged: (value) => todoRepository.save(todo.toggle()),
);
```

### 🔄 自動UI同期
エンティティの変更がUI全体に自動的に反映されます。複雑な状態管理コードを書く必要がありません。

### 🏗️ 柔軟なアーキテクチャ
```dart
// 開発時：インメモリ
final repository = TodoRepository(controller, InMemoryStorageHandler());

// 本番環境：Firestore
final repository = TodoFirestoreRepository(controller, firestore);

// ローカル重視：Sembast
final repository = TodoSembastRepository(controller, database);
```

### 🔒 型安全性
TypeScriptライクな型安全性により、コンパイル時にエラーを検出できます。

## 🎯 使用例：Todoアプリケーション

### エンティティの定義
```dart
class Todo implements Entity<int> {
  @override
  final int id;
  final String name;
  final bool isDone;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.name,
    required this.isDone,
    required this.createdAt,
  });

  // 新しいTodoを作成
  factory Todo.create(int id, String name) {
    return Todo(
      id: id,
      name: name,
      isDone: false,
      createdAt: DateTime.now(),
    );
  }

  // 完了状態をトグル
  Todo toggle() => Todo(
    id: id,
    name: name,
    isDone: !isDone,
    createdAt: createdAt,
  );

  // 名前を更新
  Todo rename(String newName) => Todo(
    id: id,
    name: newName,
    isDone: isDone,
    createdAt: createdAt,
  );
}
```

### リポジトリの実装（Firestore版）
```dart
class TodoFirestoreRepository extends FirestoreRepository<int, Todo> {
  TodoFirestoreRepository(super.controller, super.instance);

  @override
  String get collectionId => 'todos';

  @override
  String idToString(int id) => id.toString();

  @override
  Todo fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      name: json['name'] as String,
      isDone: json['isDone'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson(Todo entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'isDone': entity.isDone,
      'createdAt': entity.createdAt.toIso8601String(),
    };
  }
}
```

### UIの実装
```dart
class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 全てのTodoを監視
    final todos = context.watchAll<int, Todo>();
    
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos.values.elementAt(index);
        return TodoTile(todoId: todo.id);
      },
    );
  }
}

class TodoTile extends StatelessWidget {
  final int todoId;
  
  const TodoTile({required this.todoId});

  @override
  Widget build(BuildContext context) {
    // 特定のTodoを監視
    final todo = context.watchOne<int, Todo>(todoId);
    
    if (todo == null) return const SizedBox.shrink();
    
    return ListTile(
      title: Text(todo.name),
      leading: Checkbox(
        value: todo.isDone,
        onChanged: (_) {
          // エンティティの更新（自動UI同期）
          todoRepository.save(todo.toggle());
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          // エンティティの削除（自動UI更新）
          todoRepository.deleteById(todo.id);
        },
      ),
    );
  }
}
```

### アプリケーションのセットアップ
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EntityStoreProviderScope(
      entityStoreNotifier: entityStoreNotifier,
      child: MaterialApp(
        title: 'EntityStore Todo',
        home: TodoHomePage(),
      ),
    );
  }
}
```

## 🎨 高度な機能

### リアクティブクエリ
```dart
// 未完了のTodoのみを監視
final activeTodos = context.watchAll<int, Todo>(
  (todo) => !todo.isDone,
);

// 完了済みTodoの数を監視
final completedCount = context.selectAll<int, Todo, int>(
  (todos) => todos.values.where((todo) => todo.isDone).length,
);
```

### 効率的なデータフェッチング
```dart
// ページネーション対応
final todos = await todoRepository
  .query()
  .orderBy('createdAt', descending: true)
  .limit(20)
  .findAll();

// 条件付き検索
final urgentTodos = await todoRepository
  .query()
  .where('priority', isEqualTo: 'high')
  .where('isDone', isEqualTo: false)
  .findAll();
```

### トランザクション処理（Firestore）
```dart
await todoRepository.transaction((transaction) async {
  final todo = await transaction.findById(todoId);
  if (todo != null) {
    await transaction.save(todo.toggle());
    await transaction.save(createLogEntry(todo));
  }
});
```

## 🔧 導入手順

### 1. パッケージの選択と追加
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 基本パッケージ（必須）
  entity_store: ^6.0.0-dev.13
  
  # 用途に応じて選択
  entity_store_firestore: ^6.0.0-dev.15  # クラウド同期
  entity_store_sembast: ^6.0.0-dev.13    # ローカルDB
```

### 2. 基本セットアップ
```dart
// エンティティストアの初期化
final entityStoreNotifier = EntityStoreNotifier();
final entityStoreController = EntityStoreController(entityStoreNotifier);

// リポジトリのセットアップ（例：Firestore）
final firestore = FirebaseFirestore.instance;
final todoRepository = TodoFirestoreRepository(
  entityStoreController,
  firestore,
);
```

### 3. 依存性注入（推奨）
```dart
// Riverpod を使用した例
final entityStoreProvider = Provider((ref) => EntityStoreNotifier());

final entityStoreControllerProvider = Provider((ref) => 
  EntityStoreController(ref.watch(entityStoreProvider)));

final todoRepositoryProvider = Provider((ref) => 
  TodoFirestoreRepository(
    ref.watch(entityStoreControllerProvider),
    FirebaseFirestore.instance,
  ));
```

## 🌟 パッケージ選択ガイド

| 要件                           | 推奨パッケージ           | 理由                               |
| ------------------------------ | ------------------------ | ---------------------------------- |
| 🧪 プロトタイピング・学習       | `entity_store`           | シンプル、軽量、学習コスト低       |
| 🌐 リアルタイムコラボレーション | `entity_store_firestore` | 自動同期、スケーラビリティ         |
| 📱 オフラインファーストアプリ   | `entity_store_sembast`   | 高速、オフライン対応、プライバシー |
| 🏢 エンタープライズアプリ       | 組み合わせ使用           | 用途に応じたハイブリッド構成       |

## 🚀 次のステップ

1. **[クイックスタートガイド](./docs/getting-started.md)** - 5分でEntityStoreを体験
2. **[アーキテクチャガイド](./docs/architecture.md)** - 設計思想の詳細解説
3. **[ベストプラクティス](./docs/best-practices.md)** - 実践的な開発ノウハウ
4. **[マイグレーションガイド](./docs/migration.md)** - 既存プロジェクトからの移行

## 🤝 コミュニティ

- **GitHub**: [soraef/entity_store](https://github.com/soraef/entity_store)
- **Discord**: [EntityStore Community](https://discord.gg/entitystore)
- **Issues**: バグ報告・機能要望は [GitHub Issues](https://github.com/soraef/entity_store/issues)

## 📄 ライセンス

このプロジェクトは [MIT License](LICENSE) の下で公開されています。 