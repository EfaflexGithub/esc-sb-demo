import 'package:get/get.dart';
import './door_control.dart';

import 'package:isar/isar.dart';

part 'door.g.dart';

@collection
class Door {
  Id? id;

  final _individualName = Rxn<String>();
  String? get individualName => _individualName.value;
  set individualName(String? value) => _individualName.value = value;

  final _equipmentNumber = Rxn<int>();
  int? get equipmentNumber => _equipmentNumber.value;
  set equipmentNumber(int? value) => _equipmentNumber.value = value;

  final _profile = Rxn<String>();
  String? get profile => _profile.value;
  set profile(String? value) => _profile.value = value;

  final _cycleCounter = Rxn<int>();
  int? get cycleCounter => _cycleCounter.value;
  set cycleCounter(int? value) => _cycleCounter.value = value;

  final _openingStatus = Rx<OpeningStatus>(OpeningStatus.unknown);
  @enumerated
  OpeningStatus get openingStatus => _openingStatus.value;
  set openingStatus(OpeningStatus value) => _openingStatus.value = value;

  final _openingPosition = Rxn<double>();
  double? get openingPosition => _openingPosition.value;
  set openingPosition(double? value) => _openingPosition.value = value;

  final _currentSpeed = Rxn<int>();
  int? get currentSpeed => _currentSpeed.value;
  set currentSpeed(int? value) => _currentSpeed.value = value;

  final _doorControl = Rxn<DoorControl>();
  @ignore
  DoorControl? get doorControl => _doorControl.value;
  set doorControl(DoorControl? value) => _doorControl.value = value;
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
