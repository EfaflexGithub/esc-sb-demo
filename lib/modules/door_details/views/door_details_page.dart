import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/door_details_controller.dart';

class DoorDetailsPage extends GetView<DoorDetailsController> {
  const DoorDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final door = controller.smartDoorService.door;
    return Scaffold(
      appBar: AppBar(
          title: Text(door.individualName.value ?? 'door details'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.rootDelegate.popRoute(popMode: PopMode.History);
            },
          )),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(controller.smartDoorService.uuid),
            Text(door.individualName.value ?? 'undefined'),
          ],
        ),
      ),
    );
  }
}
