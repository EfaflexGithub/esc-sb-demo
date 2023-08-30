import 'package:get/get.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/door_collection_service.dart';

import '../controllers/door_details_controller.dart';

class DoorDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoorDetailsController>(
      () {
        var smartDoorService = DoorCollectionService.find()
            .smartDoorServices
            .firstWhere((smartDoorService) =>
                smartDoorService.id ==
                int.parse(Get.parameters['smartDoorId']!));
        return DoorDetailsController(smartDoorService);
      },
    );
  }
}
