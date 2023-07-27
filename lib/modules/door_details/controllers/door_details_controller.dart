import 'package:efa_smartconnect_modbus_demo/data/models/user_application.dart';
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

  Future<void> saveUserApplications() async {
    for (int i = 0; i < userApplicationsCount; i++) {
      if (userApplicationsTempValues[i] != userApplications[i]?.value) {
        await smartDoorService.configureUserApplication(
            i, userApplicationsTempValues[i]);
      }
    }
  }
}
