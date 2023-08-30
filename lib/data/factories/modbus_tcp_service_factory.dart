import 'package:efa_smartconnect_modbus_demo/data/services/modbus_tcp_service.dart';
import 'package:efa_smartconnect_modbus_demo/data/factories/smart_door_service_factory.dart';

class ModbusTcpServiceFactory
    implements SmartDoorServiceFactory<ModbusTcpService> {
  @override
  ModbusTcpService createSmartDoorService(
    Map<String, dynamic> map,
    int? id,
  ) {
    return ModbusTcpService.fromConfig(
      ModbusTcpServiceConfiguration.fromMap(map),
      id: id,
    );
  }
}
