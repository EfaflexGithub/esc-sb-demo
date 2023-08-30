import 'package:efa_smartconnect_modbus_demo/data/models/application_event.dart';
import 'package:efa_smartconnect_modbus_demo/data/providers/isar_provider.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/isar_repository.dart';
import 'package:isar/isar.dart';

final class ApplicationEventRepository
    extends IsarRepository<ApplicationEvent> {
  ApplicationEventRepository() : super(isar: IsarProvider.application);

  Future<bool> containsByValue(ApplicationEvent event) async {
    final isar = await this.isar;
    return isar.txn(() async {
      var applicationEvents = await isar.applicationEvents
          .where()
          .dateTimeEqualTo(event.dateTime)
          .filter()
          .doorIdEqualTo(event.doorId)
          .typeEqualTo(event.type)
          .findAll();
      for (var e in applicationEvents) {
        if (e.data.join(';') == event.data.join(';')) {
          return true;
        }
      }
      return false;
    });
  }
}
