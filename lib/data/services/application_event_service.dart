import 'dart:async';

import 'package:efa_smartconnect_modbus_demo/data/models/application_event.dart';
import 'package:efa_smartconnect_modbus_demo/data/providers/isar_provider.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/application_event_repository.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/notification_service.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/controllers/settings_controller.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/models/application_setttings.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/datetime_extensions.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class ApplicationEventService extends GetxService {
  ApplicationEventService();

  static Future<void> registerService({
    ApplicationEventService? applicationEventService,
  }) async {
    if (applicationEventService != null) {
      Get.put(
        () => applicationEventService,
        tag: 'default',
      );
    } else {
      await Get.putAsync(
        () => ApplicationEventService.initializedInstance(),
        tag: 'default',
      );
    }
  }

  static void unregisterService() {
    Get.delete<ApplicationEventService>(tag: 'default');
  }

  factory ApplicationEventService.find() =>
      Get.find<ApplicationEventService>(tag: 'default');

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
    return appEventService;
  }

  @override
  void onInit() {
    super.onInit();
    IsarProvider.application.then((isar) {
      applicationEventsChanged = isar.applicationEvents.watchLazy();
    });
  }

  Future<void> addEvent(ApplicationEvent event) async {
    final repo = ApplicationEventRepository();
    if (!await repo.containsByValue(event)) {
      repo.create(event);
    }
    await showEventNotification(event);
  }

  Future<void> deleteAll() async {
    ApplicationEventRepository().deleteAll();
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
