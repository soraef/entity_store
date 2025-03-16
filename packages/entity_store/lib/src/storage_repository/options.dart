part of '../storage_repository.dart';

class StorageFindByIdOptions implements FindByIdOptions, FetchPolicyOptions {
  @override
  FetchPolicy fetchPolicy;

  StorageFindByIdOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class StorageFindOneOptions implements FindOneOptions, FetchPolicyOptions {
  @override
  FetchPolicy fetchPolicy;

  StorageFindOneOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class StorageFindAllOptions implements FindAllOptions, FetchPolicyOptions {
  @override
  FetchPolicy fetchPolicy;

  StorageFindAllOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class StorageUpsertOptions implements UpsertOptions, FetchPolicyOptions {
  @override
  FetchPolicy fetchPolicy;

  StorageUpsertOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class StorageSaveOptions implements SaveOptions {
  bool enableBefore;
  bool enableLoadEntity;

  StorageSaveOptions({
    this.enableBefore = true,
    this.enableLoadEntity = true,
  });
}

class StorageDeleteOptions implements DeleteOptions {
  StorageDeleteOptions();
}

class StorageQueryUpsertOptions implements QueryUpsertOptions {
  StorageQueryUpsertOptions();
}

class StorageCountOptions implements CountOptions {
  StorageCountOptions();
}
