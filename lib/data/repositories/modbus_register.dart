import 'modbus_register_types.dart';
import 'modbus_register_map.g.dart';

abstract base class ModbusRegister {
  final ModbusRegisterName name;
  final List<ModbusRegisterGroup> groups;
  final int address;
  final ModbusRegisterType type;
  final AccessType accessType;

  const ModbusRegister({
    required this.name,
    required this.groups,
    required this.address,
    required this.type,
    required this.accessType,
  });
}

final class ModbusBitRegister extends ModbusRegister {
  const ModbusBitRegister({
    required super.name,
    required super.groups,
    required super.address,
    required super.type,
    required super.accessType,
  });
}

final class ModbusWordRegister extends ModbusRegister {
  final ModbusDataType dataType;
  final int length;

  const ModbusWordRegister({
    required super.name,
    required super.groups,
    required super.address,
    required super.type,
    required super.accessType,
    required this.dataType,
    required this.length,
  });
}

class ModbusRegisterCollection {
  ModbusRegisterType registerType;
  int address;
  int length;
  List<ModbusRegister> registers = [];

  ModbusRegisterCollection({
    required this.registerType,
    this.address = 0,
    this.length = 0,
  });
}

extension ModbusRegisterTypeExtensions on ModbusRegisterType {
  Type get classType {
    switch (this) {
      case ModbusRegisterType.coil:
      case ModbusRegisterType.discreteInput:
        return ModbusBitRegister;
      case ModbusRegisterType.holdingRegister:
      case ModbusRegisterType.inputRegister:
        return ModbusWordRegister;
    }
  }
}

extension ModbusRegisterNameExtensions on ModbusRegisterName {
  int compareTo(ModbusRegisterName other) {
    return index - other.index;
  }

  bool operator >=(ModbusRegisterName other) {
    return compareTo(other) >= 0;
  }

  bool operator <=(ModbusRegisterName other) {
    return compareTo(other) <= 0;
  }
}
