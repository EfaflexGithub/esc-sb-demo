import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
import 'package:efa_smartconnect_modbus_demo/data/providers/isar_provider.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/isar_repository.dart';
import 'package:isar/isar.dart';

extension DoorRepositoryExtensions on Door {
  Future<int> saveToCache() => DoorRepository().update(this);

  Future<void> copyFromCache({
    Id? id,
  }) async {
    final doorId = id ?? this.id;
    final door = await DoorRepository().getById(doorId);
    if (door != null) {
      copyFrom(door, copyDoorControl: false);
    }
  }
}

final class DoorRepository extends IsarRepository<Door> {
  DoorRepository() : super(isar: IsarProvider.application);

  Future<List<int>> searchIdsByName({required String search}) async {
    final isar = await this.isar;
    return isar.txn(() async {
      return isar.doors
          .filter()
          .individualNameContains(search)
          .idProperty()
          .findAll();
    });
  }

  Future<List<int>> searchIdsByEquipmentNumber({required String search}) async {
    final isar = await this.isar;
    return isar.txn(() async {
      var equipmentNumbers =
          await isar.doors.where().distinctByEquipmentNumber().findAll();
      return equipmentNumbers
          .where((door) => door.equipmentNumber.toString().contains(search))
          .map((door) => door.id)
          .toList();
    });
  }
}
