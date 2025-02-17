[English](/docs/entity_store/en/README.md) | [日本語](/docs/entity_store/ja/README.md)

# EntityStoreパッケージ
## はじめに
EntityStoreは、エンティティを中心とした状態管理を提供することで、Flutterアプリケーションの開発を強化します。このライブラリは、アプリケーションのビジネスロジックをイミュータブルなエンティティにカプセル化し、一元化された状態管理を通じてUIの整合性を保ちます。

以下のTodoTileコンポーネントの例は、EntityStoreがどのようにしてUIコンポーネントと状態を結びつけるかを示しています。

```dart
class TodoTile extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    // 特定のTodoを監視
    final todo = context.watchOne<int, Todo>(todoId)!;

    // Todoの完了状態をトグル
    return CheckboxListTile(
      title: Text(todo.name),
      value: todo.isDone,
      onChanged: (bool? value) {
        if (value != null) {
          
          todoRepository.save(todo.toggle());
        }
      },
    );
  }
}
```


## 特徴
- **リアクティブなUI同期**: EntityStoreは、状態の変更をリアクティブにUIに反映させます。上記のコード例では、watchOneメソッドを使用して特定のTodoエンティティを監視し、その状態が変更されるとチェックボックスの表示が更新されます。
- **簡潔な状態更新**: エンティティの状態は、操作が必要な時にのみ新しいインスタンスを通じて更新されます。Todoの完了状態をトグルすることは、todo.toggle()を呼び出すことで簡単に実行され、その結果はリポジトリを通じて永続化されます。
- **エンティティの中心的な取り扱い**: EntityStoreは、アプリケーションのコアな部分を形成するエンティティに焦点を当てており、これにより開発者はビジネスロジックに集中することができます。
- **データベースの柔軟な統合**: EntityStoreは外部データソースとの統合を容易にします。リポジトリの実装を入れ替えるだけで、Firebase Firestore、ローカルデータベース、またはその他のデータストレージとの連携が可能です。
- **ボイラープレートの削減**: 予め用意されたリポジトリの実装により、開発者は繰り返しのデータベース操作コードを書く必要がなくなります。これにより、開発プロセスが加速し、アプリケーションのメンテナンスが容易になります。

## インストール
EntityStoreパッケージをFlutterプロジェクトに導入するには、`pubspec.yaml`ファイルに以下を追加します。

```yaml
dependencies:
  entity_store: 最新のバージョン
```

## 使い方
以下のサンプルコードは、EntityStoreを使用したTodoアプリケーションの実装例を示しています。

### Todoエンティティの定義

エンティティは、アプリケーションのコアなビジネスロジックをカプセル化し、それぞれ一意の識別子（ID）を持つオブジェクトです。これにより、アプリケーション全体でエンティティが識別可能となり、データの整合性を保ちやすくなります。EntityStoreでは、エンティティはイミュータブルな設計が求められます。これは、エンティティの状態が変更された場合にUIがその変更を検出し、適切に反映するために重要です。

`Todo`クラスはこの概念を実装した例です。ここでは、各`Todo`項目は一意のID、名前、完了状態の属性を持ちます。新しい`Todo`項目を作成するためのファクトリメソッドとして`create`を定義しており、これによりランダムな名前で新しい`Todo`インスタンスを生成することができます。`toggle`メソッドは、`Todo`の完了状態を切り替えるために使用され、このメソッドを呼び出すことで、新しい状態を持つ新たな`Todo`インスタンスが返されます。

```dart
class Todo implements Entity<int> {
  // エンティティの属性はイミュータブルである必要があります。
  @override
  final int id;
  final String name;
  final bool isDone;

  Todo(this.id, this.name, this.isDone);

  // 新規Todoエンティティの生成
  factory Todo.create(int id) {
    return Todo(
      id,
      getRandomTodoName(),
      false,
    );
  }

  // Todoエンティティの完了状態を切り替える
  Todo toggle() {
    return Todo(
      id,
      name,
      !isDone,
    );
  }
}
```

このイミュータブルな設計アプローチにより、`Todo`の各インスタンスは再利用可能であり、状態の変更は新しいインスタンスの生成を通じてのみ行われるため、予期せぬ副作用を防ぎ、より予測可能な状態管理が可能になります。また、エンティティの変更を検知してUIを更新する際の複雑さを軽減し、アプリケーションのメンテナンス性を高めます。

### Todoリポジトリの実装
EntityStoreの強力な機能の一つに、リポジトリパターンの実装があります。このパターンに従い、`TodoRepository` は `LocalStorageRepository` を継承しており、継承されたメソッドをオーバーライドすることで、独自のエンティティの保存、読み込み、削除の処理を定義できます。

`TodoRepository`は`Todo`エンティティの`LocalStorageRepository`の具体的な実装です。JSONデータの読み込みと保存のための`fromJson`と`toJson`メソッドをオーバーライドすることで、エンティティとデータストレージ間の変換を簡単に行えます。

```dart
class TodoRepository extends LocalStorageRepository<int, Todo> {
  TodoRepository(super.controller, super.localStorageHandler);

  @override
  Todo fromJson(Map<String, dynamic> json) {
    // JSONからTodoエンティティを作成
  }

  @override
  Map<String, dynamic> toJson(Todo entity) {
    // TodoエンティティをJSONに変換
  }
}
```

#### LocalStorageHandlerについて
EntityStoreパッケージは、デフォルトで`InMemoryStorageHandler`を提供しており、これはデータをメモリ上にのみ保持するシンプルなストレージハンドラです。これにより、開発中やテスト中に状態を簡単に管理できます。もちろん、実際のアプリケーションでは、データをデバイスのローカルストレージに保存するために、カスタムの`LocalStorageHandler`を実装することが可能です。

```dart
class InMemoryStorageHandler extends LocalStorageHandler {
  // メモリ上のデータ操作
}
```

## EntityStoreのセットアップ

EntityStoreをセットアップするためには、以下のように`EntityStoreNotifier`や`EntityStoreController`を初期化し、それらをリポジトリに関連付ける必要があります。

```dart
final entityStoreNotifier = EntityStoreNotifier();
final entityStoreController = EntityStoreController(entityStoreNotifier);
final storageHandler = InMemoryStorageHandler();
final todoRepository = TodoRepository(entityStoreController, storageHandler);
```

上記のコードスニペットでは、シンプルさを優先してグローバル変数を使用していますが、実際のアプリケーションでは、より堅牢な設計を目指すために依存性注入(DI)を使用することを推奨します。例えば、Riverpodの`Provider`やGetItなどのDIコンテナを使用することで、依存性の解決をより効率的に行い、テストのしやすさやコードの再利用性を向上させることができます。

例:

```dart
final entityStoreProvider = Provider((ref) => EntityStoreNotifier());
final entityStoreControllerProvider = Provider((ref) => EntityStoreController(ref.watch(entityStoreProvider)));
// ...

// アプリケーション内の他の場所で
final entityStoreNotifier = ref.watch(entityStoreProvider);
final entityStoreController = ref.watch(entityStoreControllerProvider);
```

この方法を取り入れることで、アプリケーションの各部分が必要とする依存性をより明確にし、変更や拡張に強い設計を実現することができます。

### UIでの使い方

#### EntityStoreProviderScopeのセットアップ

EntityStoreパッケージの最初のステップは、`EntityStoreProviderScope`をアプリケーションの最上位に設定することです。これにより、アプリケーション全体で状態の変更を監視し、共有する基盤が作られます。

```dart
class MyApp extends StatelessWidget {
  // ...

  @override
  Widget build(BuildContext context) {
    // EntityStoreProviderScopeをアプリのルートに配置
    return EntityStoreProviderScope(
      entityStoreNotifier: entityStoreNotifier,
      child: MaterialApp(
        // ...
      ),
    );
  }
}
```

#### 状態の監視とUIの更新

`selectAll`を使用して、全てのTodoエンティティのIDを取得し、リストとしてUIに表示することができます。これにより、Todoリスト全体を監視し、新しいTodoが追加された際にリストを更新することができます。
`context.watchOne`は特定のエンティティを監視します。これらを利用することで、状態の変更がUIに反映されます。

```dart
class MyHomePage extends StatefulWidget {
  // ...

  @override
  Widget build(BuildContext context) {
    // 全てのTodoのIDを取得
    final todoIds = context.selectAll<int, Todo, List<int>>(
      (value) => value.ids.toList(),
    );

    // ...
  }
}
```

#### エンティティの操作とUIの整合性

リポジトリを介してエンティティを操作すると、`EntityStore`内の状態が更新され、関連するUIが自動的に更新されます。

```dart
class TodoTile extends StatelessWidget {
  // ...

  @override
  Widget build(BuildContext context) {
    // 特定のTodoを監視
    final todo = context.watchOne<int, Todo>(todoId);

    // Todoの完了状態をトグル
    return CheckboxListTile(
      title: Text(todo.name),
      value: todo.isDone,
      onChanged: (bool? value) {
        if (value != null) {
          // Repositoryを通じてエンティティを更新
          todoRepository.save(todo.toggle());
        }
      },
    );
  }
}
```


## 状態管理メソッドの詳細と使用例

EntityStoreで提供される`watch`, `select`, `read`メソッドは、アプリケーションの状態を監視し、UIを適切に更新するための重要なツールです。これらのメソッドを用いて、アプリケーションの状態とUIの同期を保ちます。

### watchメソッドの使用例

`watchAll`メソッドを使用して、未完了のTodoのみをリアルタイムで監視し、変更があるたびにリストを更新することができます。

```dart
final activeTodos = context.watchAll<int, Todo>(
  (todo) => !todo.isDone,
);

ListView.builder(
  itemCount: activeTodos.length,
  itemBuilder: (context, index) {
    final todo = activeTodos.values.elementAt(index);
    return ListTile(
      title: Text(todo.name),
      leading: Checkbox(
        value: todo.isDone,
        onChanged: (bool? checked) {
          // Todoの完了状態を更新するロジック
        },
      ),
    );
  },
);
```

`watchOne`メソッドを使用して、特定のTodoの状態変更を監視し、そのTodoのみを更新します。

```dart
final todo = context.watchOne<int, Todo>(todoId);

if (todo != null) {
  return CheckboxListTile(
    title: Text(todo.name),
    value: todo.isDone,
    onChanged: (bool? newValue) {
      // Todoの状態を更新するロジック
    },
  );
}
```

### selectメソッドの使用例

`selectAll`メソッドを使用して、Todoリストの中で特定のデータ（例えば、名前だけ）に興味がある場合に、それらのデータのみを取得して表示することができます。

```dart
final todoNames = context.selectAll<int, Todo, List<String>>(
  (todos) => todos.values.map((todo) => todo.name).toList(),
);

ListView(
  children: todoNames.map((name) => Text(name)).toList(),
);
```

`selectOne`メソッドを使用して、特定のTodoの名前が変更された場合にのみ、そのTodoの名前を表示するWidgetを更新します。

```dart
final todoName = context.selectOne<int, Todo, String>(
  todoId,
  (todo) => todo.name,
);

Text(todoName ?? 'No name');
```

### readメソッドの使用例

`readAll`メソッドを使用して、画面の初期ロード時に一度だけ全てのTodoを取得し、それ以降はリビルドをトリガーせずにデータを使用します。

```dart
final allTodos = context.readAll<int, Todo>();

// 初期ロード時に全Todoを表示
ListView(
  children: allTodos.values.map((todo) => Text(todo.name)).toList(),
);
```

`readOne`メソッドを使用して、ユーザーのアクションによる一回のみのデータ読み取りを行い、例えばダイアログにTodoの詳細を表示する際に使用します。

```dart
final todo = context.readOne<int, Todo>(todoId);

// ユーザーのアクションによって表示するダイアログ
showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: Text(todo?.name ?? 'No name'),
      content: Text('Completed: ${todo?.isDone}'),
    );
  },
);
```

これらのメソッドを利用することで、EntityStore内の状態とUIの同期を保ちつつ、必要に応じて効率的な状態の読み取りや更新を行うことができます。

### Repositoryの使い方

リポジトリは、データソースの操作を抽象化し、アプリケーションのビジネスロジックをデータアクセスコードから分離するために設計されています。EntityStoreでは、リポジトリを介して行われるエンティティの操作がリアクティブにUIに反映されるようになっています。つまり、リポジトリでエンティティが保存、更新、または削除されると、これらの変更は自動的にUIに伝播され、ユーザーは最新の状態を直ちに視覚的に確認できます。

この動作は、watch, selectなどのリアクティブなメソッドと組み合わせて使用することで、EntityStoreが管理する状態とUIコンポーネント間の同期を保ちます。このメカニズムは、Entityの変更がリポジトリによって行われた際に、関連するコンポーネントが適切なタイミングで更新を受け取ることを保証します。

EntityStoreパッケージのリポジトリインターフェースを利用して、エンティティに対する様々な操作を行うことができます。以下に、基本的なリポジトリ操作とその使用例を示します。

#### findById

指定されたIDを持つエンティティを取得します。

```dart
// 使用例: IDによるTodoの検索
var result = await todoRepository.findById(todoId);
if (result.isSuccess) {
  var todo = result.success;
  // Todoの処理をここに記述
}
```

#### findAll

全てのエンティティを取得します。

```dart
// 使用例: 特定の条件を満たすすべてのTodoを取得
var result = await todoRepository.query()
  .where('isComplete', isEqualTo: false)
  .findAll();
if (result.isSuccess) {
  var todos = result.success;
  // Todoリストの処理をここに記述
}
```

#### findOne

条件に一致する最初のエンティティを取得します。

```dart
// 使用例: 特定の条件を満たす最初のTodoを検索
var result = await todoRepository.query()
  .where('isComplete', isEqualTo: false)
  .findOne();
if (result.isSuccess) {
  var todo = result.success;
  // Todoの処理をここに記述
}
```

#### count

条件に一致するエンティティの数をカウントします。

```dart
// 使用例: 完了していないTodoの数をカウント
var result = await todoRepository.query()
  .where('isComplete', isEqualTo: false)
  .count();
if (result.isSuccess) {
  var activeCount = result.success;
  // activeCountを使用した処理をここに記述
}
```

#### save

エンティティを保存または更新します。

```dart
// 使用例: 新しいTodoを保存
var newTodo = Todo.create(name: 'New Task');
var result = await todoRepository.save(newTodo);
if (result.isSuccess) {
  // 保存処理の成功をここに記述
}
```

#### delete

エンティティを削除します。

```dart
// 使用例: Todoを削除
var result = await todoRepository.delete(todoId);
if (result.isSuccess) {
  // 削除処理の成功をここに記述
}
```

#### upsert

エンティティが存在しない場合は新しく作成し、存在する場合は更新します。

```dart
// 使用例: Todoのアップサート
var result = await todoRepository.upsert(
  todoId,
  creater: () => Todo.create(name: 'New Task'),
  updater: (existingTodo) => existingTodo.copyWith(isComplete: true),
);
if (result.isSuccess) {
  // アップサート処理の成功をここに記述
}
```

これらの操作を通じて、アプリケーションはEntityStore内のデータを効率的に管理し、データの整合性を維持することができます。

## ライセンス
このプロジェクトはMITライセンスのもとで公開されています。詳細はLICENSEファイルをご覧ください。

