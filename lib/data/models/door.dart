import 'package:get/get.dart';
import './door_control.dart';

class Door {
  var individualName = Rxn<String>();

  var equipmentNumber = Rxn<int>();

  var profile = Rxn<String>();

  var cycleCounter = Rxn<int>();

  Rx<OpeningStatus> openingStatus = Rx<OpeningStatus>(OpeningStatus.unknown);

  var openingPosition = Rxn<double>();

  var currentSpeed = Rxn<int>();

  var doorControl = Rxn<DoorControl>();
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
      _ => name.capitalizeFirst!,
    };
  }
}
