import 'package:entity_store/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FetchPolicyOptions', () {
    test('getFetchPolicy - デフォルト値のテスト', () {
      // nullが渡された場合
      expect(
        FetchPolicyOptions.getFetchPolicy(null),
        equals(FetchPolicy.persistent),
      );

      // FetchPolicyOptionsを実装していないオブジェクトの場合
      expect(
        FetchPolicyOptions.getFetchPolicy(Object()),
        equals(FetchPolicy.persistent),
      );
    });

    test('getFetchPolicy - EntityStoreFindByIdOptionsのテスト', () {
      // persistent (デフォルト値)
      final defaultOptions = EntityStoreFindByIdOptions();
      expect(
        FetchPolicyOptions.getFetchPolicy(defaultOptions),
        equals(FetchPolicy.persistent),
      );

      // storeOnly
      final storeOnlyOptions = EntityStoreFindByIdOptions(
        fetchPolicy: FetchPolicy.storeOnly,
      );
      expect(
        FetchPolicyOptions.getFetchPolicy(storeOnlyOptions),
        equals(FetchPolicy.storeOnly),
      );

      // storeFirst
      final storeFirstOptions = EntityStoreFindByIdOptions(
        fetchPolicy: FetchPolicy.storeFirst,
      );
      expect(
        FetchPolicyOptions.getFetchPolicy(storeFirstOptions),
        equals(FetchPolicy.storeFirst),
      );
    });

    test('getFetchPolicy - EntityStoreFindAllOptionsのテスト', () {
      // persistent (デフォルト値)
      final defaultOptions = EntityStoreFindAllOptions();
      expect(
        FetchPolicyOptions.getFetchPolicy(defaultOptions),
        equals(FetchPolicy.persistent),
      );

      // storeOnly
      final storeOnlyOptions = EntityStoreFindAllOptions(
        fetchPolicy: FetchPolicy.storeOnly,
      );
      expect(
        FetchPolicyOptions.getFetchPolicy(storeOnlyOptions),
        equals(FetchPolicy.storeOnly),
      );

      // storeFirst
      final storeFirstOptions = EntityStoreFindAllOptions(
        fetchPolicy: FetchPolicy.storeFirst,
      );
      expect(
        FetchPolicyOptions.getFetchPolicy(storeFirstOptions),
        equals(FetchPolicy.storeFirst),
      );
    });

    test('getFetchPolicy - EntityStoreFindOneOptionsのテスト', () {
      // persistent (デフォルト値)
      final defaultOptions = EntityStoreFindOneOptions();
      expect(
        FetchPolicyOptions.getFetchPolicy(defaultOptions),
        equals(FetchPolicy.persistent),
      );

      // storeOnly
      final storeOnlyOptions = EntityStoreFindOneOptions(
        fetchPolicy: FetchPolicy.storeOnly,
      );
      expect(
        FetchPolicyOptions.getFetchPolicy(storeOnlyOptions),
        equals(FetchPolicy.storeOnly),
      );

      // storeFirst
      final storeFirstOptions = EntityStoreFindOneOptions(
        fetchPolicy: FetchPolicy.storeFirst,
      );
      expect(
        FetchPolicyOptions.getFetchPolicy(storeFirstOptions),
        equals(FetchPolicy.storeFirst),
      );
    });

    test('getFetchPolicy - EntityStoreUpsertOptionsのテスト', () {
      // persistent (デフォルト値)
      final defaultOptions = EntityStoreUpsertOptions();
      expect(
        FetchPolicyOptions.getFetchPolicy(defaultOptions),
        equals(FetchPolicy.persistent),
      );

      // storeOnly
      final storeOnlyOptions = EntityStoreUpsertOptions(
        fetchPolicy: FetchPolicy.storeOnly,
      );
      expect(
        FetchPolicyOptions.getFetchPolicy(storeOnlyOptions),
        equals(FetchPolicy.storeOnly),
      );

      // storeFirst
      final storeFirstOptions = EntityStoreUpsertOptions(
        fetchPolicy: FetchPolicy.storeFirst,
      );
      expect(
        FetchPolicyOptions.getFetchPolicy(storeFirstOptions),
        equals(FetchPolicy.storeFirst),
      );
    });
  });

  group('BeforeCallbackOptions', () {
    test('getEnableBefore - デフォルト値のテスト', () {
      expect(BeforeCallbackOptions.getEnableBefore(null), isTrue);
      expect(
        BeforeCallbackOptions.getEnableBefore(Object()),
        isTrue,
      );
    });

    test('getEnableBefore - 各Optionsクラスのテスト', () {
      // EntityStoreFindByIdOptions
      expect(
        BeforeCallbackOptions.getEnableBefore(
          EntityStoreFindByIdOptions(enableBefore: false),
        ),
        isFalse,
      );

      // EntityStoreFindAllOptions
      expect(
        BeforeCallbackOptions.getEnableBefore(
          EntityStoreFindAllOptions(enableBefore: false),
        ),
        isFalse,
      );

      // EntityStoreFindOneOptions
      expect(
        BeforeCallbackOptions.getEnableBefore(
          EntityStoreFindOneOptions(enableBefore: false),
        ),
        isFalse,
      );

      // EntityStoreUpsertOptions
      expect(
        BeforeCallbackOptions.getEnableBefore(
          EntityStoreUpsertOptions(enableBefore: false),
        ),
        isFalse,
      );

      // EntityStoreSaveOptions
      expect(
        BeforeCallbackOptions.getEnableBefore(
          EntityStoreSaveOptions(enableBefore: false),
        ),
        isFalse,
      );

      // EntityStoreDeleteOptions
      expect(
        BeforeCallbackOptions.getEnableBefore(
          EntityStoreDeleteOptions(enableBefore: false),
        ),
        isFalse,
      );

      // EntityStoreQueryUpsertOptions
      expect(
        BeforeCallbackOptions.getEnableBefore(
          EntityStoreQueryUpsertOptions(enableBefore: false),
        ),
        isFalse,
      );

      // EntityStoreCountOptions
      expect(
        BeforeCallbackOptions.getEnableBefore(
          EntityStoreCountOptions(enableBefore: false),
        ),
        isFalse,
      );
    });
  });

  group('LoadEntityCallbackOptions', () {
    test('getEnableLoadEntity - デフォルト値のテスト', () {
      expect(LoadEntityCallbackOptions.getEnableLoadEntity(null), isTrue);
      expect(
        LoadEntityCallbackOptions.getEnableLoadEntity(Object()),
        isTrue,
      );
    });

    test('getEnableLoadEntity - 各Optionsクラスのテスト', () {
      // EntityStoreFindByIdOptions
      expect(
        LoadEntityCallbackOptions.getEnableLoadEntity(
          EntityStoreFindByIdOptions(enableLoadEntity: false),
        ),
        isFalse,
      );

      // EntityStoreFindAllOptions
      expect(
        LoadEntityCallbackOptions.getEnableLoadEntity(
          EntityStoreFindAllOptions(enableLoadEntity: false),
        ),
        isFalse,
      );

      // EntityStoreFindOneOptions
      expect(
        LoadEntityCallbackOptions.getEnableLoadEntity(
          EntityStoreFindOneOptions(enableLoadEntity: false),
        ),
        isFalse,
      );

      // EntityStoreUpsertOptions
      expect(
        LoadEntityCallbackOptions.getEnableLoadEntity(
          EntityStoreUpsertOptions(enableLoadEntity: false),
        ),
        isFalse,
      );

      // EntityStoreQueryUpsertOptions
      expect(
        LoadEntityCallbackOptions.getEnableLoadEntity(
          EntityStoreQueryUpsertOptions(enableLoadEntity: false),
        ),
        isFalse,
      );
    });
  });
}
