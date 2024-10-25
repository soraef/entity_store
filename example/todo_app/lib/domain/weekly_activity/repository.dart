import 'package:entity_store_firestore/entity_store_firestore.dart';

import 'weekly_activity.dart';

class WeeklyActivityRepository extends SubCollectionRepository<WeeklyActivity> {
  WeeklyActivityRepository({
    required super.controller,
    required super.parentRepository,
    required super.parentDocumentId,
  });

  @override
  WeeklyActivity fromJson(Map<String, dynamic> json) {
    return WeeklyActivity.fromJson(json);
  }

  @override
  String idToString(String id) {
    return id;
  }

  @override
  Map<String, dynamic> toJson(WeeklyActivity entity) {
    return entity.toJson();
  }

  @override
  String get collectionId => "WeeklyActivity";
}
