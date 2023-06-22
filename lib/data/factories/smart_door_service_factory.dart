import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';

abstract interface class SmartDoorServiceFactory<T extends SmartDoorService> {
  T createSmartDoorService(
    Map<String, dynamic> map,
    String? uuid,
  );
}
