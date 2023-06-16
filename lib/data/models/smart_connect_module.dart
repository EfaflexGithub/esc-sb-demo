import 'package:get/get.dart';
import 'package:version/version.dart';
import './extension_board.dart';

class SmartConnectModule extends ExtensionBoard {
  Rx<String?> materialNumber = Rx<String?>(null);

  Rx<int?> serialNumber = Rx<int?>(null);

  Rx<Version?> firmwareVersion = Rx<Version?>(null);
}
