import 'dart:ffi';
import 'package:get/get.dart';
import './door_control.dart';

class Door {
  Rx<String?> individualName = null.obs;

  Rx<Uint64?> equipmentNumber = null.obs;

  Rx<String?> doorProfile = null.obs;

  Rx<DoorControl?> doorControl = null.obs;
}
