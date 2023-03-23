part of '../firestore_repository.dart';

class FirestoreSaveOptions implements ISaveOptions {
  final bool merge;

  FirestoreSaveOptions(this.merge);
}
