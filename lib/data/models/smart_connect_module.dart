import 'package:efa_smartconnect_modbus_demo/data/models/cycle_analysis.dart';
import 'package:get/get.dart';
import 'package:version/version.dart';
import './extension_board.dart';

class SmartConnectModule extends ExtensionBoard {
  var materialNumber = Rxn<String>();

  var serialNumber = Rxn<int>();

  var firmwareVersion = Rxn<Version>();

  var cycleAnalysis = CycleAnalysis();
}
