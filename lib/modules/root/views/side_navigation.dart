import 'package:efa_smartconnect_modbus_demo/modules/root/controllers/side_navigation_controller.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/views/settings_page.dart';
import 'package:efa_smartconnect_modbus_demo/shared/widgets/NavigationRailIcon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/pages.dart';

class SideNavigation extends StatelessWidget {
  final SideNavigationController controller =
      Get.put(SideNavigationController());

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: controller.selectedIndex.value,
      onDestinationSelected: (int index) => controller.changePage(index),
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Door Overview'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.info_outline),
          label: Text('Event Overview'),
        ),
      ],
      trailing: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            NavigationRailIcon(
              icon: const Icon(Icons.settings),
              text: "Settings",
              onTap: () => Get.to(const SettingsPage()),
            ),
            NavigationRailIcon(
              icon: const Icon(Icons.help),
              text: "Help",
              onTap: () => controller.showAbout(
                context: context,
                applicationIcon: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset('assets/icon/icon.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
