import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/door_overview_controller.dart';

class DoorOverviewPage extends GetView<DoorOverviewController> {
  const DoorOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Obx(
            () => DataTable(
              columns: const [
                DataColumn(label: Expanded(child: Text('Status'))),
                DataColumn(label: Expanded(child: Text('Equipment'))),
                DataColumn(label: Expanded(child: Text('Name'))),
                DataColumn(label: Expanded(child: Text('Display'))),
                DataColumn(label: Expanded(child: Text('Position'))),
                DataColumn(label: Expanded(child: Text('Event'))),
              ],
              rows: controller.doorCollectionService.smartDoorServices
                  .map((smartDoorService) {
                var door = smartDoorService.door;
                return DataRow(cells: [
                  DataCell(Text(smartDoorService.status.value)),
                  DataCell(Text(door.equipmentNumber.value?.toString() ?? '?')),
                  DataCell(Text(door.individualName.value?.toString() ?? '?')),
                  DataCell(Text(
                      door.doorControl.value?.displayContent.value ?? '?')),
                  DataCell(Text(door.openingStatus.value.toString() ?? '?')),
                  DataCell(Text(door.equipmentNumber.value?.toString() ?? '?')),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.showAddModbusTcpDoorDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
