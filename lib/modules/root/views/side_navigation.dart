import 'package:efa_smartconnect_modbus_demo/modules/root/controllers/side_navigation_controller.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/views/settings_page.dart';
import '../../settings/models/application_setttings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SideNavigation extends StatelessWidget {
  SideNavigation({super.key});

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
          label: Text('Doors'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.info_outline),
          label: Text('Events'),
        ),
      ],
      trailing: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () =>
                  Get.to(() => const SettingsPage<ApplicationSettingKeys>()),
            ),
            IconButton(
              icon: const Icon(Icons.help),
              tooltip: 'Help',
              onPressed: () => controller.showAbout(
                context: context,
                applicationIcon: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset('assets/icon/icon.png'),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            )
            // NavigationRailIcon(
            //   icon: const Icon(Icons.settings),
            //   text: "Settings",
            //   onTap: () => Get.to(const SettingsPage()),
            // ),
            // NavigationRailIcon(
            //   icon: const Icon(Icons.help),
            //   text: "Help",
            //   onTap: () => controller.showAbout(
            //     context: context,
            //     applicationIcon: SizedBox(
            //       width: 64,
            //       height: 64,
            //       child: Image.asset('assets/icon/icon.png'),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
