import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

base mixin SmartDoorService {
  Door door = Door();

  final Rx<Color> _statusColor = Colors.grey.obs;

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

  void start() {
    isServiceRunning.value = true;
  }

  void stop() {
    isServiceRunning.value = false;
  }
}

enum StatusColor {
  unknown,
  okay,
  warn,
  error;
}
