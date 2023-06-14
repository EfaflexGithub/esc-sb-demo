import 'package:build/build.dart';

import 'src/modbus_register_map_generator.dart';

Builder modbusRegisterMapBuilder(BuilderOptions options) {
  return ModbusRegisterMapGenerator(options);
}
