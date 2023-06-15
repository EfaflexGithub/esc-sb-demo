import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';

abstract interface class SmartDoorService {
  Door get door;

  void start();

  void stop();
}
