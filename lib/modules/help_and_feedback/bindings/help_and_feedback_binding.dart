import 'package:get/get.dart';
import '../controllers/help_and_feedback_controller.dart';

class HelpAndFeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpAndFeedbackController>(
      () => HelpAndFeedbackController(),
    );
  }
}
