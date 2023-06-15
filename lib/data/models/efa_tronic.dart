import 'dart:ffi';
import 'package:get/get.dart';

import './door_control.dart';

base class EfaTronic extends DoorControl {
  Rx<String?> series = Rx<String?>(null);

  // assign 0 by default to serial
  Rx<Uint32?> serial = Rx<Uint32?>(null);

  Rx<String?> firmwareVersion = Rx<String?>(null);
}
