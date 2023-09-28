import 'package:data_table_2/data_table_2.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/door.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/user_application.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';
import 'package:efa_smartconnect_modbus_demo/routes/pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/door_overview_controller.dart';

class DoorOverviewPage extends GetView<DoorOverviewController> {
  const DoorOverviewPage({super.key});

  static const List<(String, dynamic)> columnTitles = [
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
        child: Builder(builder: (context) {
          return Obx(
            () => DataTable2(
              columnSpacing: 1,
              horizontalMargin: 0,
              minWidth: 1000,
              showCheckboxColumn: controller.showCheckboxColumn.value,
              columns: [
                DataColumn2(
                  fixedWidth: 100,
                  label: Row(
                    children: [
                      Visibility(
                        visible: controller
                            .doorCollectionService.smartDoorServices.isNotEmpty,
                        child: IconButton(
                            iconSize: 20,
                            icon: Icon(controller.showCheckboxColumn.value
                                ? Icons.cancel
                                : Icons.edit),
                            onPressed: () {
                              controller.showCheckboxColumn.toggle();
                              if (controller.showCheckboxColumn.value) {
                                _enterEditMode(context);
                              } else {
                                controller.leaveEditMode();
                              }
                            }),
                      ),
                      const Center(child: Text('Actions'))
                    ],
                  ),
                ),
                ...columnTitles.map<DataColumn>(_buildColumnTitle).toList()
              ],
              rows: controller.doorCollectionService.smartDoorServices
                  .map((service) => _buildDataRow(context, service))
                  .toList(),
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.showAddModbusTcpDoorDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _enterEditMode(BuildContext context) {
    if (controller.bottomSheetController != null) {
      return;
    }
    controller.showCheckboxColumn.value = true;
    controller.bottomSheetController = showBottomSheet<void>(
      enableDrag: false,
      elevation: 8,
      context: context,
      builder: (context) {
        List<(String, IconData, RxBool, void Function()?)> actions = [
          (
            'Start Service',
            Icons.play_arrow,
            controller.enableStartServiceIcon,
            controller.startSelectedServices,
          ),
          (
            'Stop Service',
            Icons.stop,
            controller.enableStopServiceIcon,
            controller.stopSelectedServices,
          ),
          (
            'Remove',
            Icons.delete_forever,
            controller.enableRemoveIcon,
            controller.removeSelectedServices,
          ),
          (
            'Cancel',
            Icons.cancel,
            true.obs,
            controller.leaveEditMode,
          ),
        ];
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: List.generate(
                actions.length,
                (index) => _buildActionButton(actions.elementAt(index)),
              ),
            ),
          ),
        );
      },
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
    var lastEvent = door.doorControl?.eventEntries.firstOrNull;
    var doorCycles = door.cycleCounter;
    var eventCycles = lastEvent?.cycleCounter;
    var eventDateTime = lastEvent?.dateTime;
    var highlightEvent = (doorCycles != null &&
            eventCycles != null &&
            doorCycles - eventCycles < controller.eventHighlightCycles.value) ||
        (eventDateTime != null &&
            DateTime.now().difference(eventDateTime) <
                Duration(hours: controller.eventHighlightTime.value));
    return DataRow(
      onLongPress: () {
        smartDoorService.selected.value = true;
        _enterEditMode(context);
      },
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
        }
        return null;
      }),
      selected: smartDoorService.selected.value,
      onSelectChanged: (bool? value) {
        if (value != null) {
          if (controller.showCheckboxColumn.value) {
            smartDoorService.selected.value = value;
            controller.updateIconStates();
          } else {
            Get.rootDelegate.toNamed(Routes.doorDetails(smartDoorService.id));
          }
        }
      },
      cells: [
        DataCell(
          ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Row(
                children: [
                  Visibility(
                    visible: !smartDoorService.isServiceRunning.value,
                    child: IconButton(
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.play_arrow),
                      color: Colors.green,
                      tooltip: 'Start Service',
                      onPressed: () => smartDoorService.start(),
                    ),
                  ),
                  ..._buildServiceActions(smartDoorService.serviceActions),
                  ..._buildUserApplicationActions(smartDoorService),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Tooltip(
            message: smartDoorService.tooltip.value,
            child: Row(
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
        ),
        DataCell(Text(door.equipmentNumber?.toString() ?? '?')),
        DataCell(Text(door.individualName?.toString() ?? '?')),
        DataCell(
            Center(child: Text(door.doorControl?.displayContent.value ?? '?'))),
        DataCell(Text(switch (door.openingStatus) {
          OpeningStatus.unknown => '?',
          OpeningStatus.opening ||
          OpeningStatus.intermediate ||
          OpeningStatus.closing when door.openingPosition != null =>
            '${door.openingStatus.toString()} (${(door.openingPosition! * 100).round()} %)',
          _ => door.openingStatus.toString(),
        })),
        if (lastEvent != null)
          DataCell(
            Tooltip(
              message: lastEvent.toString(),
              child: Text(lastEvent.code,
                  style: highlightEvent
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold)
                      : null),
            ),
          )
        else
          const DataCell(Text('?'))
      ],
    );
  }

  Widget _buildActionButton(
      (String, IconData, RxBool, void Function()?) record) {
    var (label, icon, enabled, action) = record;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Obx(
            () => IconButton(
              onPressed: enabled.value
                  ? () async {
                      if (action != null) {
                        if (action is Future<void> Function()) {
                          await action();
                        } else {
                          action();
                        }
                        controller.leaveEditMode();
                      }
                    }
                  : null,
              icon: Icon(icon),
            ),
          ),
          Text(label),
        ],
      ),
    );
  }

  Iterable<Widget> _buildUserApplicationActions(
      SmartDoorService smartDoorService) {
    return smartDoorService.userApplications.map((app) {
      return Obx(
        () => Visibility(
          visible: app.type != null &&
              app.type != UserApplicationType.disabled &&
              (controller.showUnknownUserApplications.value ||
                  app.definition?.label.toLowerCase() != "unknown"),
          child: Tooltip(
            message: [
              app.definition?.label,
              app.definition?.description,
            ].join('\n'),
            child: IconButton(
              iconSize: 20,
              visualDensity: VisualDensity.compact,
              icon: Icon(app.definition?.icon),
              isSelected:
                  app.type == UserApplicationType.toggle ? app.state : null,
              selectedIcon: app.definition?.selectedIcon != null
                  ? Icon(app.definition?.selectedIcon)
                  : null,
              onPressed:
                  smartDoorService.status.value != SmartDoorServiceStatus.okay
                      ? null
                      : () async {
                          await app.activate();
                        },
            ),
          ),
        ),
      );
    });
  }

  Iterable<Widget> _buildServiceActions(RxList<ServiceAction> serviceActions) {
    return serviceActions.map((serviceAction) {
      return Tooltip(
        message: [
          serviceAction.name,
          serviceAction.description,
        ].join('\n'),
        child: IconButton(
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            icon: Icon(serviceAction.iconData),
            onPressed: serviceAction.onPressed),
      );
    });
  }
}
