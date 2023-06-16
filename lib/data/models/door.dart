import 'package:efa_smartconnect_modbus_demo/data/models/efa_tronic.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/smart_connect_module.dart';
import 'package:get/get.dart';
import './door_control.dart';

class Door {
  Rx<String?> individualName = Rx<String?>(null);

  Rx<int?> equipmentNumber = Rx<int?>(null);

  Rx<String?> profile = Rx<String?>(null);

  Rx<int?> cycleCounter = Rx<int?>(null);

  Rx<DoorControl?> doorControl = null.obs;

  Door();

  Door.smartConnectModule() {
    var efaTronic = EfaTronic();
    var smartConnectModule = SmartConnectModule();
    doorControl.value = efaTronic;
    efaTronic.extensionBoards.add(smartConnectModule);
  }
}
