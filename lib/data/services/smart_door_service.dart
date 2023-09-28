import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/isar_collection_mixin.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/user_application.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract base class SmartDoorService with IsarCollectionMixin {
  SmartDoorService([int? id]) {
    if (id != null) {
      this.id = id;
    }
  }

  Door get door;

  final tooltip = ''.obs;

  final selected = false.obs;

  final serviceActions = RxList<ServiceAction>();

  final Rx<Color> _statusColor = Colors.grey.obs;

  final status = Rx<SmartDoorServiceStatus>(SmartDoorServiceStatus.unknown);

  Map<String, String> get uiConfiguration;

  Map<String, List<Map<String, String>>> get additionalUiGroups;

  List<UserApplicationDefinition> get supportedUserApplications;

  List<UserApplication> get userApplications;

  Future<bool> configureUserApplication(int slot, String value);

  Future<bool> setUserApplicationState(int slot, bool state);

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

  void addServiceAction(ServiceAction serviceAction) {
    serviceActions.add(serviceAction);
  }

  void removeServiceActionById(String id) {
    var serviceAction = serviceActions.firstWhere((e) => e.id == id);
    serviceActions.remove(serviceAction);
  }

  String getServiceName();

  Map<String, dynamic> getConfiguration();
}

enum SmartDoorServiceStatus {
  unknown,
  okay,
  warn,
  error;
}

class ServiceAction {
  ServiceAction({
    required this.id,
    required this.name,
    required this.description,
    required this.iconData,
    this.onToggle,
    this.onPressed,
  });

  final String id;
  final String name;
  final String description;
  final IconData iconData;
  final Future<void> Function()? onToggle;
  final Future<void> Function()? onPressed;
}
