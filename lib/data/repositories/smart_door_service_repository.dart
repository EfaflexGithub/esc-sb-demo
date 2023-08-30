import 'dart:convert';

import 'package:efa_smartconnect_modbus_demo/data/factories/modbus_tcp_service_factory.dart';
import 'package:efa_smartconnect_modbus_demo/data/factories/smart_door_service_factory.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/isar_collection_mixin.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/isar_advanced_repository.dart';
import 'package:efa_smartconnect_modbus_demo/data/providers/isar_provider.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/modbus_tcp_service.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';
import 'package:isar/isar.dart';

part 'smart_door_service_repository.g.dart';

extension SmartDoorServiceExtensions on SmartDoorService {
  Future<void> storeToCache() async {
    await SmartDoorServiceRepository().update(this);
  }
}

final class SmartDoorServiceRepository
    extends IsarAdvancedRepository<IsarSmartDoorService, SmartDoorService> {
  SmartDoorServiceRepository() : super(isar: IsarProvider.application);

  @override
  IsarSmartDoorService Function(SmartDoorService crud) get crudToIsar =>
      (crud) {
        var config = jsonEncode(crud.getConfiguration());
        return IsarSmartDoorService(
          doorId: crud.door.id,
          serviceName: crud.getServiceName(),
          smartDoorConfiguration: config,
        )..id = crud.id;
      };

  @override
  SmartDoorService Function(IsarSmartDoorService isar) get isarToCrud =>
      (isar) {
        var serviceName = isar.serviceName;
        SmartDoorServiceFactory factory = switch (serviceName) {
          ModbusTcpService.serviceName => ModbusTcpServiceFactory(),
          _ => throw Exception('Unknown service: $serviceName'),
        };
        Map<String, dynamic> configuration =
            jsonDecode(isar.smartDoorConfiguration);
        var service = factory.createSmartDoorService(configuration, isar.id);
        service.door.id = isar.doorId;
        return service;
      };
}

@collection
@Name('SmartDoorService')
class IsarSmartDoorService with IsarCollectionMixin {
  int doorId;

  String serviceName;

  String smartDoorConfiguration;

  IsarSmartDoorService({
    required this.doorId,
    required this.serviceName,
    required this.smartDoorConfiguration,
  });
}
