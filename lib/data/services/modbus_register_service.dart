import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register_types.dart';
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

  List<ModbusRegisterCollection> getModbusRegisterCollections(
      ModbusRegisterGroup group) {
    List<ModbusRegisterCollection> collections = [
      ModbusRegisterCollection(registerType: ModbusRegisterType.coil),
      ModbusRegisterCollection(registerType: ModbusRegisterType.discreteInput),
      ModbusRegisterCollection(
          registerType: ModbusRegisterType.holdingRegister),
      ModbusRegisterCollection(registerType: ModbusRegisterType.inputRegister),
    ];

    List<ModbusRegister> registers = modbusRegisterMap
        .where((element) => element.groups.contains(group))
        .toList();

    // move the registers into the 4 collections, based on the ModbusRegisterType
    for (var register in registers) {
      switch (register.type) {
        case ModbusRegisterType.coil:
          collections[0].registers.add(register);
          break;
        case ModbusRegisterType.discreteInput:
          collections[1].registers.add(register);
          break;
        case ModbusRegisterType.holdingRegister:
          collections[2].registers.add(register);
          break;
        case ModbusRegisterType.inputRegister:
          collections[3].registers.add(register);
          break;
      }
    }

    // remove collections that have no registers
    collections.removeWhere((element) => element.registers.isEmpty);

    for (int i = 0; i < collections.length; i++) {
      var collection = collections[i];
      var registerType = switch (collection.registerType) {
        ModbusRegisterType.coil ||
        ModbusRegisterType.discreteInput =>
          ModbusBitRegister,
        ModbusRegisterType.holdingRegister ||
        ModbusRegisterType.inputRegister =>
          ModbusWordRegister,
      };

      // sort the registers in each collection based on the address
      collection.registers.sort((a, b) => a.address.compareTo(b.address));

      // split the registers into another collection when they are not sequential
      for (int j = 0; j < collection.registers.length - 1; j++) {
        ModbusRegister first = collection.registers.first;
        ModbusRegister current = collection.registers[j];
        ModbusRegister next = collection.registers[j + 1];

        if ((current is ModbusBitRegister &&
                (current.address + 1 != next.address ||
                    next.address - first.address > 2000)) ||
            (current is ModbusWordRegister &&
                next is ModbusWordRegister &&
                (current.address + current.length != next.address ||
                    next.address + next.length - first.address > 125))) {
          var newCollection =
              ModbusRegisterCollection(registerType: collection.registerType);
          newCollection.registers.addAll(collection.registers.sublist(j + 1));
          collection.registers.removeRange(j + 1, collection.registers.length);
          collections.add(newCollection);
          break;
        }
      }

      // calculate address and length of collection
      collection.address = collection.registers.first.address;
      if (registerType == ModbusBitRegister) {
        collection.length = collection.registers.length;
      } else if (registerType == ModbusWordRegister) {
        collection.length = collection.registers.last.address -
            collection.registers.first.address +
            (collection.registers.last as ModbusWordRegister).length;
      }
    }

    return collections;
  }
}
