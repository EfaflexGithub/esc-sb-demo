import 'package:efa_smartconnect_modbus_demo/data/models/extension_board.dart';
import 'package:get/get.dart';

abstract base class DoorControl {
  var cycleCounter = 0.obs;
  List<ExtensionBoard> extensionBoards = <ExtensionBoard>[];
}
