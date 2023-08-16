import 'package:intl/intl.dart';

extension DoubleExtension on double {
  String toPercentage({int precision = 0}) =>
      NumberFormat.percentPattern('en_US').format(this);

  String get localized => NumberFormat.decimalPattern('en_US').format(this);
}

extension IntExtensions on int {
  String get localized => NumberFormat.decimalPattern('en_US').format(this);
}
