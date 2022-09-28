import 'package:cloud_firestore/cloud_firestore.dart';

typedef FirestoreWhere<T> = Query<T?> Function(
  CollectionReference<T?> collection,
);
