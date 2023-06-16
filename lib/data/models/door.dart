import 'package:get/get.dart';
import './door_control.dart';

class Door {
  Rx<String?> individualName = Rx<String?>(null);

  Rx<int?> equipmentNumber = Rx<int?>(null);

  Rx<String?> profile = Rx<String?>(null);

  Rx<int?> cycleCounter = Rx<int?>(null);

  Rx<OpeningStatus> openingStatus = Rx<OpeningStatus>(OpeningStatus.unknown);

  Rx<double?> openingPosition = Rx<double?>(null);

  Rx<int?> currentSpeed = Rx<int?>(null);

  Rx<DoorControl?> doorControl = Rx<DoorControl?>(null);
}

enum OpeningStatus {
  unknown,
  opened,
  opening,
  intermediate,
  closing,
  closed;

  @override
  String toString() {
    return switch (this) {
      unknown => '?',
      _ => name.toUpperCase(),
    };
  }
}
