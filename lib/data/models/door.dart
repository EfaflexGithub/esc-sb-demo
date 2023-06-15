import 'dart:ffi';
import 'package:get/get.dart';
import './door_control.dart';

class Door {
  Rx<String?> individualName = Rx<String?>(null);

  Rx<Uint64?> equipmentNumber = Rx<Uint64?>(null);

  Rx<String?> doorProfile = Rx<String?>(null);

  Rx<DoorControl?> doorControl = null.obs;
}
