part of '../repository_interface.dart';

abstract interface class FindByIdOptions {}

abstract interface class FindOneOptions {}

abstract interface class FindAllOptions {}

abstract interface class UpsertOptions {}

abstract interface class SaveOptions {}

abstract interface class DeleteOptions {}

abstract interface class CountOptions {}

abstract interface class ObserveAllOptions {}

abstract interface class ObserveByIdOptions {}

abstract interface class QueryUpsertOptions {}

class EntityStoreFindByIdOptions
    implements
        FindByIdOptions,
        FetchPolicyOptions,
        BeforeCallbackOptions,
        LoadEntityCallbackOptions {
  @override
  bool enableBefore;

  @override
  FetchPolicy fetchPolicy;

  @override
  bool enableLoadEntity;

  EntityStoreFindByIdOptions({
    this.enableBefore = true,
    this.fetchPolicy = FetchPolicy.persistent,
    this.enableLoadEntity = true,
  });
}

class EntityStoreFindOneOptions
    implements
        FindOneOptions,
        FetchPolicyOptions,
        BeforeCallbackOptions,
        LoadEntityCallbackOptions {
  @override
  bool enableBefore;

  @override
  FetchPolicy fetchPolicy;

  @override
  bool enableLoadEntity;

  EntityStoreFindOneOptions({
    this.enableBefore = true,
    this.fetchPolicy = FetchPolicy.persistent,
    this.enableLoadEntity = true,
  });
}

class EntityStoreFindAllOptions
    implements
        FindAllOptions,
        FetchPolicyOptions,
        BeforeCallbackOptions,
        LoadEntityCallbackOptions {
  @override
  bool enableBefore;

  @override
  FetchPolicy fetchPolicy;

  @override
  bool enableLoadEntity;

  EntityStoreFindAllOptions({
    this.enableBefore = true,
    this.fetchPolicy = FetchPolicy.persistent,
    this.enableLoadEntity = true,
  });
}

class EntityStoreUpsertOptions
    implements
        UpsertOptions,
        FetchPolicyOptions,
        BeforeCallbackOptions,
        LoadEntityCallbackOptions {
  @override
  bool enableBefore;

  @override
  FetchPolicy fetchPolicy;

  @override
  bool enableLoadEntity;

  EntityStoreUpsertOptions({
    this.enableBefore = true,
    this.fetchPolicy = FetchPolicy.persistent,
    this.enableLoadEntity = true,
  });
}

class EntityStoreSaveOptions implements SaveOptions, BeforeCallbackOptions {
  @override
  bool enableBefore;

  EntityStoreSaveOptions({
    this.enableBefore = true,
  });
}

class EntityStoreDeleteOptions implements DeleteOptions, BeforeCallbackOptions {
  @override
  bool enableBefore;

  EntityStoreDeleteOptions({
    this.enableBefore = true,
  });
}

class EntityStoreQueryUpsertOptions
    implements
        QueryUpsertOptions,
        BeforeCallbackOptions,
        LoadEntityCallbackOptions {
  @override
  bool enableBefore;

  @override
  bool enableLoadEntity;

  EntityStoreQueryUpsertOptions({
    this.enableBefore = true,
    this.enableLoadEntity = true,
  });
}

class EntityStoreCountOptions implements CountOptions, BeforeCallbackOptions {
  @override
  bool enableBefore;

  EntityStoreCountOptions({
    this.enableBefore = true,
  });
}
