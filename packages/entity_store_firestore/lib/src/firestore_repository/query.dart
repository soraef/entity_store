// ignore_for_file: invalid_use_of_protected_member

part of '../firestore_repository.dart';

class FirestoreRepositoryQuery<Id, E extends Entity<Id>>
    implements IRepositoryQuery<Id, E> {
  final BaseFirestoreRepository<Id, E> _repository;
  @override
  final List<RepositoryFilter> filters;
  @override
  final List<RepositorySort> sorts;
  @override
  final int? limitNum;
  @override
  final Id? startAfterId;

  List<RepositoryFilter> get getFilters => filters;
  List<RepositorySort> get getSorts => sorts;
  int? get getLimit => limitNum;
  Id? get getStartAfterId => startAfterId;

  FirestoreRepositoryQuery._(
    this._repository,
    this.filters,
    this.sorts,
    this.limitNum,
    this.startAfterId,
  );

  const FirestoreRepositoryQuery(this._repository)
      : filters = const [],
        sorts = const [],
        limitNum = null,
        startAfterId = null;

  @override
  FirestoreRepositoryQuery<Id, E> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return FirestoreRepositoryQuery._(
      _repository,
      [
        ...filters,
        if (isEqualTo != null)
          RepositoryFilter(
            field,
            FilterOperator.isEqualTo,
            isEqualTo,
          ),
        if (isNotEqualTo != null)
          RepositoryFilter(
            field,
            FilterOperator.isNotEqualTo,
            isNotEqualTo,
          ),
        if (isLessThan != null)
          RepositoryFilter(
            field,
            FilterOperator.isLessThan,
            isLessThan,
          ),
        if (isLessThanOrEqualTo != null)
          RepositoryFilter(
            field,
            FilterOperator.isLessThanOrEqualTo,
            isLessThanOrEqualTo,
          ),
        if (isGreaterThan != null)
          RepositoryFilter(
            field,
            FilterOperator.isGreaterThan,
            isGreaterThan,
          ),
        if (isGreaterThanOrEqualTo != null)
          RepositoryFilter(
            field,
            FilterOperator.isGreaterThanOrEqualTo,
            isGreaterThanOrEqualTo,
          ),
        if (arrayContains != null)
          RepositoryFilter(
            field,
            FilterOperator.arrayContains,
            arrayContains,
          ),
        if (arrayContainsAny != null)
          RepositoryFilter(
            field,
            FilterOperator.arrayContainsAny,
            arrayContainsAny,
          ),
        if (whereIn != null)
          RepositoryFilter(
            field,
            FilterOperator.whereIn,
            whereIn,
          ),
        if (whereNotIn != null)
          RepositoryFilter(
            field,
            FilterOperator.whereNotIn,
            whereNotIn,
          ),
        if (isNull != null)
          RepositoryFilter(
            field,
            FilterOperator.isNull,
            isNull,
          ),
      ],
      sorts,
      limitNum,
      startAfterId,
    );
  }

  @override
  FirestoreRepositoryQuery<Id, E> orderBy(
    Object field, {
    bool descending = false,
  }) {
    return FirestoreRepositoryQuery<Id, E>._(
      _repository,
      filters,
      [
        ...sorts,
        RepositorySort(
          field,
          descending,
        ),
      ],
      limitNum,
      startAfterId,
    );
  }

  @override
  FirestoreRepositoryQuery<Id, E> limit(int count) {
    return FirestoreRepositoryQuery<Id, E>._(
      _repository,
      filters,
      sorts,
      count,
      startAfterId,
    );
  }

  @override
  FirestoreRepositoryQuery<Id, E> startAfter(Id id) {
    return FirestoreRepositoryQuery<Id, E>._(
      _repository,
      filters,
      sorts,
      limitNum,
      id,
    );
  }

  @override
  bool test(Map<String, dynamic> object) {
    return filters.map((e) => e.test(object)).every((e) => e);
  }

  @override
  Future<List<E>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException(
        'Transaction is not supported in FirestoreRepositoryQuery',
      );
    }

    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

    // ストアからデータを取得
    final objects = _repository.controller
        .getAll<Id, E>()
        .map((e) => _repository.toJson(e))
        .toList();
    final storeEntities = IRepositoryQuery.findEntities(objects, this)
        .map((e) => _repository.fromJson(e))
        .toList();

    // ストアのみの場合
    if (fetchPolicy == FetchPolicy.storeOnly) {
      return storeEntities;
    }

    // ストア優先の場合、ストアにデータがあればそれを返す
    if (fetchPolicy == FetchPolicy.storeFirst) {
      if (storeEntities.isNotEmpty) {
        return storeEntities;
      }
    }

    // Firestoreからデータを取得
    final query = await _buildQueryWithCursor(_repository.collectionRef);
    return await _repository._protectedListAndNotify(query, options);
  }

  @override
  Future<E?> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException(
        'Transaction is not supported in FirestoreRepositoryQuery',
      );
    }

    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

    // ストアからデータを取得
    final objects = _repository.controller
        .getAll<Id, E>()
        .map((e) => _repository.toJson(e))
        .toList();
    final storeEntity = IRepositoryQuery.findEntities(objects, this)
        .map((e) => _repository.fromJson(e))
        .take(1)
        .firstOrNull;

    // ストアのみの場合
    if (fetchPolicy == FetchPolicy.storeOnly) {
      return storeEntity;
    }

    // ストア優先の場合、ストアにデータがあればそれを返す
    if (fetchPolicy == FetchPolicy.storeFirst) {
      if (storeEntity != null) {
        return storeEntity;
      }
    }

    // Firestoreからデータを取得
    final query = await _buildQueryWithCursor(_repository.collectionRef);
    final limitedQuery = query.limit(1);

    final entities =
        await _repository._protectedListAndNotify(limitedQuery, options);
    return entities.isEmpty ? null : entities.first;
  }

  @override
  Future<int> count({
    CountOptions? options,
  }) async {
    try {
      final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

      // ストアのみの場合はストアのデータ数を返す
      if (fetchPolicy == FetchPolicy.storeOnly) {
        final objects = _repository.controller
            .getAll<Id, E>()
            .map((e) => _repository.toJson(e))
            .toList();
        return IRepositoryQuery.findEntities(objects, this).length;
      }

      final query = await _buildQueryWithCursor(_repository.collectionRef);
      final countQuery = query.count();
      final result = await countQuery.get();

      if (result.count == null) {
        throw QueryException('カウント結果が取得できませんでした');
      }

      return result.count!;
    } catch (e) {
      if (e is FirebaseException) {
        throw QueryException('Firestoreカウントに失敗: ${e.code} - ${e.message}');
      }
      throw QueryException('ドキュメント数の取得に失敗: ${e.toString()}');
    }
  }

  @override
  Stream<List<EntityChange<E>>> observeAll({
    ObserveAllOptions? options,
  }) {
    try {
      Query query = _buildQuery(_repository.collectionRef);
      return _repository._protectedObserveCollection(query);
    } catch (e) {
      throw QueryException('Failed to observe collection: ${e.toString()}');
    }
  }

  Future<Query> _buildQueryWithCursor(CollectionReference collectionRef) async {
    Query query = _buildQuery(collectionRef);

    if (startAfterId != null) {
      try {
        // ドキュメントスナップショットを取得してカーソル位置として使用
        final docRef = _repository.getDocumentRef(startAfterId!);
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          query = query.startAfterDocument(docSnapshot);
        } else {
          throw QueryException('カーソルに指定されたドキュメント(ID: $startAfterId)が存在しません');
        }
      } catch (e) {
        if (e is QueryException) rethrow;
        throw QueryException('カーソルの設定に失敗しました: ${e.toString()}');
      }
    }

    return query;
  }

  Query _buildQuery(CollectionReference collectionRef) {
    Query query = collectionRef;

    for (final filter in filters) {
      final fieldPath = filter.field;
      switch (filter.operator) {
        case FilterOperator.isEqualTo:
          query = query.where(fieldPath, isEqualTo: filter.value);
          break;
        case FilterOperator.isNotEqualTo:
          query = query.where(fieldPath, isNotEqualTo: filter.value);
          break;
        case FilterOperator.isLessThan:
          query = query.where(fieldPath, isLessThan: filter.value);
          break;
        case FilterOperator.isLessThanOrEqualTo:
          query = query.where(fieldPath, isLessThanOrEqualTo: filter.value);
          break;
        case FilterOperator.isGreaterThan:
          query = query.where(fieldPath, isGreaterThan: filter.value);
          break;
        case FilterOperator.isGreaterThanOrEqualTo:
          query = query.where(fieldPath, isGreaterThanOrEqualTo: filter.value);
          break;
        case FilterOperator.arrayContains:
          query = query.where(fieldPath, arrayContains: filter.value);
          break;
        case FilterOperator.arrayContainsAny:
          query = query.where(fieldPath, arrayContainsAny: filter.value);
          break;
        case FilterOperator.whereIn:
          query = query.where(fieldPath, whereIn: filter.value);
          break;
        case FilterOperator.whereNotIn:
          query = query.where(fieldPath, whereNotIn: filter.value);
          break;
        case FilterOperator.isNull:
          if (filter.value as bool) {
            query = query.where(fieldPath, isNull: true);
          } else {
            query = query.where(fieldPath, isNull: false);
          }
          break;
      }
    }

    for (final sort in sorts) {
      query = query.orderBy(
        sort.field,
        descending: sort.descending,
      );
    }

    if (limitNum != null) {
      query = query.limit(limitNum!);
    }

    // 注意: startAfterの処理は_buildQueryWithCursorメソッドに移動しました
    // ここではcursorを設定しない基本的なクエリを返します

    return query;
  }
}
