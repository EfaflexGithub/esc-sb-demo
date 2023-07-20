import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
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

  SmartDoorService([String? uuid]) : uuid = uuid ?? const Uuid().v4();

  set statusColor(StatusColor color) {
    _statusColor.value = switch (color) {
      StatusColor.unknown => Colors.grey,
      StatusColor.okay => Colors.green,
      StatusColor.warn => Colors.yellow,
      StatusColor.error => Colors.red,
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
    await Hive.withBox(_doorCacheBoxName, (box) {
      var map = (box.get(uuid) as Map?)?.cast<String, dynamic>();
      if (map == null) {
        return;
      }
      door.individualName.value = map['individual-name'];
      door.equipmentNumber.value = map['equipment-number'];
    });
  }
}

enum StatusColor {
  unknown,
  okay,
  warn,
  error;
}
