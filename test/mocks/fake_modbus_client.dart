import 'dart:async';
import 'dart:typed_data';

import 'package:efa_smartconnect_modbus_demo/data/services/modbus_tcp_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:modbus/modbus.dart';
import 'package:logger/logger.dart' as logger;

class FakeModbusClient extends Fake implements ModbusClient {
  FakeModbusClient(this._dataConfiguration);

  final _logger = logger.Logger();
  final ModbusDataConfiguration _dataConfiguration;
  var _isConnected = false;

  final _holdingRegisterStream = GetStream<WordStreamData>();
  final _coilStream = GetStream<BitStreamData>();

  StreamSubscription<WordStreamData> listenWriteHoldingRegisters(
    void Function(WordStreamData) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _holdingRegisterStream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  StreamSubscription<BitStreamData> listenWriteCoils(
    void Function(BitStreamData) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _coilStream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  void _throwIfNotConnected() {
    if (_isConnected == false) {
      throw Exception('Not connected');
    }
  }

  bool _isDefaultDataConfiguration() {
    return _dataConfiguration == ModbusDataConfiguration();
  }

  @override
  Future<void> connect() {
    _isConnected = true;
    _logger.i('FakeModbusClient successfully connected');
    return Future.value();
  }

  @override
  Future<void> close() {
    _isConnected = false;
    _logger.i('FakeModbusClient successfully closed');
    return Future.value();
  }

  @override
  Future<Uint16List> readHoldingRegisters(int address, int amount) {
    switch (address + 1) {
      case 1 when amount == 25:
        return Future.value(Uint16List.fromList([
          0x4546,
          0x412D,
          0x536D,
          0x6172,
          0x7443,
          0x6F6E,
          0x6E65,
          0x6374,
          0x204D,
          0x6F63,
          0x6B00,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
          0x0000,
        ]));

      default:
        throw UnimplementedError("desired register request not mocked!");
    }
  }

  @override
  Future<Uint16List> readInputRegisters(int address, int amount) {
    _throwIfNotConnected();

    switch (address + 1) {
      case 1 when amount == 8 && _isDefaultDataConfiguration():
        return Future.value(Uint16List.fromList([
          0x0000,
          0x0001,
          0xDCD8,
          0x3240,
          0x3237,
          0x3100,
          0x0000,
          0x0000,
        ]));

      case 1 when amount == 4 && _isDefaultDataConfiguration():
        return Future.value(
            Uint16List.fromList([0x0000, 0x0001, 0xDCD8, 0x3240]));

      case 5 when amount == 4:
        return Future.value(
            Uint16List.fromList([0x3237, 0x3100, 0x0000, 0x0000]));

      case 9003 when amount == 1:
        return Future.value(Uint16List.fromList([0x8421]));

      case 9004 when amount == 2:
        var index = 0;
        if (_dataConfiguration.wordSwap) {
          index |= 0x0001;
        }
        if (_dataConfiguration.byteSwap) {
          index |= 0x0002;
        }
        final List<Uint16List> registers = [
          Uint16List.fromList([0x8765, 0x4321]),
          Uint16List.fromList([0x4321, 0x8765]),
          Uint16List.fromList([0x6587, 0x2143]),
          Uint16List.fromList([0x2143, 0x6587]),
        ];
        return Future.value(registers[index]);

      case 9006 when amount == 4:
        var index = 0;
        if (_dataConfiguration.dWordSwap) {
          index |= 0x0001;
        }
        if (_dataConfiguration.wordSwap) {
          index |= 0x0002;
        }
        if (_dataConfiguration.byteSwap) {
          index |= 0x0004;
        }
        final List<Uint16List> registers = [
          Uint16List.fromList([0xFEDC, 0xBA98, 0x7654, 0x3210]),
          Uint16List.fromList([0x7654, 0x3210, 0xFEDC, 0xBA98]),
          Uint16List.fromList([0xBA98, 0xFEDC, 0x3210, 0x7654]),
          Uint16List.fromList([0x3210, 0x7654, 0xBA98, 0xFEDC]),
          Uint16List.fromList([0xDCFE, 0x98BA, 0x5476, 0x1032]),
          Uint16List.fromList([0x5476, 0x1032, 0xDCFE, 0x98BA]),
          Uint16List.fromList([0x98BA, 0xDCFE, 0x1032, 0x5476]),
          Uint16List.fromList([0x1032, 0x5476, 0x98BA, 0xDCFE]),
        ];
        return Future.value(registers[index]);

      case 9010 when amount == 4:
        final registers = Uint16List.fromList([0x646f, 0x2069, 0x7400, 0x0000]);
        return Future.value(registers);

      case 9014 when amount == 4:
        final registers = Uint16List.fromList([0x2192, 0x0032, 0x00B0, 0x2713]);
        return Future.value(registers);

      case 9018
          when amount == 4 &&
              _dataConfiguration.dateTimeFormat ==
                  DateTimeFormat.dateTimeFormat2:
        return Future.value(
            Uint16List.fromList([0x07E6, 0x0202, 0x0B1C, 0x0009]));

      case 9018 when amount == 4 && _isDefaultDataConfiguration():
        return Future.value(
            Uint16List.fromList([0x0000, 0x0000, 0x61FA, 0x6AC9]));

      case 9018
          when amount == 4 &&
              _dataConfiguration.dateTimeFormat ==
                  DateTimeFormat.dateTimeFormat1 &&
              _dataConfiguration.dWordSwap == true &&
              _dataConfiguration.wordSwap == true &&
              _dataConfiguration.byteSwap == true:
        return Future.value(
            Uint16List.fromList([0xC96A, 0xFA61, 0x0000, 0x0000]));

      case 9022
          when amount == 4 &&
              _dataConfiguration.dateTimeFormat ==
                  DateTimeFormat.dateTimeFormat2:
        return Future.value(
            Uint16List.fromList([0x0757, 0x030E, 0x0B1E, 0x0000]));

      case 9022 when amount == 4 && _isDefaultDataConfiguration():
        return Future.value(
            Uint16List.fromList([0xFFFF, 0xFFFF, 0x5535, 0x3E38]));

      case 9022
          when amount == 4 &&
              _dataConfiguration.dateTimeFormat ==
                  DateTimeFormat.dateTimeFormat1 &&
              _dataConfiguration.dWordSwap == true &&
              _dataConfiguration.wordSwap == true &&
              _dataConfiguration.byteSwap == true:
        return Future.value(
            Uint16List.fromList([0x383E, 0x3555, 0xFFFF, 0xFFFF]));

      case 9026 when amount == 5:
        return Future.value(
            Uint16List.fromList([0x0002, 0x000F, 0x0006, 0x0002, 0x0017]));

      case 9031 when amount == 10 && _isDefaultDataConfiguration():
        return Future.value(Uint16List.fromList([
          0x0000,
          0x0000,
          0x62EB,
          0x8AE6,
          0x0001,
          0x6910,
          0x4600,
          0x040C,
          0x0000,
          0x0000
        ]));

      case 9031
          when amount == 10 &&
              _dataConfiguration.dateTimeFormat ==
                  DateTimeFormat.dateTimeFormat2 &&
              _dataConfiguration.dWordSwap == true &&
              _dataConfiguration.wordSwap == true &&
              _dataConfiguration.byteSwap == true:
        return Future.value(Uint16List.fromList([
          2022,
          (8 << 8) | (4 << 0),
          (9 << 8) | (1 << 0),
          26,
          0x1069,
          0x0100,
          0x4600,
          0x040C,
          0x0000,
          0x0000
        ]));

      default:
        throw UnimplementedError(
            "desired register request not mocked: $amount registers @ $address with data configuration $_dataConfiguration");
    }
  }

  @override
  Future<bool> writeSingleCoil(int address, bool to_write) {
    _coilStream.add(BitStreamData(address: address, data: [to_write]));
    return Future.value(true);
  }

  @override
  Future<void> writeMultipleCoils(int address, List<bool> values) {
    _coilStream.add(BitStreamData(address: address, data: values));
    return Future.value();
  }

  @override
  Future<int> writeSingleRegister(int address, int value) {
    _throwIfNotConnected();
    switch (address + 1) {
      case 2017:
        _dataConfiguration.dWordSwap = value & 0x0001 != 0;
        _dataConfiguration.wordSwap = value & 0x0002 != 0;
        _dataConfiguration.byteSwap = value & 0x0004 != 0;
        break;

      case 2018:
        _dataConfiguration.dateTimeFormat = switch (value) {
          0 => DateTimeFormat.dateTimeFormat1,
          1 => DateTimeFormat.dateTimeFormat2,
          _ => throw Exception('Invalid date time format'),
        };
        break;

      default:
        _holdingRegisterStream.add(WordStreamData(
            address: address, data: Uint16List.fromList([value])));
        throw UnimplementedError();
    }
    return Future.value(0);
  }

  @override
  Future<void> writeMultipleRegisters(int address, Uint16List values) {
    _holdingRegisterStream.add(WordStreamData(address: address, data: values));
    return Future.value();
  }
}

class BitStreamData {
  final int address;
  final List<bool> data;

  BitStreamData({
    required this.address,
    required this.data,
  });
}

class WordStreamData {
  final int address;
  final Uint16List data;

  WordStreamData({
    required this.address,
    required this.data,
  });
}
