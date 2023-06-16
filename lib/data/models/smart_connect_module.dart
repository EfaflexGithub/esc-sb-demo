import 'package:efa_smartconnect_modbus_demo/data/models/cycle_analysis.dart';
import 'package:get/get.dart';
import 'package:version/version.dart';
import './extension_board.dart';

class SmartConnectModule extends ExtensionBoard {
  Rx<String?> materialNumber = Rx<String?>(null);

  Rx<int?> serialNumber = Rx<int?>(null);

  Rx<Version?> firmwareVersion = Rx<Version?>(null);

  var cycleAnalysis = CycleAnalysis();
}
