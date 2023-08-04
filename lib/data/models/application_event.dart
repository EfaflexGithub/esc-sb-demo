import 'package:efa_smartconnect_modbus_demo/data/models/event_entry.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/numeric_extensions.dart';
import 'package:isar/isar.dart';

part 'application_event.g.dart';

@collection
@Name('ApplicaitonEvent')
class ApplicationEvent {
  final Id id = Isar.autoIncrement;

  @enumerated
  final Severity severity;

  @Index()
  @Name('timestamp')
  final DateTime dateTime;

  @Name('uuid')
  final String uuid;

  @enumerated
  final EventType type;

  @Name('data')
  final List<String> data;

  Future<String> getMessage() async {
    if (type == EventType.smartDoorService) {
      SmartDoorServiceEvent event =
          SmartDoorServiceEvent.values[int.parse(data[0])];
      return event.toString();
    }
    if (type == EventType.doorControl) {
      //TODO query event description from rest api
      await Future.delayed(const Duration(milliseconds: 100));
      return '${data[1]} at ${int.parse(data[0]).localized} cycles';
    }
    throw UnimplementedError('unknown type');
  }

  const ApplicationEvent({
    required this.severity,
    required this.uuid,
    required this.dateTime,
    required this.type,
    required this.data,
  });

  factory ApplicationEvent.fromSmartDoorServiceEvent({
    required String uuid,
    required SmartDoorServiceEvent event,
    DateTime? dateTime,
  }) {
    var dateTime_ = dateTime ?? DateTime.now();
    var severity = switch (event) {
      SmartDoorServiceEvent.connectionLost => Severity.error,
      SmartDoorServiceEvent.connectionEstablished => Severity.info,
    };
    var data = event.index.toString();

    return ApplicationEvent(
      severity: severity,
      uuid: uuid,
      dateTime: dateTime_,
      type: EventType.smartDoorService,
      data: [data],
    );
  }

  factory ApplicationEvent.fromDoorControlEvent({
    required String uuid,
    required EventEntry event,
  }) {
    var dateTime = event.dateTime;
    var type = EventType.doorControl;
    var data = [
      event.cycleCounter.toString(),
      event.code,
    ];

    return ApplicationEvent(
      severity: Severity.warning,
      uuid: uuid,
      dateTime: dateTime,
      type: type,
      data: data,
    );
  }
}

enum EventType {
  smartDoorService,
  doorControl;

  @override
  String toString() => switch (this) {
        smartDoorService => 'Smart Door Service',
        doorControl => 'Door Control Event',
      };
}

enum Severity {
  error,
  warning,
  info;
}

enum SmartDoorServiceEvent {
  connectionLost,
  connectionEstablished;

  @override
  String toString() => switch (this) {
        connectionLost => 'Connection Lost',
        connectionEstablished => 'Connection Established',
      };
}
