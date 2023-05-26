import 'package:get/get.dart';

import '../controllers/door_overview_controller.dart';

class DoorOverviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoorOverviewController>(
      () => DoorOverviewController(),
    );
  }
}
