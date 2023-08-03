import 'dart:convert';

import 'package:efa_smartconnect_modbus_demo/data/models/event_entry.dart';
import 'package:isar/isar.dart';

part 'application_event.g.dart';

@collection
@Name('ApplicaitonEvent')
class ApplicationEvent {
  final Id id = Isar.autoIncrement;

  @Index()
  @Name('timestamp')
  final DateTime dateTime;

  @Name('uuid')
  final String uuid;

  @enumerated
  final EventType type;

  @Name('data')
  final String data;

  const ApplicationEvent({
    required this.uuid,
    required this.dateTime,
    required this.type,
    required this.data,
  });

  factory ApplicationEvent.fromDoorControlEvent({
    required String uuid,
    required EventEntry event,
  }) {
    var dateTime = event.dateTime;
    var type = EventType.doorControl;
    var data = json.encode({
      "cycles": event.cycleCounter,
      "code": event.code,
    });

    return ApplicationEvent(
      uuid: uuid,
      dateTime: dateTime,
      type: type,
      data: data,
    );
  }
}

enum EventType {
  smartDoorService,
  doorControl,
}
