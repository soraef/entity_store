part of "../store.dart";

abstract class Id {
  final String value;

  const Id(this.value);

  @override
  bool operator ==(Object other) =>
      other is Id && other.runtimeType == runtimeType && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return "$runtimeType($value)";
  }
}

class CommonId extends Id {
  CommonId(super.value);

  /// Same ID in the application
  factory CommonId.singleton() {
    return CommonId("singleton_id");
  }
}
