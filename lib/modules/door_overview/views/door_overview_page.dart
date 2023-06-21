import 'dart:developer';

import 'package:data_table_2/data_table_2.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/door_overview_controller.dart';

class DoorOverviewPage extends GetView<DoorOverviewController> {
  const DoorOverviewPage({super.key});

  static const List<(String, dynamic?)> columnTitles = [
    ('', 50),
    ('Status', ColumnSize.S),
    ('Equipment', ColumnSize.M),
    ('Name', ColumnSize.M),
    ('Display', ColumnSize.M),
    ('Position', ColumnSize.S),
    ('Event', ColumnSize.L),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => DataTable2(
            columnSpacing: 1,
            horizontalMargin: 0,
            minWidth: 1000,
            showCheckboxColumn: false,
            columns: columnTitles.map<DataColumn>(_buildColumnTitle).toList(),
            rows: controller.doorCollectionService.smartDoorServices
                .map((service) => _buildDataRow(context, service))
                .toList(),
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

  static DataColumn _buildColumnTitle((String, dynamic) record) {
    var (title, width) = record;

    double? fixedWidth = (width is int || width is double) ? width + .0 : null;
    ColumnSize size = (width is ColumnSize) ? width : ColumnSize.M;

    return DataColumn2(
      size: size,
      fixedWidth: fixedWidth,
      label: Center(child: Text(title)),
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
        DataCell(Center(
            child: Text(door.doorControl.value?.displayContent.value ?? '?'))),
        DataCell(Text(door.openingStatus.value.toString())),
        DataCell(
          Text(door.doorControl.value?.eventEntries.firstOrNull?.toString() ??
              '?'),
        ),
      ],
    );
  }
}
