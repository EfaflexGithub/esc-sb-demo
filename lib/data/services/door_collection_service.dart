import 'dart:async';

import 'package:efa_smartconnect_modbus_demo/data/repositories/door_respository.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/smart_door_service_repository.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';
import 'package:get/get.dart';

class DoorCollectionService extends GetxService {
  DoorCollectionService();

  static void registerService({
    DoorCollectionService? doorCollectionService,
    bool permanent = true,
  }) {
    Get.put<DoorCollectionService>(
      doorCollectionService ?? DoorCollectionService(),
      permanent: permanent,
      tag: 'default',
    );
  }

  static void unregisterService() {
    Get.delete<DoorCollectionService>(tag: 'default');
  }

  factory DoorCollectionService.find() =>
      Get.find<DoorCollectionService>(tag: 'default');

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
    await Future.forEach(_smartDoorServices.where(test), (service) {
      service.stop();
    });
    final serviceRepository = SmartDoorServiceRepository();
    await Future.forEach(_smartDoorServices.where(test), (service) {
      serviceRepository.delete(service);
    });
    _smartDoorServices.removeWhere(test);
  }

  Future<void> remove(SmartDoorService service) async {
    await service.stop();
    await SmartDoorServiceRepository().delete(service);
    _smartDoorServices.remove(service);
  }

  Future<void> saveConfigurations() async {
    for (SmartDoorService smartDoorService in _smartDoorServices) {
      await saveConfiguration(smartDoorService);
    }
  }

  static Future<void> saveConfiguration(
      SmartDoorService smartDoorService) async {
    await smartDoorService.door.saveToCache();
    await SmartDoorServiceRepository().update(smartDoorService);
  }

  Future<void> loadConfigurations() async {
    var services = await SmartDoorServiceRepository().getAll();
    for (var service in services) {
      await service.door.copyFromCache();
      await add(service, saveConfiguration: false);
      await service.start();
    }
  }
}
