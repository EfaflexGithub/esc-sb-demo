import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/user_application.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/hive_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';

abstract base class SmartDoorService {
  static const String _doorCacheBoxName = 'doorCache';

  final String uuid;

  Door get door;

  final tooltip = ''.obs;

  final selected = false.obs;

  final Rx<Color> _statusColor = Colors.grey.obs;

  final status = Rx<SmartDoorServiceStatus>(SmartDoorServiceStatus.unknown);

  Map<String, String> get uiConfiguration;

  Map<String, List<Map<String, String>>> get additionalUiGroups;

  List<UserApplicationDefinition> get supportedUserApplications;

  List<UserApplication> get userApplications;

  Future<bool> configureUserApplication(int slot, String value);

  Future<bool> setUserApplicationState(int slot, bool state);

  SmartDoorService([String? uuid]) : uuid = uuid ?? const Uuid().v4();

  set smartDoorServiceStatus(SmartDoorServiceStatus newStatus) {
    status.value = newStatus;
    _statusColor.value = switch (newStatus) {
      SmartDoorServiceStatus.unknown => Colors.grey,
      SmartDoorServiceStatus.okay => Colors.green,
      SmartDoorServiceStatus.warn => Colors.yellow,
      SmartDoorServiceStatus.error => Colors.red,
    };
  }

  var isServiceRunning = false.obs;

  Color get statusColorValue => _statusColor.value;

  var statusString = 'Uninitialized'.obs;

  @mustCallSuper
  Future<void> start() async {
    isServiceRunning.value = true;
  }

  @mustCallSuper
  Future<void> stop() async {
    isServiceRunning.value = false;
  }

  String getServiceName();

  Map<String, dynamic> getConfiguration();

  Future<void> saveToCache() async {
    await Hive.withBox(_doorCacheBoxName, (box) async {
      Map<String, dynamic> data = {
        'individual-name': door.individualName.value,
        'equipment-number': door.equipmentNumber.value,
      };
      await box.put(uuid, data);
    });
  }

  Future<void> loadCachedData() async {
    await Hive.withBox(_doorCacheBoxName, (box) async {
      var map = await getCacheData(uuid);
      if (map == null) {
        return;
      }
      door.individualName.value = map['individual-name'];
      door.equipmentNumber.value = map['equipment-number'];
    });
  }

  //TODO add option to query array of uuids for performance reasons.
  static Future<Map<String, dynamic>?> getCacheData(String uuid) async {
    return await Hive.withBox<Map<String, dynamic>>(_doorCacheBoxName, (box) {
      return (box.get(uuid) as Map?)?.cast<String, dynamic>();
    });
  }
}

enum SmartDoorServiceStatus {
  unknown,
  okay,
  warn,
  error;
}
