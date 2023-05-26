import 'package:get/get.dart';

class EventOverviewController extends GetxController {
  var count = 0.obs;
  increment() {
    count++;

    // print the first 10 prime numbers if count is 52

    if (count % 5 == 0) {
      Get.defaultDialog(
          title: 'Event Overview', middleText: 'You have $count events');
    }
  }
}
