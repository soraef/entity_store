import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class DateTimeConverter implements JsonConverter<DateTime, Timestamp?> {
  const DateTimeConverter();
  @override
  DateTime fromJson(Timestamp? json) {
    return json?.toDate() ?? DateTime.now();
  }

  @override
  Timestamp toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}
