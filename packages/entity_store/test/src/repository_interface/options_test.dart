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
}
