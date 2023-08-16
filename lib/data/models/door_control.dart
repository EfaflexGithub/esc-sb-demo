import 'package:efa_smartconnect_modbus_demo/data/models/event_entry.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/information_entry.dart';
import 'package:get/get.dart';

abstract base class DoorControl {
  var series = Rxn<String>();

  var serialNumber = Rxn<int>();

  var firmwareVersion = Rxn<String>();

  var displayContent = Rxn<String>();

  var eventEntries = RxList<EventEntry>();

  List<List<InformationEntry>> get controlInformation;
}
