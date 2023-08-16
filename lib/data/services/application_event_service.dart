import 'dart:async';

import 'package:efa_smartconnect_modbus_demo/data/models/application_event.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/notification_service.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/controllers/settings_controller.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/models/application_setttings.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/datetime_extensions.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ApplicationEventService extends GetxService {
  ApplicationEventService();

  static registerService({
    ApplicationEventService? applicationEventService,
  }) {
    if (applicationEventService != null) {
      Get.put(
        () => applicationEventService,
        tag: 'default',
      );
    } else {
      Get.putAsync(
        () => ApplicationEventService.initializedInstance(),
        tag: 'default',
      );
    }
  }

  static unregisterService() {
    Get.delete<ApplicationEventService>(tag: 'default');
  }

  factory ApplicationEventService.find() =>
      Get.find<ApplicationEventService>(tag: 'default');

  late Isar isar;
  late Stream<void> applicationEventsChanged;

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

  static Future<ApplicationEventService> initializedInstance() async {
    var appEventService = ApplicationEventService();
    var directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    appEventService.isar = await Isar.open([ApplicationEventSchema],
        directory: directory.path, name: 'application-events');
    return appEventService;
  }

  @override
  void onInit() {
    super.onInit();
    applicationEventsChanged = isar.applicationEvents.watchLazy();
  }

  @override
  void onClose() {
    isar.close();
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
        await showEventNotification(event);
      });
    });
  }

  Future<void> deleteAll() async {
    await isar.writeTxn(() async {
      await isar.applicationEvents.clear();
    });
  }

  Future<void> showEventNotification(ApplicationEvent event) async {
    final appSettings = SettingsController.find<AppSettingKeys>();

    final severityEnabled = switch (event.severity) {
      Severity.error =>
        appSettings.getValueFromKey<bool>(AppSettingKeys.notifyErrorEvents),
      Severity.warning =>
        appSettings.getValueFromKey<bool>(AppSettingKeys.notifyWarningEvents),
      Severity.info =>
        appSettings.getValueFromKey<bool>(AppSettingKeys.notifyInfoEvents),
    };

    if (!severityEnabled) {
      return;
    }

    final age = DateTime.now().difference(event.dateTime).inHours;
    final maxAge =
        appSettings.getValueFromKey<int>(AppSettingKeys.notifyTimeTreshold);

    if (age > maxAge) {
      return;
    }

    switch (event.type) {
      case EventType.doorControl:
        break;
      case EventType.smartDoorService:
        break;
      default:
        throw UnimplementedError();
    }
    final String title = await event.getIndividualName();
    final subtitle = event.type.toString();
    final message = await event.getMessage();

    final notificationService = NotificationService.find();
    await notificationService.showNotification(
      title: title,
      // subtitle: subtitle,
      message: [subtitle, event.dateTime.localized, message].join('\n'),
    );
  }
}
