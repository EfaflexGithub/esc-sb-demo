import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/door_overview_controller.dart';

class DoorOverviewPage extends GetView<DoorOverviewController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Door Overview'),
        centerTitle: true,
      ),
      body: Center(
        child: Obx(() => Text('${controller.count} doors')),
      ),
      // Drawer(
      //   width: 100,
      //   child: ListView(
      //     padding: EdgeInsets.zero,

      //     children: [
      //       const DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: Colors.orange,
      //         ),
      //         child: Text("Drawer Header"),
      //       ),
      //       ListTile(
      //         title: const Text('Door Overview'),
      //         onTap: () => Get.to(Routes.DOOR_OVERVIEW),
      //       )
      //     ],
      //   ),
      // ),

      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
