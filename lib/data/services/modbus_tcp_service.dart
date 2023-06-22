import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/door_control.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/efa_tronic.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/event_entry.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/smart_connect_module.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register_map.g.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register_types.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/modbus_register_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modbus/modbus.dart';
import 'package:version/version.dart';
import 'package:statemachine/statemachine.dart';
import 'package:async/async.dart';

import './smart_door_service.dart';

base class ModbusTcpService extends SmartDoorService {
  final ModbusTcpServiceConfiguration configuration;
  final ModbusDataConfiguration _dataConfiguration = ModbusDataConfiguration();

  static const String serviceName = 'modbus_tcp_service';

  @override
  final Door door = Door();

  @override
  String getServiceName() => serviceName;

  bool isConnected = false;

  bool _blockClient = false;

  RestartableTimer? _disconnectTimer;

  final ModbusClient client;

  bool? _licenseActivated;

  _LicenseActivationResult? _licenseActivationResult;

  DateTime? _licenseExpirationDate;

  final _rootMachine = Machine<_ModbusTcpServiceState>();

  final _startedMachine = Machine<_ModbusTcpServiceState>();

  final ModbusRegisterService _modbusRegisterService =
      Get.find<ModbusRegisterService>();

  @override
  Future<void> start() async {
    _rootMachine.current = _ModbusTcpServiceState.started;
    super.start();
  }

  @override
  Future<void> stop() async {
    _rootMachine.current = _ModbusTcpServiceState.stopped;
    super.stop();
  }

  @override
  Map<String, dynamic> getConfiguration() {
    return configuration.toMap();
  }

  ModbusTcpService(String ip,
      {int port = 502,
      Duration timeout = const Duration(seconds: 3),
      ModbusClient? client})
      : this.fromConfig(
            ModbusTcpServiceConfiguration(ip: ip, port: port, timeout: timeout),
            client: client);

  ModbusTcpService.fromConfig(this.configuration,
      {String? uuid, ModbusClient? client})
      : client = client ??
            createTcpClient(configuration.ip,
                port: configuration.port,
                timeout: configuration.timeout,
                mode: ModbusMode.rtu),
        super(uuid) {
    // as we know that modbus_tcp_service uses the EFA-SmartConnect module,
    // add the specific door control implementation and the SmartConnectModule
    var efaTronic = EfaTronic();
    door.doorControl.value = efaTronic;
    efaTronic.extensionBoards.add(SmartConnectModule());
    initializeStateMachine();
  }

  void initializeStateMachine() {
    // configure disconnect timer
    _disconnectTimer ??=
        RestartableTimer(const Duration(milliseconds: 500), () async {
      await _disconnect();
    });

    // configure root state machine
    final stoppedState = _rootMachine.newState(_ModbusTcpServiceState.stopped);
    final startedState = _rootMachine.newState(_ModbusTcpServiceState.started);

    stoppedState.onEntry(() {
      _setStatus(_ModbusTcpServiceState.stopped);
    });
    startedState.onEntry(() {
      _setStatus(_ModbusTcpServiceState.started);
    });
    startedState.addNested(_startedMachine);
    startedState.onExit(() async {
      await _disconnect();
    });

    // configure started state machine
    final offlineState =
        _startedMachine.newState(_ModbusTcpServiceState.offline);
    final checkingLicenseState =
        _startedMachine.newState(_ModbusTcpServiceState.checkingLicense);
    final onlineState = _startedMachine.newState(_ModbusTcpServiceState.online);

    offlineState.onTimeout(
        Duration(milliseconds: configuration.timeout.inMilliseconds + 100),
        offlineState.enter);

    offlineState.onEntry(() async {
      _setStatus(_ModbusTcpServiceState.offline);
      try {
        await updateDoorModelByGroup(
            ModbusRegisterGroup.dataConfigurationRegisters);
        _startedMachine.current = _ModbusTcpServiceState.checkingLicense;
      } on SocketException {
        _blockClient = false;
        // Nothing to do here as we want to stay inside the offlineState on a
        // SocketException (normally caused by a timeout if the modbus server
        // is not reachable)
      }
    });

    checkingLicenseState.onTimeout(
        Duration(milliseconds: configuration.timeout.inMilliseconds + 100),
        checkingLicenseState.enter);

    checkingLicenseState.onEntry(() async {
      _setStatus(_ModbusTcpServiceState.checkingLicense);
      await updateDoorModelByGroup(ModbusRegisterGroup.licensing);
      if (_licenseActivated!) {
        _startedMachine.current = _ModbusTcpServiceState.online;
      } else if (_licenseExpirationDate!.year < 2000) {
        _setStatus(_ModbusTcpServiceState.checkingLicense, 'Unlicensed');
      } else if (_licenseExpirationDate!.isBefore(DateTime.now())) {
        _setStatus(_ModbusTcpServiceState.checkingLicense, 'License Expired');
      }
    });
    checkingLicenseState.onExit(() async {
      await updateDoorModelByGroup(ModbusRegisterGroup.doorData);
      await updateDoorModelByGroup(ModbusRegisterGroup.operatingInformation);
    });

    onlineState.onTimeout(configuration.refreshRate, onlineState.enter);

    onlineState.onEntry(() async {
      _setStatus(_ModbusTcpServiceState.online);
      try {
        await _readAndProcessChangeNotificationFlags();
      } on SocketException {
        _startedMachine.current = _ModbusTcpServiceState.offline;
        _blockClient = false;
      }
    });

    _rootMachine.start();
  }

  void _setStatus(_ModbusTcpServiceState serviceState, [String? stateMessage]) {
    switch (serviceState) {
      case _ModbusTcpServiceState.stopped:
        statusString.value = stateMessage ?? 'Service Stopped';
        statusColor = StatusColor.warn;
        break;
      case _ModbusTcpServiceState.started:
        statusString.value = stateMessage ?? 'Starting Service';
        statusColor = StatusColor.unknown;
        break;
      case _ModbusTcpServiceState.offline:
        statusString.value = stateMessage ?? 'Offline';
        statusColor = StatusColor.error;
        break;
      case _ModbusTcpServiceState.checkingLicense:
        statusString.value = stateMessage ?? 'Checking license';
        statusColor = StatusColor.warn;
        break;
      case _ModbusTcpServiceState.online:
        statusString.value = stateMessage ?? 'Online';
        statusColor = StatusColor.okay;
        break;
    }
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

  @visibleForTesting
  Future<int> readIntegerTest1() async {
    return await _readRegisterByName(ModbusRegisterName.integerTest1);
  }

  @visibleForTesting
  Future<int> readIntegerTest2() async {
    return await _readRegisterByName(ModbusRegisterName.integerTest2);
  }

  @visibleForTesting
  Future<int> readIntegerTest3() async {
    return await _readRegisterByName(ModbusRegisterName.integerTest3);
  }

  @visibleForTesting
  Future<int> readIntegerTest4() async {
    return await _readRegisterByName(ModbusRegisterName.integerTest4);
  }

  @visibleForTesting
  Future<int> readIntegerTest5() async {
    return await _readRegisterByName(ModbusRegisterName.integerTest5);
  }

  @visibleForTesting
  Future<int> readIntegerTest6() async {
    return await _readRegisterByName(ModbusRegisterName.integerTest6);
  }

  @visibleForTesting
  Future<String> readAsciiTest1() async {
    return await _readRegisterByName(ModbusRegisterName.asciiTest1);
  }

  @visibleForTesting
  Future<String> readUnicodeTest1() async {
    return await _readRegisterByName(ModbusRegisterName.unicodeTest1);
  }

  @visibleForTesting
  Future<DateTime> readDateTimeTest1() async {
    return await _readRegisterByName(ModbusRegisterName.dateTimeTest1);
  }

  @visibleForTesting
  Future<DateTime> readDateTimeTest2() async {
    return await _readRegisterByName(ModbusRegisterName.dateTimeTest2);
  }

  @visibleForTesting
  Future<Version> readSemanticVersionTest() async {
    return await _readRegisterByName(ModbusRegisterName.semanticVersionTest);
  }

  @visibleForTesting
  Future<EventEntry> readEventEntryTest() async {
    return await _readRegisterByName(ModbusRegisterName.eventEntryTest);
  }

  Future<void> _ensureConnected() async {
    if (!isConnected) {
      await client.connect();
      isConnected = true;
    }
  }

  Future<void> _disconnect() async {
    while (_blockClient) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _blockClient = true;
    if (isConnected) {
      await client.close();
      isConnected = false;
    }
    _blockClient = false;
  }

  Future<void> _readAndProcessChangeNotificationFlags() async {
    var changeNotificationFlags = await _readRegistersByGroup(
        ModbusRegisterGroup.changeNotificationFlags);
    for (var name in changeNotificationFlags.keys) {
      if (!(changeNotificationFlags[name] as bool)) {
        continue;
      }
      switch (name) {
        case ModbusRegisterName.equipmentInforamtionChanged:
          await updateDoorModelByGroup(
              ModbusRegisterGroup.equipmentInformation);
          break;

        case ModbusRegisterName.physicalOutputsChanged:
          await updateDoorModelByGroup(ModbusRegisterGroup.physicalOutputs);
          break;

        case ModbusRegisterName.physicalInputsChanged:
          await updateDoorModelByGroup(ModbusRegisterGroup.physicalInputs);
          break;

        case ModbusRegisterName.virtualOutputsChanged ||
              ModbusRegisterName.virtualInputsChanged:
          await updateDoorModelByGroup(ModbusRegisterGroup.virtualInOutputs);
          break;

        case ModbusRegisterName.cycleCountersChanged:
          await updateDoorModelByGroup(ModbusRegisterGroup.cycleCounters);
          break;

        case ModbusRegisterName.operationInformationChanged:
          await updateDoorModelByGroup(
              ModbusRegisterGroup.currentOperatingInformation);
          break;

        case ModbusRegisterName.displayContentChanged:
          await updateDoorModelByGroup(ModbusRegisterGroup.displayContent);
          break;

        case ModbusRegisterName.eventMemoryChanged:
          await updateDoorModelByGroup(ModbusRegisterGroup.eventMemory);
          break;

        default:
          print('Unknown change notification flag: $name');
          break;
      }
    }
  }

  Future<void> updateDoorModelByName(ModbusRegisterName name) async {
    var value = await _readRegisterByName(name);
    _updateDoorModel(name, value);
  }

  Future<void> updateDoorModelByGroup(ModbusRegisterGroup group) async {
    var value = await _readRegistersByGroup(group);
    for (var name in value.keys) {
      _updateDoorModel(name, value[name]);
    }
  }

  void _updateDoorModel(ModbusRegisterName name, dynamic value) {
    switch (name) {
      case ModbusRegisterName.swapOptions
          when value is int && value > 0 && value < 8:
        _dataConfiguration.swapOptions = value;
        break;

      case ModbusRegisterName.dateTimeFormat when value is int:
        _dataConfiguration.dateTimeFormat = DateTimeFormat.values[value];
        break;

      case ModbusRegisterName.licenseActivationResult:
        _licenseActivationResult = _LicenseActivationResult.values[value];
        break;

      case ModbusRegisterName.licenseActivationState:
        _licenseActivated = value;
        break;

      case ModbusRegisterName.licenseExpirationDate:
        _licenseExpirationDate = value;
        break;

      case ModbusRegisterName.individualName when value is String:
        door.individualName.value = value;
        break;

      case ModbusRegisterName.equipmentNumber when value is int:
        door.equipmentNumber.value = value;
        break;

      case ModbusRegisterName.doorProfile when value is String:
        door.profile.value = value;
        break;

      case ModbusRegisterName.smartConnectMaterialNumber when value is String:
        DoorControl? control = door.doorControl.value;
        if (control is EfaTronic) {
          control
              .findExtensionBoardByType<SmartConnectModule>()
              ?.materialNumber
              .value = value;
        }
        break;

      case ModbusRegisterName.smartConnectSerialNumber when value is int:
        DoorControl? control = door.doorControl.value;
        if (control is EfaTronic) {
          control
              .findExtensionBoardByType<SmartConnectModule>()
              ?.serialNumber
              .value = value;
        }
        break;

      case ModbusRegisterName.smartConnectFirmwareVersion when value is Version:
        DoorControl? control = door.doorControl.value;
        if (control is EfaTronic) {
          control
              .findExtensionBoardByType<SmartConnectModule>()
              ?.firmwareVersion
              .value = value;
        }
        break;

      case ModbusRegisterName.currentCycleCounter when value is int:
        door.cycleCounter.value = value;
        break;

      case ModbusRegisterName.dailyCyclesDay when value is int:
        DoorControl? control = door.doorControl.value;
        if (control is EfaTronic) {
          control
              .findExtensionBoardByType<SmartConnectModule>()
              ?.cycleAnalysis
              .dailyCyclesDay
              .value = value;
        }
        break;

      case ModbusRegisterName.dailyCyclesWeek when value is int:
        DoorControl? control = door.doorControl.value;
        if (control is EfaTronic) {
          control
              .findExtensionBoardByType<SmartConnectModule>()
              ?.cycleAnalysis
              .dailyCyclesWeek
              .value = value;
        }
        break;

      case ModbusRegisterName.dailyCyclesMonth when value is int:
        DoorControl? control = door.doorControl.value;
        if (control is EfaTronic) {
          control
              .findExtensionBoardByType<SmartConnectModule>()
              ?.cycleAnalysis
              .dailyCyclesMonth
              .value = value;
        }
        break;

      case ModbusRegisterName.dailyCyclesYear when value is int:
        DoorControl? control = door.doorControl.value;
        if (control is EfaTronic) {
          control
              .findExtensionBoardByType<SmartConnectModule>()
              ?.cycleAnalysis
              .dailyCyclesYear
              .value = value;
        }
        break;

      case ModbusRegisterName.currentStatus when value is int:
        door.openingStatus.value = OpeningStatus.values[value];
        break;

      case ModbusRegisterName.currentOpeningPosition when value is int:
        door.openingPosition.value = value / 100.0;
        break;

      case ModbusRegisterName.currentSpeed when value is int:
        door.currentSpeed.value = value;
        break;

      case ModbusRegisterName.displayContentLine1 when value is String:
        (door.doorControl.value as EfaTronic).displayContentLine1 = value;
        break;

      case ModbusRegisterName.displayContentLine2 when value is String:
        (door.doorControl.value as EfaTronic).displayContentLine2 = value;
        break;

      case >= ModbusRegisterName.eventEntry1 &&
              <= ModbusRegisterName.eventEntry20
          when value is EventEntry:
        var eventEntries = door.doorControl.value?.eventEntries;
        if (eventEntries != null && eventEntries.contains(value) == false) {
          eventEntries.add(value);
          eventEntries.sort((a, b) => b.compareTo(a));
        }
        break;

      case ModbusRegisterName.currentDateAndTime when value is DateTime:
        (door.doorControl.value as EfaTronic).dateTime.value = value;
        break;

      case ModbusRegisterName.daylightSavingTime when value is int:
        (door.doorControl.value as EfaTronic).daylightSavingTime.value =
            DaylightSavingTime.values[value];
        break;

      case ModbusRegisterName.keepOpenTimeAutomaticMode when value is int:
        (door.doorControl.value as EfaTronic).keepOpenTimeAutomatic.value =
            value;
        break;

      case ModbusRegisterName.keepOpenTimeIntermediateStop when value is int:
        (door.doorControl.value as EfaTronic)
            .keepOpenTimeIntermediateStop
            .value = value;
        break;

      case ModbusRegisterName.closedPositionAdjustment when value is int:
        (door.doorControl.value as EfaTronic).closedPositionAdjustment.value =
            value;
        break;

      case ModbusRegisterName.openPositionAdjustment when value is int:
        (door.doorControl.value as EfaTronic).openPositionAdjustment.value =
            value;
        break;

      default:
        break;
    }
  }

  Future<dynamic> _readRegisterByName(
      ModbusRegisterName modbusRegisterName) async {
    var register = _modbusRegisterService.getModbusRegister(modbusRegisterName);
    if (register is ModbusBitRegister) {
      return await _readRegisters(register.type, register.address, 1);
    }

    if (register is ModbusWordRegister) {
      Uint16List result = await _readRegisters(
          register.type, register.address, register.length);
      return _decodeModbusData(result, register.dataType, _dataConfiguration);
    }

    throw "Unsupported type: ${register.type}";
  }

  Future<HashMap<ModbusRegisterName, dynamic>> _readRegistersByGroup(
      ModbusRegisterGroup group) async {
    HashMap<ModbusRegisterName, dynamic> retval =
        HashMap<ModbusRegisterName, dynamic>();
    var collections =
        _modbusRegisterService.getModbusRegisterCollections(group);

    for (var collection in collections) {
      var result = await _readRegisters(
          collection.registerType, collection.address, collection.length);

      if (collection.registerType.classType == ModbusBitRegister &&
          result is List<bool?>) {
        for (int i = 0; i < result.length; i++) {
          retval[collection.registers[i].name] = result[i];
        }
      } else if (collection.registerType.classType == ModbusWordRegister &&
          result is Uint16List) {
        int startIndex = 0;
        for (int i = 0; i < collection.registers.length; i++) {
          var register = collection.registers[i] as ModbusWordRegister;
          var registerResult =
              result.sublist(startIndex, startIndex + register.length);
          retval[collection.registers[i].name] = _decodeModbusData(
              registerResult, register.dataType, _dataConfiguration);
          startIndex += register.length;
        }
      } else {
        throw "Unsupported type: ${collection.registerType.classType}";
      }
    }
    return retval;
  }

  Future<dynamic> _readRegisters(
      ModbusRegisterType type, int address, int length) async {
    while (_blockClient) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _blockClient = true;
    _disconnectTimer?.reset();
    dynamic retval;
    await _ensureConnected();
    switch (type) {
      case ModbusRegisterType.coil:
        retval = await client.readCoils(address - 1, length);

      case ModbusRegisterType.discreteInput:
        retval = await client.readDiscreteInputs(address - 1, length);

      case ModbusRegisterType.holdingRegister:
        retval = await client.readHoldingRegisters(address - 1, length);

      case ModbusRegisterType.inputRegister:
        retval = await client.readInputRegisters(address - 1, length);

      default:
        throw "Unsupported type: $type";
    }
    _blockClient = false;
    return retval;
  }

  Future<void> _writeRegister(
      ModbusRegisterName modbusRegisterName, dynamic value) async {
    await _ensureConnected();
    var register = _modbusRegisterService.getModbusRegister(modbusRegisterName);
    if (register is ModbusBitRegister) {
      throw UnimplementedError();
    } else if (register is ModbusWordRegister) {
      if (register.type != ModbusRegisterType.holdingRegister) {
        throw "It is not possible to write to register of type ${register.type}";
      }
      final Uint16List words = _encodeModbusData(
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
      case ModbusDataType.boolean:
        var value = list.byteData().getInt16(0, Endian.big);
        return switch (value) {
          0 => false,
          -1 => true,
          _ => throw "Unexpected value for boolean: $value",
        };
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
        return String.fromCharCodes(list.toList());
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
        return switch (label) {
          '' => Version(major, minor, patch),
          _ => Version(major, minor, patch,
              preRelease: [label, labelIndex.toString()])
        };

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
  final Duration refreshRate;
  ModbusTcpServiceConfiguration({
    required this.ip,
    this.port = 502,
    this.refreshRate = const Duration(seconds: 1000),
    this.timeout = const Duration(seconds: 5),
  });

  ModbusTcpServiceConfiguration.fromMap(Map<String, dynamic> map)
      : ip = map['ip'],
        port = map['port'],
        timeout = Duration(milliseconds: map['timeout']),
        refreshRate = Duration(milliseconds: map['refreshRate']);

  Map<String, dynamic> toMap() {
    return {
      'ip': ip,
      'port': port,
      'timeout': timeout.inMilliseconds,
      'refreshRate': refreshRate.inMilliseconds,
    };
  }
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

  int get swapOptions {
    return (dWordSwap ? 0x01 : 0) |
        (wordSwap ? 0x02 : 0) |
        (byteSwap ? 0x04 : 0);
  }

  set swapOptions(int value) {
    if (value & 0x01 != 0) {
      dWordSwap = true;
    }
    if (value & 0x02 != 0) {
      wordSwap = true;
    }
    if (value & 0x04 != 0) {
      byteSwap = true;
    }
  }

  ModbusDataConfiguration({
    this.dWordSwap = false,
    this.wordSwap = false,
    this.byteSwap = false,
    this.dateTimeFormat = DateTimeFormat.dateTimeFormat1,
  });

  @override
  String toString() {
    String bool2binary(bool value) {
      return value ? "1" : "0";
    }

    return "swap(dword|word|byte): ${bool2binary(dWordSwap)}|${bool2binary(wordSwap)}|${bool2binary(byteSwap)}, datetime: ${dateTimeFormat.index}";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModbusDataConfiguration &&
          dWordSwap == other.dWordSwap &&
          wordSwap == other.wordSwap &&
          byteSwap == other.byteSwap &&
          dateTimeFormat == other.dateTimeFormat;

  @override
  int get hashCode =>
      dWordSwap.hashCode ^
      wordSwap.hashCode ^
      byteSwap.hashCode ^
      dateTimeFormat.hashCode;
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

enum _ModbusTcpServiceState {
  stopped,
  started,
  offline,
  checkingLicense,
  online,
}

enum _LicenseActivationResult {
  success,
  invalidKeyFormat,
  invalidKey,
  expired;
}
