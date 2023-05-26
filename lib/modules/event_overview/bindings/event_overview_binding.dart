import 'package:get/get.dart';

import '../controllers/event_overview_controller.dart';

class EventOverviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventOverviewController>(
      () => EventOverviewController(),
    );
  }
}
