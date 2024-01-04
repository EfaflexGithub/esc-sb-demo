import 'package:get/get.dart';

class ControlInput {
  final String description;

  final bool virtual;

  final String? connector;

  final String? label;

  RxnBool enabled;

  ControlInput({
    required this.description,
    this.virtual = false,
    this.connector,
    this.label,
    bool? enabled,
  }) : enabled = RxnBool(enabled);

  @override
  String toString() => description;
}
