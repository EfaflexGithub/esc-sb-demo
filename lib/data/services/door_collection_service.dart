import 'dart:async';

import 'package:efa_smartconnect_modbus_demo/data/factories/modbus_tcp_service_factory.dart';
import 'package:efa_smartconnect_modbus_demo/data/factories/smart_door_service_factory.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/modbus_tcp_service.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/hive_extensions.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

class DoorCollectionService extends GetxService {
  static const String _configurationsBoxName = 'smartDoorServiceConfigurations';

  @override
  void onReady() async {
    super.onReady();
    await loadConfigurations();
  }

  final RxList<SmartDoorService> _smartDoorServices = <SmartDoorService>[].obs;

  RxList<SmartDoorService> get smartDoorServices => _smartDoorServices;

  Future<SmartDoorService> add(
    SmartDoorService smartDoorService, {
    bool saveConfiguration = true,
  }) async {
    _smartDoorServices.add(smartDoorService);
    if (saveConfiguration) {
      await DoorCollectionService.saveConfiguration(smartDoorService);
    }
    return smartDoorService;
  }

  Future<void> removeWhere(bool Function(SmartDoorService) test) async {
    _smartDoorServices.where(test).forEach((service) {
      service.stop();
    });
    await Hive.withBox(_configurationsBoxName, (box) {
      var uuids = _smartDoorServices.where(test).map<String>((e) => e.uuid);
      box.deleteAll(uuids);
    });
    _smartDoorServices.removeWhere(test);
  }

  Future<void> remove(SmartDoorService service) async {
    await service.stop();
    await Hive.withBox(_configurationsBoxName, (box) {
      box.delete(service.uuid);
    });
    _smartDoorServices.remove(service);
  }

  Future<void> saveConfigurations() async {
    await Hive.withBox(_configurationsBoxName, (_) async {
      for (SmartDoorService smartDoorService in _smartDoorServices) {
        saveConfiguration(smartDoorService);
      }
    });
  }

  static Future<void> saveConfiguration(
      SmartDoorService smartDoorService) async {
    await Hive.withBox(_configurationsBoxName, (box) async {
      Map<String, dynamic> configuration = {
        'serviceName': smartDoorService.getServiceName(),
        'configuration': smartDoorService.getConfiguration(),
      };
      await box.put(smartDoorService.uuid, configuration);
    });
  }

  Future<void> loadConfigurations() async {
    await Hive.withBox(_configurationsBoxName, (box) {
      box.toMap().cast<String, dynamic>().forEach((uuid, map) async {
        String serviceName = map['serviceName'];
        SmartDoorServiceFactory factory = switch (serviceName) {
          ModbusTcpService.serviceName => ModbusTcpServiceFactory(),
          _ => throw Exception('Unknown service: $serviceName'),
        };
        var configuration =
            (map['configuration'] as Map).cast<String, dynamic>();
        SmartDoorService service =
            factory.createSmartDoorService(configuration, uuid);
        await add(service, saveConfiguration: false);
        await service.start();
      });
    });
  }
}
