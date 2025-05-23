part of '../firestore_repository.dart';

class FirestoreSaveOptions extends EntityStoreSaveOptions
    implements MergeOptions {
  @override
  final bool merge;

  @override
  final List<String> mergeFields;

  FirestoreSaveOptions({
    this.merge = true,
    this.mergeFields = const [],
  });
}

class FirestoreUpsertOptions extends EntityStoreUpsertOptions
    implements MergeOptions, UseTransactionOptions {
  @override
  final bool? merge;

  @override
  final List<String>? mergeFields;

  @override
  final bool useTransaction;

  FirestoreUpsertOptions({
    super.fetchPolicy = FetchPolicy.persistent,
    this.merge,
    this.mergeFields,
    this.useTransaction = false,
  });
}

abstract interface class MergeOptions {
  bool? get merge;
  List<String>? get mergeFields;

  static bool? getMerge(Object? options) {
    return switch (options) { MergeOptions(:final merge) => merge, _ => null };
  }

  static List<String>? getMergeFields(Object? options) {
    return switch (options) {
      MergeOptions(:final mergeFields) => mergeFields,
      _ => null,
    };
  }
}
