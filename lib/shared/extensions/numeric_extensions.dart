import 'package:intl/intl.dart';

extension DoubleExtension on double {
  String toPercentage({int precision = 0}) =>
      NumberFormat.percentPattern('en_US').format(this);

  String get localized => NumberFormat.decimalPattern('en_US').format(this);
}

extension IntExtensions on int {
  String get localized => NumberFormat.decimalPattern('en_US').format(this);
}

extension DateTimeExtensions on DateTime {
  String get localized => DateFormat.yMMMEd('en_US').add_Hms().format(this);
}
