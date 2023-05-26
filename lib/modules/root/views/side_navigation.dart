import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/pages.dart';

class SideNavigation extends StatelessWidget {
  const SideNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        padding: EdgeInsets.zero,
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
            onTap: () => Get.rootDelegate.toNamed(Routes.DOOR_OVERVIEW),
          ),
          ListTile(
            title: const Text('Event Overview'),
            onTap: () => Get.rootDelegate.toNamed(Routes.EVENT_OVERVIEW),
          ),
        ],
      ),
    );
  }
}
