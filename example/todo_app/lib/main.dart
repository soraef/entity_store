import 'package:entity_store/entity_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/domain/auth/entity.dart';
import 'package:todo_app/domain/user/repository.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

import 'domain/user/id.dart';
import 'firebase_options.dart';
import 'presentation/page/auth/auth_page.dart';
import 'presentation/page/task/task_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(debugger);

    // final store = ref.watch(source);
    // final tasks = ref.watch(source).whereType<TaskId, Task>();

    return MaterialApp(
      title: 'Task Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends ConsumerWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref
        .watch(entityStore.select(
          (value) => value.where<CommonId, Auth>(),
        ))
        .atOrNull(0);

    if (auth == null || !auth.isLogin) {
      return const AuthPage();
    } else {
      return const TaskPage();
    }
  }
}
