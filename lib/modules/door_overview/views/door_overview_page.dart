import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/door_overview_controller.dart';

class DoorOverviewPage extends GetView<DoorOverviewController> {
  const DoorOverviewPage({super.key});

  static const List<String> columnTitles = [
    '',
    'Status',
    'Equipment',
    'Name',
    'Display',
    'Position',
    'Event',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Obx(
            () => DataTable(
              showCheckboxColumn: false,
              columns: columnTitles.map(_buildColumnTitle).toList(),
              rows: controller.doorCollectionService.smartDoorServices
                  .map((smartDoorService) =>
                      _buildDataRow(context, smartDoorService))
                  .toList(),
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

  static DataColumn _buildColumnTitle(String title) {
    return DataColumn(
      label: Expanded(
        child: Center(
          child: Text(title),
        ),
      ),
    );
  }

  DataRow _buildDataRow(
      BuildContext context, SmartDoorService smartDoorService) {
    var door = smartDoorService.door;
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
        }
        return null;
      }),
      onSelectChanged: (bool? value) {},
      cells: [
        DataCell(
          Row(
            children: [
              IconButton(
                iconSize: 20,
                icon: smartDoorService.isServiceRunning.value
                    ? const Icon(Icons.stop)
                    : const Icon(Icons.play_arrow),
                color: smartDoorService.isServiceRunning.value
                    ? Colors.red
                    : Colors.green,
                tooltip: smartDoorService.isServiceRunning.value
                    ? 'Stop Service'
                    : 'Start Service',
                onPressed: () => smartDoorService.isServiceRunning.value
                    ? smartDoorService.stop()
                    : smartDoorService.start(),
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: smartDoorService.statusColorValue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(smartDoorService.statusString.value),
                  ],
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(door.equipmentNumber.value?.toString() ?? '?')),
        DataCell(Text(door.individualName.value?.toString() ?? '?')),
        DataCell(Text(door.doorControl.value?.displayContent.value ?? '?')),
        DataCell(Text(door.openingStatus.value.toString())),
        DataCell(
          Text(door.doorControl.value?.eventEntries.firstOrNull?.toString() ??
              '?'),
        ),
      ],
    );
  }
}
