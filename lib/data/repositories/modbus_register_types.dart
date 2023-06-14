enum ModbusBitRegisterType {
  coil,
  discreteInput,
}

enum ModbusWordRegistersType {
  holdingRegister,
  inputRegister,
}

enum ModbusDataType {
  int16,
  int32,
  int64,
  uint16,
  uint32,
  uint64,
  ascii,
  unicode,
  dateTime,
  semVer,
  eventEntry,
}
