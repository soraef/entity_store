part of '../repository_interface.dart';

abstract class IGetOptions {
  final bool useCache;
  IGetOptions({
    this.useCache = false,
  });
}

abstract class ISaveOptions {}

abstract class IDeleteOptions {}

abstract class ICreateOrUpdateOptions {
  final bool useTransaction;
  final bool useCache;
  ICreateOrUpdateOptions({
    this.useTransaction = true,
    this.useCache = false,
  }) {
    assert(!(useTransaction && useCache));
  }
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

class FindByIdOptions {
  final FetchPolicy fetchPolicy;
  const FindByIdOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class FindOneOptions {
  final FetchPolicy fetchPolicy;
  const FindOneOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class FindAllOptions {
  final FetchPolicy fetchPolicy;
  const FindAllOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class UpsertOptions {
  final FetchPolicy fetchPolicy;
  final bool useTransaction;
  const UpsertOptions({
    this.fetchPolicy = FetchPolicy.persistent,
    this.useTransaction = true,
  });
}

class SaveOptions {}

class DeleteOptions {}
