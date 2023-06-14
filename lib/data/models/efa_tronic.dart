import 'dart:ffi';
import 'package:get/get.dart';

import './door_control.dart';

class EfaTronic extends DoorControl {
  Rx<String?> series = null.obs;

  // assign 0 by default to serial
  Rx<Uint32?> serial = null.obs;

  Rx<String?> firmwareVersion = null.obs;
}
