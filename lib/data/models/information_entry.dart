import 'package:efa_smartconnect_modbus_demo/shared/utils/callbacks.dart';

abstract base class InformationEntry<T extends Object> {
  AsyncValueChanged<T>? onSaved;

  InformationEntry({
    required this.description,
    required this.value,
    this.editable = false,
    this.onSaved,
  }) : tempValue = value;

  /// The description of the information entry
  final String description;

  /// The value of the information entry
  T? value;

  /// The temporory value of the information entry during the editing process
  T? tempValue;

  Future<void> triggerSave() async {
    var arg = tempValue;
    if (arg == null) {
      return;
    }
    await onSaved?.call(arg);
    value = arg;
  }

  /// Whether the information entry is editable
  final bool editable;
}

final class StringInformationEntry extends InformationEntry<String> {
  StringInformationEntry({
    required super.description,
    required super.value,
    super.editable,
    super.onSaved,
  });
}

final class IntInformationEntry extends InformationEntry<int> {
  IntInformationEntry({
    required super.description,
    required super.value,
    super.editable,
    super.onSaved,
    this.min,
    this.max,
  });

  /// The minimum value of the information entry
  final int? min;

  /// The maximum value of the information entry
  final int? max;
}

final class DateInformationEntry extends InformationEntry<DateTime> {
  DateInformationEntry({
    required super.description,
    required super.value,
    super.editable,
    super.onSaved,
    this.min,
    this.max,
    this.initial,
  });

  /// The minimum value of the datetime information
  final DateTime? min;

  /// The maximum value of the datetime information
  final DateTime? max;

  /// The initial value of the datetime information
  final DateTime? initial;
}

// final class TimeInformationEntry extends InformationEntry<TimeOfDay> {
//   TimeInformationEntry({
//     required super.description,
//     required super.value,
//     super.editable,
//     super.onSaved,
//     this.min,
//     this.max,
//     this.initial,
//   });

//   /// The minimum value of the datetime information
//   final DateTime? min;

//   /// The maximum value of the datetime information
//   final DateTime? max;

//   /// The initial value of the datetime information
//   final DateTime? initial;
// }

final class EnumInformationEntry<T extends Enum> extends InformationEntry<T> {
  EnumInformationEntry({
    required super.description,
    required super.value,
    required this.values,
    super.editable,
    super.onSaved,
  });

  final List<T> values;
}
