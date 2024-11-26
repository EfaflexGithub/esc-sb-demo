import 'package:efa_smartconnect_modbus_demo/data/models/isar_collection_mixin.dart';
import 'package:get/get.dart';
import './door_control.dart';

import 'package:isar/isar.dart';

part 'door.g.dart';

@collection
class Door with IsarCollectionMixin {
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

  final _siCycleCounter = Rxn<int>();
  int? get reversalsSafetyGroup => _siCycleCounter.value;
  set reversalsSafetyGroup(int? value) => _siCycleCounter.value = value;

  final _seCycleCounter = Rxn<int>();
  int? get reversalsSafetyEdge => _seCycleCounter.value;
  set reversalsSafetyEdge(int? value) => _seCycleCounter.value = value;

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

  void copyFrom(
    Door door, {
    bool copyId = false,
    bool copyDoorControl = true,
  }) {
    if (copyId) {
      id = door.id;
    }
    individualName = door.individualName;
    equipmentNumber = door.equipmentNumber;
    profile = door.profile;
    cycleCounter = door.cycleCounter;
    openingStatus = door.openingStatus;
    openingPosition = door.openingPosition;
    currentSpeed = door.currentSpeed;
    if (copyDoorControl) {
      doorControl = door.doorControl;
    }
  }
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
