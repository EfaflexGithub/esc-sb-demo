import 'package:get/get.dart';

import '../repositories/modbus_register.dart';
import '../repositories/modbus_register_map.g.dart';

class ModbusRegisterService extends GetxService {
  ModbusRegisterService();

  ModbusRegister getModbusRegister(ModbusRegisterName modbusRegisterName) {
    if (modbusRegisterName.index >= 0 &&
        modbusRegisterName.index < modbusRegisterMap.length &&
        modbusRegisterMap[modbusRegisterName.index].name ==
            modbusRegisterName) {
      return modbusRegisterMap[modbusRegisterName.index];
    } else {
      for (var modbusRegister in modbusRegisterMap) {
        if (modbusRegister.name == modbusRegisterName) {
          return modbusRegister;
        }
      }
    }
    throw ArgumentError('ModbusRegister not found');
  }
}
