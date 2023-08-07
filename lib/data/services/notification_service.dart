import 'package:get/get.dart';
import 'package:local_notifier/local_notifier.dart';

class NotificationService extends GetxService {
  NotificationService();

  factory NotificationService.find() => Get.find<NotificationService>();

  @override
  Future<void> onInit() async {
    super.onInit();
    await localNotifier.setup(appName: "EFA-SmartConnect Modbus Demo");
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
