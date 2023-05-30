import 'package:efa_smartconnect_modbus_demo/modules/root/controllers/side_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/pages.dart';

class SideNavigation extends StatelessWidget {
  final SideNavigationController controller =
      Get.put(SideNavigationController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                  ),
                  child: Center(
                    child: Text(
                      "Drawer Header",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Door Overview'),
                  leading: const Icon(Icons.home),
                  onTap: () => Get.rootDelegate.toNamed(Routes.doorOverview),
                ),
                ListTile(
                  title: const Text('Event Overview'),
                  leading: const Icon(Icons.info_outline),
                  onTap: () => Get.rootDelegate.toNamed(Routes.eventOverview),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () => Get.rootDelegate.toNamed(Routes.settings),
          ),
          ListTile(
            title: const Text('Help & Feedback'),
            leading: const Icon(Icons.help),
            onTap: () => Get.rootDelegate.toNamed(Routes.helpAndFeedback),
          ),
          Obx(() => Text("Version ${controller.version.value}")),
        ],
      ),
    );
  }
}
