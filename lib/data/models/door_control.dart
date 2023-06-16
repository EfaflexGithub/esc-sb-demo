import 'package:get/get.dart';

abstract base class DoorControl {
  Rx<String?> series = Rx<String?>(null);

  Rx<int?> serialNumber = Rx<int?>(null);

  Rx<String?> firmwareVersion = Rx<String?>(null);

  Rx<String?> displayContent = Rx<String?>(null);
}
