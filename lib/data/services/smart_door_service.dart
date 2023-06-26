import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

abstract base class SmartDoorService {
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
}

enum StatusColor {
  unknown,
  okay,
  warn,
  error;
}
