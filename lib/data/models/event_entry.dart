class EventEntry {
  String code;
  DateTime dateTime;
  int? cycleCounter;
  String? title;
  String? description;

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
}
