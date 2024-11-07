part of '../storage_repository.dart';

class StorageFindByIdOptions extends FindByIdOptions {
  final bool skipSyncCheck;
  const StorageFindByIdOptions({
    super.fetchPolicy,
    this.skipSyncCheck = false,
  });
}

class StorageFindOneOptions extends FindOneOptions {
  final bool skipSyncCheck;
  const StorageFindOneOptions({
    super.fetchPolicy,
    this.skipSyncCheck = false,
  });
}

class StorageFindAllOptions extends FindAllOptions {
  final bool skipSyncCheck;
  const StorageFindAllOptions({
    super.fetchPolicy,
    this.skipSyncCheck = false,
  });
}

class StorageUpsertOptions extends UpsertOptions {
  final bool skipSyncCheck;
  const StorageUpsertOptions({
    super.fetchPolicy,
    super.useTransaction,
    this.skipSyncCheck = false,
  });
}

class StorageSaveOptions extends SaveOptions {}

class StorageDeleteOptions extends DeleteOptions {}

class StorageObserveAllOptions extends ObserveAllOptions {}

class StorageObserveByIdOptions extends ObserveByIdOptions {}

class StorageQueryUpsertOptions extends QueryUpsertOptions {
  const StorageQueryUpsertOptions({
    super.fetchPolicy,
    super.useTransaction,
  });
}

class StorageCountOptions extends CountOptions {
  final bool skipSyncCheck;
  StorageCountOptions({
    this.skipSyncCheck = false,
  });
}
