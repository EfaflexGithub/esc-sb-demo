import 'dart:ffi';

import 'package:get/get.dart';
import 'package:version/version.dart';
import './extension_board.dart';

class SmartConnectModule extends ExtensionBoard {
  Rx<String?> materialNumber = null.obs;

  Rx<Uint64?> serialNumber = null.obs;

  Rx<Version?> firmwareVersion = null.obs;
}
