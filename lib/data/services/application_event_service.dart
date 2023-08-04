import 'dart:async';

import 'package:efa_smartconnect_modbus_demo/data/models/application_event.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ApplicationEventService extends GetxService {
  late final Isar isar;
  late final applicationEventsChanged = isar.applicationEvents.watchLazy();

  StreamSubscription<void> listen(
    void Function(void) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      applicationEventsChanged.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  Future<void> onInit() async {
    super.onInit();
    var directory = await getApplicationSupportDirectory();
    isar = await Isar.open([ApplicationEventSchema],
        directory: directory.path, name: 'application-events');
  }

  @override
  Future<void> onClose() async {
    await isar.close();
  }

  Future<void> addEvent(ApplicationEvent event) async {
    await isar.writeTxn(() async {
      await isar.applicationEvents
          .where()
          .dateTimeEqualTo(event.dateTime)
          .filter()
          .uuidEqualTo(event.uuid)
          .typeEqualTo(event.type)
          .findAll()
          .then((applicationEvents) async {
        for (var e in applicationEvents) {
          if (e.data.join(';') == event.data.join(';')) {
            return;
          }
        }
        await isar.applicationEvents.put(event);
      });
    });
  }

  Future<void> deleteAll() async {
    await isar.writeTxn(() async {
      await isar.applicationEvents.clear();
    });
  }
}
