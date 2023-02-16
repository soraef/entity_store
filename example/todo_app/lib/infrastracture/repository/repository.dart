import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/domain/todo/repository.dart';
import 'package:todo_app/domain/user/repository.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

final repoRemoteFactory = Provider(
  (ref) => FirestoreRepoFactory.init(
    FirestoreRepoFactorySettings.init(ref.read(entityStoreController))
        .regist(todoCollectionType)
        .regist(userCollectionType),
    FirebaseFirestore.instance,
  ),
);

final repoInMemoryFactory = Provider(
  (ref) => InMemoryRepositoryFactory(ref.read(entityStoreController)),
);
