import 'dart:async';
import 'package:build/build.dart';
import 'package:yaml/yaml.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/modbus_register_types.dart';

Map<String, String?> _modbusGroups = <String, String?>{};

class ModbusRegisterMapGenerator extends Builder {
  ModbusRegisterMapGenerator(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // Each `buildStep` has a single input.
    var inputId = buildStep.inputId;

    // Create a new target `AssetId` based on the old one.
    var copy = inputId.changeExtension('.g.dart');
    var contents = await buildStep.readAsString(inputId);

    // Write out the new asset.
    await buildStep.writeAsString(
        copy, generateModbusRegisterMapFile(contents).join());
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        ".yaml": [".g.dart"]
      };
}

Stream<String> generateModbusRegisterMapFile(String yamlString) async* {
  final yamlMap = loadYaml(yamlString);

  yield "import 'modbus_register.dart';\n";
  yield "import 'modbus_register_types.dart';\n\n";

  yield _generateModbusRegisterGroupEnum(yamlMap['groups']);

  yield* _generateModbusRegisterDefinitions(yamlMap['registers']);
}

String _generateModbusRegisterGroupEnum(YamlList map) {
  for (var group in map) {
    group as YamlMap;
    final String groupName = group.extractName();
    final String? parentGroup = group.extractGroup();
    _modbusGroups[groupName] = parentGroup;
  }

  return '''
enum ModbusRegisterGroup {
  ${_modbusGroups.keys.join(',\n  ')}
}
'''
      '\n';
}

Stream<String> _generateModbusRegisterDefinitions(YamlList map) async* {
  List<String> enumMembers = <String>[];
  List<String> registerDefinitions = <String>[];
  for (var register in map) {
    register as YamlMap;
    final String name = register.extractName();
    enumMembers.add(name);
    final registerDefinition =
        _generateModbusRegisterDefinition(name, register);
    registerDefinitions.add(registerDefinition);
  }

  yield '''
enum ModbusRegisterName {
  ${enumMembers.join(',\n  ')}
}
'''
      '\n';

  yield '''
const List<ModbusRegister> modbusRegisterMap = [
${registerDefinitions.join('\n')}
];
'''
      '\n';
}

String _generateModbusRegisterDefinition(String name, YamlMap map) {
  String? group = map.extractGroup();
  List<String?> groups = <String?>[];
  while (group != null) {
    groups.insert(0, "ModbusRegisterGroup.$group,");
    group = _modbusGroups[group];
  }
  final registerType = map.extractRegisterType();
  final address = map.extractAddress();

  late final String classType;
  late final ModbusDataType? dataType;
  late final int? length;
  switch (registerType) {
    case ModbusRegisterType.discreteInput:
    case ModbusRegisterType.coil:
      classType = "ModbusBitRegister";
      dataType = null;
      length = null;
      break;
    case ModbusRegisterType.holdingRegister:
    case ModbusRegisterType.inputRegister:
      classType = "ModbusWordRegister";
      dataType = map.extractDatatype();
      length = _getDataTypeLength(dataType) ?? map.extractLength();
      break;
  }
  final AccessType accessType = map.extractAccessType(registerType);

  switch (classType) {
    case "ModbusBitRegister":
      return '''
  ${classType.toString()} (
    name: ModbusRegisterName.$name,
    groups: [
      ${groups.join('\n      ')}
    ],
    type: $registerType,
    address: $address,
    accessType: $accessType,
  ),''';

    case "ModbusWordRegister":
      return '''
  ${classType.toString()} (
    name: ModbusRegisterName.$name,
    groups: [
      ${groups.join('\n      ')}
    ],
    type: $registerType,
    address: $address,
    accessType: $accessType,
    dataType: $dataType,
    length: $length,
  ),''';

    default:
      throw Exception('Unknown class type: $classType');
  }
}

extension GetStringUtils on String {
  String get camelCase {
    final separatedWords = split(RegExp(r'[\W]+'));
    separatedWords.removeWhere((element) => element.isEmpty);
    var newString = '';

    for (final word in separatedWords) {
      newString += word[0].toUpperCase() + word.substring(1);
    }

    return newString[0].toLowerCase() + newString.substring(1);
  }
}

extension _ParseModbusRegisterFields on YamlMap {
  String extractName() {
    return this['name']?.toString().camelCase ??
        (throw ArgumentError('Missing name'));
  }

  String? extractGroup() {
    return this['group']?.toString().camelCase;
  }

  ModbusRegisterType extractRegisterType() {
    switch (this['registerType'].toString()) {
      case 'Coil':
        return ModbusRegisterType.coil;
      case 'DiscreteInput':
        return ModbusRegisterType.discreteInput;
      case 'HoldingRegister':
        return ModbusRegisterType.holdingRegister;
      case 'InputRegister':
        return ModbusRegisterType.inputRegister;
      default:
        throw ArgumentError('Unknown ModbusRegisterType: $this');
    }
  }

  int extractAddress() {
    final address = this['address']?.toString();
    if (address == null) throw ArgumentError('Missing address');
    return int.parse(address);
  }

  ModbusDataType extractDatatype() {
    switch (this['datatype'].toString()) {
      case 'Boolean':
        return ModbusDataType.boolean;
      case 'Int16':
        return ModbusDataType.int16;
      case 'Int32':
        return ModbusDataType.int32;
      case 'Int64':
        return ModbusDataType.int64;
      case 'UInt16':
        return ModbusDataType.uint16;
      case 'UInt32':
        return ModbusDataType.uint32;
      case 'UInt64':
        return ModbusDataType.uint64;
      case 'Ascii':
        return ModbusDataType.ascii;
      case 'Unicode':
        return ModbusDataType.unicode;
      case 'DateTime':
        return ModbusDataType.dateTime;
      case 'SemVer':
        return ModbusDataType.semVer;
      case 'EventEntry':
        return ModbusDataType.eventEntry;
      default:
        throw ArgumentError('Unknown ModbusDataType: $this');
    }
  }

  int extractLength() {
    final length = this['length']?.toString();
    if (length == null) throw ArgumentError('Missing length');
    return int.parse(length);
  }

  AccessType extractAccessType(ModbusRegisterType registerType) {
    if (registerType == ModbusRegisterType.discreteInput ||
        registerType == ModbusRegisterType.inputRegister) {
      return AccessType.read;
    }

    String accessType =
        this['access'] ?? (throw ArgumentError('Missing access: $this'));
    return switch (accessType) {
      'R' => AccessType.read,
      'W' => AccessType.write,
      'R/W' => AccessType.readWrite,
      _ => throw ArgumentError('Unknown access type: $accessType'),
    };
  }
}

int? _getDataTypeLength(ModbusDataType datatype) {
  switch (datatype) {
    case ModbusDataType.boolean:
    case ModbusDataType.int16:
    case ModbusDataType.uint16:
      return 1;
    case ModbusDataType.int32:
    case ModbusDataType.uint32:
      return 2;
    case ModbusDataType.int64:
    case ModbusDataType.uint64:
    case ModbusDataType.dateTime:
      return 4;
    case ModbusDataType.semVer:
      return 5;
    case ModbusDataType.eventEntry:
      return 10;
    case ModbusDataType.ascii:
    case ModbusDataType.unicode:
      return null;
    default:
      throw ArgumentError('Invalid ModbusDataType: $datatype');
  }
}
