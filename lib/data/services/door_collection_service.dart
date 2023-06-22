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
  void onInit() async {
    super.onInit();
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

  void removeAt(int index) {
    _smartDoorServices.removeAt(index);
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
