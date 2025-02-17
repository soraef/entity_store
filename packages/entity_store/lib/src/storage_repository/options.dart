part of '../storage_repository.dart';

class StorageFindByIdOptions
    implements FindByIdOptions, FetchPolicyOptions, BeforeCallbackOptions {
  @override
  bool enableBefore;

  @override
  FetchPolicy fetchPolicy;

  StorageFindByIdOptions({
    this.enableBefore = true,
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class StorageFindOneOptions
    implements FindOneOptions, FetchPolicyOptions, BeforeCallbackOptions {
  @override
  bool enableBefore;

  @override
  FetchPolicy fetchPolicy;

  StorageFindOneOptions({
    this.enableBefore = true,
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class StorageFindAllOptions
    implements FindAllOptions, FetchPolicyOptions, BeforeCallbackOptions {
  @override
  bool enableBefore;

  @override
  FetchPolicy fetchPolicy;

  StorageFindAllOptions({
    this.enableBefore = true,
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class StorageUpsertOptions
    implements UpsertOptions, FetchPolicyOptions, BeforeCallbackOptions {
  @override
  bool enableBefore;

  @override
  FetchPolicy fetchPolicy;

  StorageUpsertOptions({
    this.enableBefore = true,
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class StorageSaveOptions
    implements SaveOptions, BeforeCallbackOptions, LoadEntityCallbackOptions {
  @override
  bool enableBefore;

  @override
  bool enableLoadEntity;

  StorageSaveOptions({
    this.enableBefore = true,
    this.enableLoadEntity = true,
  });
}

class StorageDeleteOptions implements DeleteOptions, BeforeCallbackOptions {
  @override
  bool enableBefore;

  StorageDeleteOptions({
    this.enableBefore = true,
  });
}

class StorageQueryUpsertOptions
    implements QueryUpsertOptions, BeforeCallbackOptions {
  @override
  bool enableBefore;

  StorageQueryUpsertOptions({
    this.enableBefore = true,
  });
}

class StorageCountOptions implements CountOptions, BeforeCallbackOptions {
  @override
  bool enableBefore;

  StorageCountOptions({
    this.enableBefore = true,
  });
}
