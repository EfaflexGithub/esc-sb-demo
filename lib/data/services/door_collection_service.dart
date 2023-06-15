import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';
import 'package:get/get.dart';

class DoorCollectionService extends GetxService {
  Future<DoorCollectionService> init() async {
    return this;
  }

  final RxList<SmartDoorService> _smartDoorServices = <SmartDoorService>[].obs;

  RxList<SmartDoorService> get smartDoorServices => _smartDoorServices;

  SmartDoorService add(SmartDoorService smartDoorService) {
    _smartDoorServices.add(smartDoorService);
    return smartDoorService;
  }

  void removeAt(int index) {
    _smartDoorServices.removeAt(index);
  }
}
