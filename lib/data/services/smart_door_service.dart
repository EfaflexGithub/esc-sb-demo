import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
import 'package:get/get.dart';

abstract interface class SmartDoorService {
  Door get door;

  var status = 'Uninitialized'.obs;

  Future<void> start();

  Future<void> stop();
}
