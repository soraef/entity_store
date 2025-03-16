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
    implements FindByIdOptions, FetchPolicyOptions {
  @override
  FetchPolicy fetchPolicy;

  EntityStoreFindByIdOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class EntityStoreFindOneOptions implements FindOneOptions, FetchPolicyOptions {
  @override
  FetchPolicy fetchPolicy;

  EntityStoreFindOneOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class EntityStoreFindAllOptions implements FindAllOptions, FetchPolicyOptions {
  @override
  FetchPolicy fetchPolicy;

  EntityStoreFindAllOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class EntityStoreUpsertOptions implements UpsertOptions, FetchPolicyOptions {
  @override
  FetchPolicy fetchPolicy;

  EntityStoreUpsertOptions({
    this.fetchPolicy = FetchPolicy.persistent,
  });
}

class EntityStoreSaveOptions implements SaveOptions {
  EntityStoreSaveOptions();
}

class EntityStoreDeleteOptions implements DeleteOptions {
  EntityStoreDeleteOptions();
}

class EntityStoreQueryUpsertOptions implements QueryUpsertOptions {
  EntityStoreQueryUpsertOptions();
}

class EntityStoreCountOptions implements CountOptions {
  EntityStoreCountOptions();
}
