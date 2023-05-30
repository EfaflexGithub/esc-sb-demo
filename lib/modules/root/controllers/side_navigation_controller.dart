import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SideNavigationController extends GetxController {
  final version = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
  }
}
