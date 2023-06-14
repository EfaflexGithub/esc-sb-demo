import 'modbus_register_types.dart';
import 'modbus_register_map.g.dart';

abstract class ModbusRegister {
  final ModbusRegisterName name;
  final List<ModbusRegisterGroup> groups;
  final int address;

  const ModbusRegister({
    required this.name,
    required this.groups,
    required this.address,
  });
}

class ModbusBitRegister extends ModbusRegister {
  final ModbusBitRegisterType type;
  const ModbusBitRegister({
    required super.name,
    required super.groups,
    required super.address,
    required this.type,
  });
}

class ModbusWordRegisters extends ModbusRegister {
  final ModbusWordRegistersType type;
  final ModbusDataType dataType;
  final int length;

  const ModbusWordRegisters({
    required super.name,
    required super.groups,
    required super.address,
    required this.type,
    required this.dataType,
    required this.length,
  });
}
