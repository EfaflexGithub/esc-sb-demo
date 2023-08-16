import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get localized => DateFormat.yMMMEd('en_US').add_Hms().format(this);

  DateTime copyWithTimeOfDay(TimeOfDay timeOfDay) {
    return copyWith(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }
}

extension TimeOfDayExtensions on TimeOfDay {
  String toFormattedString() => '$hour:${minute.toString().padLeft(2, '0')}';
}
