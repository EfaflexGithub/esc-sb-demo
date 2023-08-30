import 'dart:io';

import 'package:efa_smartconnect_modbus_demo/data/models/application_event.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/smart_door_service_repository.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarProvider {
  static const List<CollectionSchema> _schemas = [
    DoorSchema,
    IsarSmartDoorServiceSchema,
    ApplicationEventSchema,
  ];

  static Future<Isar> get application => getInstance(name: 'application');

  static Future<Isar> getInstance({
    required String name,
    String? subdirectory,
  }) async {
    final applicationSupportDirectory = await getApplicationSupportDirectory();

    final String path = switch (subdirectory) {
      null => applicationSupportDirectory.path,
      _ => "${applicationSupportDirectory.path}/$subdirectory",
    };

    final Directory directory = Directory(path);

    var instance = Isar.getInstance(name);

    if (instance != null) {
      return instance;
    }

    await directory.create(recursive: true);
    return await Isar.open(
      _schemas,
      name: name,
      directory: directory.path,
    );
  }
}
