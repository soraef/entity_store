import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/application/store/session_store/auth_store.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

import 'firebase_options.dart';
import 'presentation/page/auth/auth_page.dart';
import 'presentation/page/todo/todo_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Sample',
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
    ref.read(debugger);
    final auth = ref.watch(authStore);

    if (!auth.isLogin) {
      return const AuthPage();
    } else {
      return const TodoPage();
    }
  }
}
