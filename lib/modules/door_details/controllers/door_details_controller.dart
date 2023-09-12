import 'package:efa_smartconnect_modbus_demo/data/models/information_entry.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/user_application.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/modbus_tcp_service.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';
import 'package:get/get.dart';

class DoorDetailsController extends GetxController {
  final SmartDoorService smartDoorService;
  late final int userApplicationsCount;
  late final List<UserApplication?> userApplications;
  late final List<String> userApplicationsTempValues;

  DoorDetailsController(this.smartDoorService) {
    userApplicationsCount = smartDoorService.userApplications.length;
    userApplications = smartDoorService.userApplications;
    userApplicationsTempValues = List.filled(userApplicationsCount, "-1");
  }

  Future<void> updateDoorName(String value) async {
    if (smartDoorService is ModbusTcpService) {
      await (smartDoorService as ModbusTcpService).writeIndividualName(value);
    }
  }

  Future<void> saveUserApplications() async {
    for (int slot = 0; slot < userApplicationsCount; slot++) {
      if (userApplicationsTempValues[slot] !=
          userApplications[slot]?.definition?.value) {
        await smartDoorService.configureUserApplication(
            slot, userApplicationsTempValues[slot]);
      }
    }
  }

  Future<void> saveInformationEntries(
      List<InformationEntry> informationEntries) async {
    for (var entry in informationEntries) {
      if (!entry.editable) {
        continue;
      }
      if (entry.value == entry.tempValue) {
        continue;
      }
      await entry.triggerSave();
      entry.value = entry.tempValue;
    }
  }
}
