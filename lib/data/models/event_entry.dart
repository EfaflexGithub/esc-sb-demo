import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventEntry implements Comparable<EventEntry> {
  String code;
  DateTime dateTime;
  int? cycleCounter;
  var title = Rxn<String>();
  var description = Rxn<String>();

  EventEntry({
    required this.code,
    required this.dateTime,
    this.cycleCounter,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventEntry &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          dateTime == other.dateTime &&
          cycleCounter == other.cycleCounter;

  @override
  int get hashCode => code.hashCode ^ dateTime.hashCode ^ cycleCounter.hashCode;

  @override
  int compareTo(EventEntry other) {
    // compare datetime and if equal, compare cycle counter
    if (dateTime != other.dateTime) {
      return dateTime.compareTo(other.dateTime);
    }
    if (cycleCounter != other.cycleCounter) {
      return cycleCounter!.compareTo(other.cycleCounter!);
    }
    return 0;
  }

  @override
  String toString() {
    return '$code on ${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)} at $cycleCounter cycles';
  }
}
