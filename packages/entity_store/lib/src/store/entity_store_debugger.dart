part of "../store.dart";

abstract class EntityStoreDebugger {
  final Stream<StoreEvent> eventStream;

  EntityStoreDebugger(this.eventStream) {
    eventStream.listen((event) {
      if (kDebugMode) {
        onEvent(event);
      }
    });
  }

  void onEvent(StoreEvent<dynamic, Entity<dynamic>> event);
}

class EntityStorePrintDebugger extends EntityStoreDebugger {
  final bool showEntityDetail;
  EntityStorePrintDebugger(
    super.eventStream, {
    this.showEntityDetail = false,
  });

  @override
  void onEvent(StoreEvent<dynamic, Entity> event) {
    if (event is GetEvent) {
      debugPrint(
        "[GetEvent:${event.entityType}] ${_entityString(
          event.entity,
          showEntityDetail: showEntityDetail,
        )}",
      );
    } else if (event is ListEvent) {
      debugPrint(
        "[ListEvent:${event.entityType}] ${_entitiesString(
          event.entities,
          showEntityDetail: showEntityDetail,
        )}",
      );
    } else if (event is SaveEvent) {
      debugPrint(
        "[SaveEvent:${event.entityType}] ${_entityString(
          event.entity,
          showEntityDetail: showEntityDetail,
        )}",
      );
    } else if (event is DeleteEvent) {
      debugPrint(
        "[DeleteEvent:${event.entityType}] ${event.entityId}",
      );
    }
  }

  String _entitiesString(
    List<Entity> entities, {
    required bool showEntityDetail,
  }) {
    if (showEntityDetail) {
      try {
        final list = entities.map((e) => (e as dynamic).toJson()).toList();
        return _listToString(list);
      } catch (_) {
        return _listToString(entities.map((e) => e.id).toList());
      }
    } else {
      return _listToString(entities.map((e) => e.id).toList());
    }
  }

  String _entityString(
    Entity? entity, {
    required bool showEntityDetail,
  }) {
    if (entity == null) {
      return "";
    }

    if (showEntityDetail) {
      try {
        return _mapToString((entity as dynamic).toJson());
      } catch (_) {
        return entity.id.toString();
      }
    } else {
      return entity.id.toString();
    }
  }

  String _mapToString(Map<String, dynamic> map,
      {int indent = 2, bool isValue = false}) {
    String result = '';
    String indentString = ' ' * indent;
    String childIndentString = " " * (indent - 2);

    result += '${isValue ? "" : childIndentString}{\n';
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        result += '$indentString$key: ';
        result += _mapToString(value, indent: indent + 2, isValue: true);
      } else if (value is List<dynamic>) {
        result += '$indentString$key: ';
        result += _listToString(value, indent: indent + 2, isValue: true);
      } else {
        result += '$indentString$key: $value\n';
      }
    });
    result += '$childIndentString}\n';

    return result;
  }

  String _listToString(List<dynamic> list,
      {int indent = 2, bool isValue = false}) {
    String result = '';
    String indentString = ' ' * indent;
    String childIndentString = " " * (indent - 2);

    result += '${isValue ? "" : childIndentString}[\n';
    for (var value in list) {
      if (value is Map<String, dynamic>) {
        result += _mapToString(value, indent: indent + 2);
      } else if (value is List<dynamic>) {
        result += _listToString(value, indent: indent + 2);
      } else {
        result += '$indentString- $value\n';
      }
    }
    result += '$childIndentString]\n';

    return result;
  }
}
