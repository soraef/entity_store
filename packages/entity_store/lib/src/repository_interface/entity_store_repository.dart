part of '../repository_interface.dart';

abstract interface class EntityStoreRepository<Id, E extends Entity<Id>> {
  final EntityStoreController controller;
  EntityStoreRepository(this.controller);

  Map<String, dynamic> toJson(E entity);
  E fromJson(Map<String, dynamic> json);
}

enum FetchPolicy {
  /// Fetch the data from the [EntityStore] first.
  /// If the data is not found, fetch from the persisten.
  storeFirst,

  /// Fetch the data from the [EntityStore] only.
  storeOnly,

  /// Fetch the data from the persistent.
  persistent,
}

abstract interface class FetchPolicyOptions {
  FetchPolicy get fetchPolicy;

  static FetchPolicy getFetchPolicy(Object? options) {
    return switch (options) {
      FetchPolicyOptions(:final fetchPolicy) => fetchPolicy,
      _ => FetchPolicy.persistent,
    };
  }
}

abstract interface class UseTransactionOptions {
  bool get useTransaction;

  static bool getUseTransaction(Object? options) {
    return switch (options) {
      UseTransactionOptions(useTransaction: true) => true,
      _ => false,
    };
  }
}
