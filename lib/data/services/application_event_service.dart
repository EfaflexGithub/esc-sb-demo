import 'dart:async';

import 'package:efa_smartconnect_modbus_demo/data/models/application_event.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ApplicationEventService extends GetxService {
  late final Isar isar;
  final _changedStream = GetStream<void>();
  final test = 0.obs;

  StreamSubscription<void> listen(
    void Function(void) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _changedStream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  Future<void> onInit() async {
    super.onInit();
    var directory = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ApplicationEventSchema],
        directory: directory.path, name: 'application-events');
  }

  @override
  Future<void> onClose() async {
    await isar.close();
  }

  Future<void> addEvent(ApplicationEvent event) async {
    bool notifyListeners = false;
    await isar.writeTxn(() async {
      bool existing = await isar.applicationEvents
              .filter()
              .dateTimeEqualTo(event.dateTime)
              .uuidEqualTo(event.uuid)
              .typeEqualTo(event.type)
              .dataEqualTo(event.data)
              .count() >
          0;
      if (!existing) {
        notifyListeners = true;
        await isar.applicationEvents.put(event);
      }
    });
    if (notifyListeners) {
      _changedStream.add(null);
    }
  }
}
