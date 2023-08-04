import 'package:efa_smartconnect_modbus_demo/data/services/application_event_service.dart';
import 'package:get/get.dart';

class EventOverviewController extends GetxController {
  final _appEventService = Get.find<ApplicationEventService>();

  Future<void> deleteAll() async {
    await _appEventService.deleteAll();
  }
}
