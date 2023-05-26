import 'package:get/get.dart';

class DoorOverviewController extends GetxController {
  var count = 0.obs;
  increment() {
    count++;

    // print the first 10 prime numbers if count is 52

    if (count % 5 == 0) {
      Get.defaultDialog(
          title: 'Door Overview', middleText: 'You have clicked $count times');
    }
  }
}
