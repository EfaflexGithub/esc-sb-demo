import 'package:efa_smartconnect_modbus_demo/data/models/event_entry.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/modbus_tcp_service.dart';
import 'package:efa_smartconnect_modbus_demo/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:version/version.dart';

import 'mocks/fake_modbus_client.dart';

void main() {
  initializeApplication();

  group('Modbus data parsing', () {
    test('(U)Intx data parsing', () async {
      FakeModbusClient fakeModbusClient =
          FakeModbusClient(ModbusDataConfiguration());

      ModbusTcpServiceConfiguration configuration =
          ModbusTcpServiceConfiguration(ip: '0.0.0.0');

      var modbusTcpService =
          ModbusTcpService(configuration, client: fakeModbusClient);

      const int expectedUint16 = 33825;
      const int expectedInt16 = -31711;

      const int expectedUint32 = 2271560481;
      const int expectedInt32 = -2023406815;

      const int expectedXint64 = -81985529216486896;

      List<ModbusDataConfiguration> dataConfigurations = [
        ModbusDataConfiguration(
            byteSwap: false, wordSwap: false, dWordSwap: false),
        ModbusDataConfiguration(
            byteSwap: false, wordSwap: false, dWordSwap: true),
        ModbusDataConfiguration(
            byteSwap: false, wordSwap: true, dWordSwap: false),
        ModbusDataConfiguration(
            byteSwap: false, wordSwap: true, dWordSwap: true),
        ModbusDataConfiguration(
            byteSwap: true, wordSwap: false, dWordSwap: false),
        ModbusDataConfiguration(
            byteSwap: true, wordSwap: false, dWordSwap: true),
        ModbusDataConfiguration(
            byteSwap: true, wordSwap: true, dWordSwap: false),
        ModbusDataConfiguration(
            byteSwap: true, wordSwap: true, dWordSwap: true),
      ];

      for (var dataConfiguration in dataConfigurations) {
        await modbusTcpService.writeModbusDataConfiguration(dataConfiguration);

        var actualUint16 = await modbusTcpService.readIntegerTest1();
        expect(actualUint16, equals(expectedUint16));

        var actualInt16 = await modbusTcpService.readIntegerTest2();
        expect(actualInt16, equals(expectedInt16));

        var actualUint32 = await modbusTcpService.readIntegerTest3();
        expect(actualUint32, equals(expectedUint32));

        var actualInt32 = await modbusTcpService.readIntegerTest4();
        expect(actualInt32, equals(expectedInt32));

        var actualUint64 = await modbusTcpService.readIntegerTest5();
        expect(actualUint64, equals(expectedXint64));

        var actualInt64 = await modbusTcpService.readIntegerTest6();
        expect(actualInt64, equals(expectedXint64));
      }
    });

    test('Ascii data parsing', () async {
      FakeModbusClient fakeModbusClient =
          FakeModbusClient(ModbusDataConfiguration());

      ModbusTcpServiceConfiguration configuration =
          ModbusTcpServiceConfiguration(ip: '0.0.0.0');

      var modbusTcpService =
          ModbusTcpService(configuration, client: fakeModbusClient);

      var expected = "do it";

      var actual = await modbusTcpService.readAsciiTest1();

      expect(actual, const TypeMatcher<String>());
      expect(actual, equals(expected));
    });

    test('Unicode data parsing', () async {
      FakeModbusClient fakeModbusClient =
          FakeModbusClient(ModbusDataConfiguration());

      ModbusTcpServiceConfiguration configuration =
          ModbusTcpServiceConfiguration(ip: '0.0.0.0');

      var modbusTcpService =
          ModbusTcpService(configuration, client: fakeModbusClient);

      var expected = "→2°✓";

      var actual = await modbusTcpService.readUnicodeTest1();

      expect(actual, const TypeMatcher<String>());
      expect(actual, equals(expected));
    });

    test('Datetime data parsing', () async {
      FakeModbusClient fakeModbusClient =
          FakeModbusClient(ModbusDataConfiguration());

      ModbusTcpServiceConfiguration configuration =
          ModbusTcpServiceConfiguration(ip: '0.0.0.0');

      var modbusTcpService =
          ModbusTcpService(configuration, client: fakeModbusClient);

      var expected1 = DateTime(2022, 2, 2, 11, 28, 9);
      var expected2 = DateTime(1879, 3, 14, 11, 30, 00);

      List<ModbusDataConfiguration> dataConfigurations = [
        ModbusDataConfiguration(
          byteSwap: false,
          wordSwap: false,
          dWordSwap: false,
          dateTimeFormat: DateTimeFormat.dateTimeFormat1,
        ),
        ModbusDataConfiguration(
          byteSwap: true,
          wordSwap: true,
          dWordSwap: true,
          dateTimeFormat: DateTimeFormat.dateTimeFormat1,
        ),
        ModbusDataConfiguration(
          byteSwap: false,
          wordSwap: false,
          dWordSwap: false,
          dateTimeFormat: DateTimeFormat.dateTimeFormat2,
        ),
        ModbusDataConfiguration(
          byteSwap: true,
          wordSwap: true,
          dWordSwap: true,
          dateTimeFormat: DateTimeFormat.dateTimeFormat2,
        ),
      ];

      for (var dataConfiguration in dataConfigurations) {
        await modbusTcpService.writeModbusDataConfiguration(dataConfiguration);

        var actual1 = await modbusTcpService.readDateTimeTest1();
        expect(actual1, const TypeMatcher<DateTime>());
        expect(actual1, equals(expected1));

        var actual2 = await modbusTcpService.readDateTimeTest2();
        expect(actual2, const TypeMatcher<DateTime>());
        expect(actual2, equals(expected2));
      }
    });

    test('Semantic version parsing', () async {
      FakeModbusClient fakeModbusClient =
          FakeModbusClient(ModbusDataConfiguration());

      ModbusTcpServiceConfiguration configuration =
          ModbusTcpServiceConfiguration(ip: '0.0.0.0');

      var modbusTcpService =
          ModbusTcpService(configuration, client: fakeModbusClient);

      var expected = Version(2, 15, 6, preRelease: ["beta", "23"]);

      var actual = await modbusTcpService.readSemanticVersionTest();

      expect(actual, const TypeMatcher<Version>());
      expect(actual, equals(expected));
    });

    test('Event entry parsing', () async {
      FakeModbusClient fakeModbusClient =
          FakeModbusClient(ModbusDataConfiguration());

      ModbusTcpServiceConfiguration configuration =
          ModbusTcpServiceConfiguration(ip: '0.0.0.0');

      var modbusTcpService =
          ModbusTcpService(configuration, client: fakeModbusClient);

      var expected = EventEntry(
        code: "F.40C",
        dateTime: DateTime(2022, 8, 4, 9, 1, 26),
        cycleCounter: 92432,
      );

      List<ModbusDataConfiguration> dataConfigurations = [
        ModbusDataConfiguration(
          byteSwap: false,
          wordSwap: false,
          dWordSwap: false,
          dateTimeFormat: DateTimeFormat.dateTimeFormat1,
        ),
        ModbusDataConfiguration(
          byteSwap: true,
          wordSwap: true,
          dWordSwap: true,
          dateTimeFormat: DateTimeFormat.dateTimeFormat2,
        ),
      ];

      for (var dataConfiguration in dataConfigurations) {
        await modbusTcpService.writeModbusDataConfiguration(dataConfiguration);
        var actual = await modbusTcpService.readEventEntryTest();
        expect(actual, const TypeMatcher<EventEntry>());
        expect(actual, equals(expected));
      }
    });
  });
}
