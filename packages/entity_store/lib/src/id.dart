import 'package:equatable/equatable.dart';

abstract class Id extends Equatable {
  final String value;

  const Id(this.value);

  @override
  List<Object?> get props => [value];
}
