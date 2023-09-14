import 'dart:convert';

import 'package:entity_store/entity_store.dart';
import 'package:type_result/type_result.dart';

import '../local_storage_repository.dart';

class LocalStorageEntityHander<Id, E extends Entity<Id>> {
  final LocalStorageHandler localStorageHandler;
  LocalStorageEntityHander(
    this.localStorageHandler,
    this.toJson,
    this.fromJson,
  );

  Future<Result<List<E>, Exception>> loadEntityList() async {
    final entityListResult =
        await localStorageHandler.load(_getEntityListKey());
    if (entityListResult.isErr) {
      return Result.err(entityListResult.err);
    }

    final entityListJsonString = entityListResult.ok;
    if (entityListJsonString == null) {
      return Result.ok(<E>[]);
    }

    try {
      return Result.ok((jsonDecode(entityListJsonString) as List<dynamic>)
          .map((e) => fromJson(e))
          .toList());
    } catch (e) {
      return Result.ok(<E>[]);
    }
  }

  Future<Result<void, Exception>> save(E entity) async {
    final currentListResult = await loadEntityList();
    if (currentListResult.isErr) {
      return Result.err(currentListResult.err);
    }

    final currentList = currentListResult.ok;
    final newList = <E>[
      ...currentList.where((e) => e.id != entity.id),
      entity,
    ];

    try {
      final jsonString = jsonEncode(newList.map((e) => toJson(e)).toList());
      final saveResult =
          await localStorageHandler.save(_getEntityListKey(), jsonString);
      return saveResult;
    } on Exception catch (e) {
      return Result.err(e);
    }
  }

  Future<Result<void, Exception>> delete(Id id) async {
    final currentListResult = await loadEntityList();
    if (currentListResult.isErr) {
      return Result.err(currentListResult.err);
    }

    final currentList = currentListResult.ok;
    final newList = <E>[
      ...currentList.where((e) => e.id != id),
    ];

    try {
      final jsonString = jsonEncode(newList.map((e) => toJson(e)).toList());
      final saveResult =
          await localStorageHandler.save(_getEntityListKey(), jsonString);
      return saveResult;
    } on Exception catch (e) {
      return Result.err(e);
    }
  }

  String _getEntityListKey() {
    return E.toString();
  }

  final Map<String, dynamic> Function(E entity) toJson;
  final E Function(Map<String, dynamic> json) fromJson;
}
