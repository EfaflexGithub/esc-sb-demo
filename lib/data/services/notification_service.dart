import 'package:get/get.dart';
import 'package:local_notifier/local_notifier.dart';

class NotificationService extends GetxService {
  NotificationService();

  static Future<void> registerService({
    NotificationService? notificationService,
  }) async {
    if (notificationService != null) {
      Get.put(
        () => notificationService,
        tag: 'default',
      );
    } else {
      await Get.putAsync(
        () => NotificationService.initializedInstance(),
        tag: 'default',
      );
    }
  }

  static void unregisterService() {
    Get.delete<NotificationService>(tag: 'default');
  }

  factory NotificationService.find() =>
      Get.find<NotificationService>(tag: 'default');

  static Future<NotificationService> initializedInstance() async {
    await localNotifier.setup(appName: "EFA-SmartConnect Modbus Demo");
    return NotificationService();
  }

  Future<void> showNotification({
    required String title,
    String? subtitle,
    String? message,
    List<String>? actions,
    void Function(int?)? onClick,
    void Function(LocalNotificationCloseReason)? onClose,
  }) async {
    var notification = LocalNotification(
      title: title,
      subtitle: subtitle,
      body: message,
    )
      ..onClick = () {
        onClick?.call(null);
      }
      ..onClickAction = onClick
      ..onClose = onClose
      ..actions =
          actions?.map((e) => LocalNotificationAction(text: e)).toList();
    await notification.show();
  }
}
