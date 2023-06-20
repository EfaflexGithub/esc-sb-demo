enum ModbusRegisterType {
  coil,
  discreteInput,
  holdingRegister,
  inputRegister,
}

enum ModbusDataType {
  boolean,
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

enum AccessType {
  read,
  write,
  readWrite;

  bool contains(AccessType other) {
    return switch (this) {
      readWrite when other == readWrite => true,
      readWrite || write when other == write => true,
      readWrite || read when other == read => true,
      _ => false,
    };
  }

  bool isWritable() {
    return this == AccessType.write || this == AccessType.readWrite;
  }

  bool isReadable() {
    return this == AccessType.read || this == AccessType.readWrite;
  }
}
