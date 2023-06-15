import 'dart:typed_data';

import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/event_entry.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register_map.g.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register_types.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/modbus_register_service.dart';
import 'package:get/get.dart';
import 'package:modbus/modbus.dart';
import 'package:version/version.dart';

import './smart_door_service.dart';

class ModbusTcpService implements SmartDoorService {
  @override
  Door door = Door();

  final ModbusTcpServiceConfiguration configuration;
  final ModbusDataConfiguration _dataConfiguration = ModbusDataConfiguration();

  bool isConnected = false;

  final ModbusClient client;

  late final ModbusRegisterService _modbusRegisterService =
      Get.find<ModbusRegisterService>();

  @override
  void start() {
    // TODO: implement start
  }

  @override
  void stop() {
    // TODO: implement stop
  }

  ModbusTcpService(this.configuration, {ModbusClient? client})
      : client = client ??
            createTcpClient(configuration.ip,
                port: configuration.port,
                timeout: configuration.timeout,
                mode: ModbusMode.rtu);

  ModbusTcpService.ip(
    String ip, {
    int port = 502,
    Duration timeout = const Duration(seconds: 5),
  }) : this(ModbusTcpServiceConfiguration(
            ip: ip, port: port, timeout: timeout));

  ModbusTcpService.deserialize(String serializedConfiguration)
      : this(_deserializeConfiguration(serializedConfiguration));

  static ModbusTcpServiceConfiguration _deserializeConfiguration(
      String serializedConfiguration) {
    // todo: implement deserialization logic
    return ModbusTcpServiceConfiguration(ip: "0.0.0.0");
  }

  Future<void> updateIndividualName() async {
    door.individualName.value =
        await _readRegister(ModbusRegisterName.individualName);
  }

  Future<void> updateCycles() async {
    door.doorControl.value?.cycleCounter.value =
        await _readRegister(ModbusRegisterName.currentCycleCounter);
  }

  Future<void> writeModbusDataConfiguration(
      ModbusDataConfiguration newConfiguration) async {
    var swapOptions = 0;
    if (newConfiguration.dWordSwap) {
      swapOptions |= 0x0001;
    }
    if (newConfiguration.wordSwap) {
      swapOptions |= 0x0002;
    }
    if (newConfiguration.byteSwap) {
      swapOptions |= 0x0004;
    }
    await _writeRegister(ModbusRegisterName.swapOptions, swapOptions);
    _dataConfiguration.dWordSwap = newConfiguration.dWordSwap;
    _dataConfiguration.wordSwap = newConfiguration.wordSwap;
    _dataConfiguration.byteSwap = newConfiguration.byteSwap;

    await _writeRegister(ModbusRegisterName.dateTimeFormat,
        newConfiguration.dateTimeFormat.index);
    _dataConfiguration.dateTimeFormat = newConfiguration.dateTimeFormat;
  }

  Future<void> applyDateTimeFormat(DateTimeFormat? dateTimeFormat) async {}

  Future<int> readIntegerTest1() async {
    return await _readRegister(ModbusRegisterName.integerTest1);
  }

  Future<int> readIntegerTest2() async {
    return await _readRegister(ModbusRegisterName.integerTest2);
  }

  Future<int> readIntegerTest3() async {
    return await _readRegister(ModbusRegisterName.integerTest3);
  }

  Future<int> readIntegerTest4() async {
    return await _readRegister(ModbusRegisterName.integerTest4);
  }

  Future<int> readIntegerTest5() async {
    return await _readRegister(ModbusRegisterName.integerTest5);
  }

  Future<int> readIntegerTest6() async {
    return await _readRegister(ModbusRegisterName.integerTest6);
  }

  Future<String> readAsciiTest1() async {
    return await _readRegister(ModbusRegisterName.asciiTest1);
  }

  Future<String> readUnicodeTest1() async {
    return await _readRegister(ModbusRegisterName.unicodeTest1);
  }

  Future<DateTime> readDateTimeTest1() async {
    return await _readRegister(ModbusRegisterName.dateTimeTest1);
  }

  Future<DateTime> readDateTimeTest2() async {
    return await _readRegister(ModbusRegisterName.dateTimeTest2);
  }

  Future<Version> readSemanticVersionTest() async {
    return await _readRegister(ModbusRegisterName.semanticVersionTest);
  }

  Future<EventEntry> readEventEntryTest() async {
    return await _readRegister(ModbusRegisterName.eventEntryTest);
  }

  Future<void> _ensureConnected() async {
    if (!isConnected) {
      await client.connect();
      isConnected = true;
    }
  }

  Future<void> _disconnect() async {
    await client.close();
    isConnected = false;
  }

  dynamic _readRegister(ModbusRegisterName modbusRegisterName) async {
    dynamic retval;
    await _ensureConnected();
    var register = _modbusRegisterService.getModbusRegister(modbusRegisterName);
    if (register is ModbusBitRegister) {
      List<bool?> result;
      switch (register.type) {
        case ModbusBitRegisterType.coil:
          result = await client.readCoils(register.address - 1, 1);
          break;
        case ModbusBitRegisterType.discreteInput:
          result = await client.readDiscreteInputs(register.address - 1, 1);
          break;
        default:
          throw "Unsupported type: ${register.type}";
      }
      retval = result[0];
    } else if (register is ModbusWordRegisters) {
      Uint16List result;
      switch (register.type) {
        case ModbusWordRegistersType.holdingRegister:
          result = await client.readHoldingRegisters(
              register.address - 1, register.length);
          break;
        case ModbusWordRegistersType.inputRegister:
          result = await client.readInputRegisters(
              register.address - 1, register.length);
          break;
        default:
          throw "Unsupported type: ${register.type}";
      }
      retval = _decodeModbusData(result, register.dataType, _dataConfiguration);
    }
    await _disconnect();
    return retval;
  }

  Future<void> _writeRegister(
      ModbusRegisterName modbusRegisterName, dynamic value) async {
    await _ensureConnected();
    var register = _modbusRegisterService.getModbusRegister(modbusRegisterName);
    if (register is ModbusBitRegister) {
      throw UnimplementedError();
    } else if (register is ModbusWordRegisters) {
      if (register.type != ModbusWordRegistersType.holdingRegister) {
        throw "It is not possible to write to register of type ${register.type}";
      }
      late Uint16List words;

      words = _encodeModbusData(
          value, register.dataType, _dataConfiguration, register.length);

      switch (words.length) {
        case 0:
          return;
        case 1:
          await client.writeSingleRegister(register.address - 1, words.first);
        default:
          await client.writeMultipleRegisters(register.address - 1, words);
      }
    }
    await _disconnect();
  }

  static dynamic _decodeModbusData(Uint16List list, ModbusDataType type,
      ModbusDataConfiguration dataConfiguration) {
    switch (type) {
      case ModbusDataType.int16:
        return list.byteData().getInt16(0, Endian.big);
      case ModbusDataType.uint16:
        return list.byteData().getUint16(0, Endian.big);
      case ModbusDataType.int32:
        return list
            .byteData()
            .applySwapConfiguration(dataConfiguration)
            .getInt32(0, Endian.big);
      case ModbusDataType.uint32:
        return list
            .byteData()
            .applySwapConfiguration(dataConfiguration)
            .getUint32(0, Endian.big);
      case ModbusDataType.int64:
        return list
            .byteData()
            .applySwapConfiguration(dataConfiguration)
            .getInt64(0, Endian.big);
      case ModbusDataType.uint64:
        return list
            .byteData()
            .applySwapConfiguration(dataConfiguration)
            .getUint64(0, Endian.big);
      case ModbusDataType.ascii:
        var asciiBuffer = StringBuffer();
        for (int i = 0; i < list.length; i++) {
          int c = (list[i] >> 8) & 0xFF;
          if (c == 0) {
            break;
          }
          asciiBuffer.writeCharCode(c);
          c = list[i] & 0xFF;
          if (c == 0) {
            break;
          }
          asciiBuffer.writeCharCode(c);
        }
        return asciiBuffer.toString();
      case ModbusDataType.unicode:
        return String.fromCharCodes(list.toList()).trimRight();
      case ModbusDataType.dateTime:
        if (dataConfiguration.dateTimeFormat ==
            DateTimeFormat.dateTimeFormat1) {
          final seconds =
              _decodeModbusData(list, ModbusDataType.int64, dataConfiguration);
          var dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
          return dateTime.subtract(dateTime.timeZoneOffset);
        } else if (dataConfiguration.dateTimeFormat ==
            DateTimeFormat.dateTimeFormat2) {
          final year = list.first;
          final month = list.byteData().getUint8(2);
          final day = list.byteData().getUint8(3);
          final hour = list.byteData().getUint8(4);
          final minute = list.byteData().getUint8(5);
          final second = list.byteData().getUint8(7);
          return DateTime(year, month, day, hour, minute, second);
        } else {
          throw "Unsupported dateTime format: ${dataConfiguration.dateTimeFormat}";
        }
      case ModbusDataType.semVer:
        final major = list.byteData().getUint16(0);
        final minor = list.byteData().getUint16(2);
        final patch = list.byteData().getUint16(4);
        final labelValue = list.byteData().getInt16(6);
        final String label = switch (labelValue) {
          -1 => 'dirty',
          0 => '',
          1 => 'alpha',
          2 => 'beta',
          _ => (throw "Unsupported label value: $labelValue"),
        };
        final labelIndex = list.byteData().getUint16(8);
        return Version(major, minor, patch,
            preRelease: [label, labelIndex.toString()]);
      case ModbusDataType.eventEntry:
        DateTime dateTime = _decodeModbusData(
            list.sublist(0, 4), ModbusDataType.dateTime, dataConfiguration);
        int cycles = _decodeModbusData(
            list.sublist(4, 6), ModbusDataType.int32, dataConfiguration);
        String eventType = _decodeModbusData(
            list.sublist(6, 7), ModbusDataType.ascii, dataConfiguration);
        int eventCode = _decodeModbusData(
            list.sublist(7, 8), ModbusDataType.uint16, dataConfiguration);
        return EventEntry(
            code:
                "$eventType.${eventCode.toRadixString(16).toUpperCase().padLeft(3, '0')}",
            dateTime: dateTime,
            cycleCounter: cycles);
    }
  }

  static Uint16List _encodeModbusData(dynamic value, ModbusDataType type,
      ModbusDataConfiguration dataConfiguration, int registerCount) {
    switch (type) {
      case ModbusDataType.int16 when value is int:
      case ModbusDataType.uint16 when value is int:
        return Uint16List.fromList([value]);

      case ModbusDataType.ascii when value is String:
        Uint16List result = Uint16List(registerCount);
        for (int i = 0; i < value.length; i += 2) {
          int c1 = value.codeUnitAt(i);
          int c2 = (i + 1 < value.length) ? value.codeUnitAt(i + 1) : 0;
          result[i >> 1] = (c1 << 8) + c2;
        }
        return result;

      default:
        throw "Unsupported type $type or mismatching value type ${value.runtimeType}";
    }
  }
}

class ModbusTcpServiceConfiguration {
  final String ip;
  final int port;
  final Duration timeout;
  ModbusTcpServiceConfiguration({
    required this.ip,
    this.port = 502,
    this.timeout = const Duration(seconds: 5),
  });
}

enum DateTimeFormat {
  dateTimeFormat1,
  dateTimeFormat2,
}

class ModbusDataConfiguration {
  bool dWordSwap;
  bool wordSwap;
  bool byteSwap;
  DateTimeFormat dateTimeFormat;

  ModbusDataConfiguration({
    this.dWordSwap = false,
    this.wordSwap = false,
    this.byteSwap = false,
    this.dateTimeFormat = DateTimeFormat.dateTimeFormat1,
  });
}

extension _Uint16ListModbusExtension on Uint16List {
  ByteData byteData() {
    Uint16List copy = Uint16List.fromList(this);
    return copy.buffer.asByteData().fixEndianess();
  }
}

extension _ByteBufferModbusExtension on ByteData {
  ByteData fixEndianess() {
    if (Endian.host == Endian.little) {
      for (int i = 0; i < lengthInBytes; i += 2) {
        var temp = getInt16(i, Endian.little);
        setInt16(i, temp, Endian.big);
      }
    }
    return this;
  }

  ByteData applySwapConfiguration(ModbusDataConfiguration config) {
    if (config.dWordSwap && lengthInBytes % 8 == 0) {
      for (int i = 0; i < lengthInBytes; i += 8) {
        var temp = getInt32(i);
        setInt32(i, getInt32(i + 4));
        setInt32(i + 4, temp);
      }
    }
    if (config.wordSwap && lengthInBytes % 4 == 0) {
      for (int i = 0; i < lengthInBytes; i += 4) {
        var temp = getInt16(i);
        setInt16(i, getInt16(i + 2));
        setInt16(i + 2, temp);
      }
    }
    if (config.byteSwap && lengthInBytes % 2 == 0) {
      for (int i = 0; i < lengthInBytes; i += 2) {
        var temp = getInt8(i);
        setInt8(i, getInt8(i + 1));
        setInt8(i + 1, temp);
      }
    }
    return this;
  }
}
