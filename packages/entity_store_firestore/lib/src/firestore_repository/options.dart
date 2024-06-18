part of '../firestore_repository.dart';

class FirestoreSaveOptions extends SaveOptions {
  final bool merge;

  FirestoreSaveOptions(this.merge);
}

class FirestoreCreateOrUpdateOptions extends UpsertOptions {
  final bool merge;

  FirestoreCreateOrUpdateOptions({
    super.useTransaction = true,
    super.fetchPolicy = FetchPolicy.persistent,
    this.merge = true,
  });
}

class FirestoreGetOptions extends IGetOptions {
  FirestoreGetOptions({
    super.useCache = false,
  });
}
