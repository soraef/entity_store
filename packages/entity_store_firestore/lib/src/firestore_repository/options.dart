part of '../firestore_repository.dart';

class FirestoreSaveOptions extends ISaveOptions {
  final bool merge;

  FirestoreSaveOptions(this.merge);
}

class FirestoreCreateOrUpdateOptions extends ICreateOrUpdateOptions {
  final bool merge;

  FirestoreCreateOrUpdateOptions({
    super.useTransaction = true,
    super.useCache = false,
    this.merge = true,
  });
}

class FirestoreGetOptions extends IGetOptions {
  FirestoreGetOptions({
    super.useCache = false,
  });
}
