import 'package:efa_smartconnect_modbus_demo/data/models/event_entry.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register_map.g.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register_types.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/modbus_tcp_service.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/controllers/settings_controller.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/models/application_setttings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';

import 'mocks/fake_modbus_client.dart';
import 'mocks/fake_path_provider_platform.dart';

(ModbusTcpService, ModbusDataConfiguration) _createFakeModbusTcpService() {
  var defaultDataConfiguration = ModbusDataConfiguration();

  FakeModbusClient fakeModbusClient =
      FakeModbusClient(defaultDataConfiguration);

  var modbusTcpService = ModbusTcpService("0.0.0.0", client: fakeModbusClient);

  return (modbusTcpService, defaultDataConfiguration);
}

void main() async {
  // TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    SharedPreferences.setMockInitialValues({});
    SettingsController.registerService<AppSettingKeys>(applicationSettings);
  });

  group('Modbus data decoding', () {
    test('(U)Intx data decoding', () async {
      final (modbusTcpService, _) = _createFakeModbusTcpService();

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

    test('Ascii data decoding', () async {
      final (modbusTcpService, _) = _createFakeModbusTcpService();

      var expected = "do it";

      var actual = await modbusTcpService.readAsciiTest1();

      expect(actual, const TypeMatcher<String>());
      expect(actual, equals(expected));
    });

    test('Unicode data decoding', () async {
      final (modbusTcpService, _) = _createFakeModbusTcpService();

      var expected = "→2°✓";

      var actual = await modbusTcpService.readUnicodeTest1();

      expect(actual, const TypeMatcher<String>());
      expect(actual, equals(expected));
    });

    test('Datetime data decoding', () async {
      final (modbusTcpService, _) = _createFakeModbusTcpService();

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
      final (modbusTcpService, _) = _createFakeModbusTcpService();

      var expected = Version(2, 15, 6, preRelease: ["beta", "23"]);

      var actual = await modbusTcpService.readSemanticVersionTest();

      expect(actual, const TypeMatcher<Version>());
      expect(actual, equals(expected));
    });

    test('Event entry parsing', () async {
      final (modbusTcpService, _) = _createFakeModbusTcpService();

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

  group('modbus data encoding', () {
    test('DateTime data encoding', () async {
      final (modbusTcpService, _) = _createFakeModbusTcpService();
      final fakeModbusClient = modbusTcpService.client as FakeModbusClient;

      var testDateTime = DateTime(2023, 8, 10, 14, 0, 45);
      var testData = <(ModbusDataConfiguration, List<int>)>[
        (
          ModbusDataConfiguration(
            byteSwap: false,
            wordSwap: false,
            dWordSwap: false,
            dateTimeFormat: DateTimeFormat.dateTimeFormat1,
          ),
          [0x0000, 0x0000, 0x64D4, 0xED8D],
        ),
        (
          ModbusDataConfiguration(
            byteSwap: true,
            wordSwap: false,
            dWordSwap: false,
            dateTimeFormat: DateTimeFormat.dateTimeFormat1,
          ),
          [0x0000, 0x0000, 0xD464, 0x8DED],
        ),
        (
          ModbusDataConfiguration(
            byteSwap: false,
            wordSwap: true,
            dWordSwap: true,
            dateTimeFormat: DateTimeFormat.dateTimeFormat1,
          ),
          [0xED8D, 0x64D4, 0x0000, 0x0000],
        ),
        (
          ModbusDataConfiguration(
            byteSwap: false,
            wordSwap: false,
            dWordSwap: false,
            dateTimeFormat: DateTimeFormat.dateTimeFormat2,
          ),
          [0x07E7, 0x080A, 0x0E00, 0x002D],
        ),
        (
          ModbusDataConfiguration(
            byteSwap: true,
            wordSwap: true,
            dWordSwap: true,
            dateTimeFormat: DateTimeFormat.dateTimeFormat2,
          ),
          [0x07E7, 0x080A, 0x0E00, 0x002D],
        ),
      ];

      for (var dataset in testData) {
        var dataConfiguration = dataset.$1;
        var expected = dataset.$2;
        await modbusTcpService.writeModbusDataConfiguration(dataConfiguration);
        var subscription = fakeModbusClient.listenWriteHoldingRegisters(
          expectAsync1(
            (wordStreamData) {
              var actual = wordStreamData.data.toList();
              expect(actual, equals(expected));
            },
          ),
        );
        await modbusTcpService.writeControllerDateTime(testDateTime);
        subscription.cancel();
      }
    });
  });

  group('door model operations', () {
    test('get register collections', () async {
      for (var group in ModbusRegisterGroup.values) {
        var collections = ModbusRegisterCollection.byGroup(group);

        expect(collections, isNotEmpty);
        for (var collection in collections) {
          expect(collection.registers, isNotEmpty);
          if (collection.registerType == ModbusRegisterType.coil ||
              collection.registerType == ModbusRegisterType.discreteInput) {
            expect(collection.length, lessThanOrEqualTo(2000));
          } else {
            expect(collection.length, lessThanOrEqualTo(125));
          }
        }
      }
    });

    test('update model by name', () async {
      final (modbusTcpService, defaultDataConfiguration) =
          _createFakeModbusTcpService();
      final door = modbusTcpService.door;

      // write default data configuration
      await modbusTcpService
          .writeModbusDataConfiguration(defaultDataConfiguration);

      expect(door.individualName.value, isNull);

      // read register group
      await modbusTcpService
          .updateDoorModelByName(ModbusRegisterName.individualName);

      expect(door.individualName.value, equals("EFA-SmartConnect Mock"));
    });

    test('update model by group', () async {
      final (modbusTcpService, defaultDataConfiguration) =
          _createFakeModbusTcpService();
      final door = modbusTcpService.door;

      // write default data configuration
      await modbusTcpService
          .writeModbusDataConfiguration(defaultDataConfiguration);

      expect(door.individualName.value, isNull);
      expect(door.equipmentNumber.value, isNull);
      expect(door.profile.value, isNull);

      // read register group
      await modbusTcpService
          .updateDoorModelByGroup(ModbusRegisterGroup.equipmentInformation);

      expect(door.individualName.value, equals("EFA-SmartConnect Mock"));
      expect(door.equipmentNumber.value, equals(8000123456));
      expect(door.profile.value, equals("271"));
    });
  });
}
