import 'package:efa_smartconnect_modbus_demo/data/services/application_event_service.dart';
import 'package:get/get.dart';

class EventOverviewController extends GetxController {
  Future<void> deleteAll() async {
    final appEventService = ApplicationEventService.find();
    await appEventService.deleteAll();
  }
}
