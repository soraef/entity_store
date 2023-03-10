import 'package:entity_store_firestore/src/repository_interface.dart';

class FirestoreSaveOptions implements ISaveOptions {
  final bool merge;

  FirestoreSaveOptions(this.merge);
}
