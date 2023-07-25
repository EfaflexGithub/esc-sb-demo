import 'package:data_table_2/data_table_2.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/numeric_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/door_details_controller.dart';
import '../models/event_data_source.dart';

class DoorDetailsPage extends GetView<DoorDetailsController> {
  const DoorDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = controller.smartDoorService;
    final door = service.door;
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      appBar: AppBar(
          title: Text(door.individualName.value ?? 'door details'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.rootDelegate.popRoute(popMode: PopMode.History);
            },
          )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroup(
              context: context,
              title: 'Smart Door Configuration',
              children: [
                _buildPropertiesCard(
                  context: context,
                  properties: service.uiConfiguration,
                ),
              ],
            ),
            _buildGroup(
              context: context,
              title: 'Door Information',
              children: [
                Obx(() => _buildPropertiesCard(
                      context: context,
                      properties: {
                        "Individual Name": door.individualName.value ?? '?',
                        "Equipment Number":
                            door.equipmentNumber.value?.toString() ?? '?',
                        "Construction Type": door.profile.value ?? '?',
                      },
                    )),
                Obx(() => _buildPropertiesCard(
                      context: context,
                      properties: {
                        "Status": door.openingStatus.value.toString(),
                        "Opening Position":
                            door.openingPosition.value?.toPercentage() ?? '?',
                        "Current Speed": "${door.currentSpeed.value ?? '?'} Hz",
                      },
                    )),
              ],
            ),
            _buildGroup(
              context: context,
              title: 'Door Control',
              children: [
                Obx(() => _buildPropertiesCard(
                      context: context,
                      properties: {
                        "Series": door.doorControl.value?.series.value ?? '?',
                        "Serial Number": door
                                .doorControl.value?.serialNumber.value
                                ?.toString() ??
                            '?',
                        "Firmware":
                            door.doorControl.value?.firmwareVersion.value ??
                                '?',
                        "Current Cycle Counter":
                            door.cycleCounter.value?.localized ?? '?',
                      },
                    )),
                Obx(() => _buildPropertiesCard(
                      context: context,
                      properties: {
                        "Display Content":
                            door.doorControl.value?.displayContent.value ?? '?',
                      },
                    )),
              ],
            ),
            _buildGroup(
              context: context,
              title: 'Events',
              children: [
                SizedBox(
                  height: 315,
                  child: Obx(() {
                    var doorControl = door.doorControl.value;
                    return switch (doorControl) {
                      null => const Text(
                          'Events not available as door control is not set'),
                      _ => PaginatedDataTable2(
                          source: EventDataSource(
                              eventEntries: doorControl.eventEntries.toList()),
                          columns: ['Date', 'Time', 'Cycles', 'Code']
                              .map((title) => DataColumn2(label: Text(title)))
                              .toList(),
                          showCheckboxColumn: false,
                          rowsPerPage: 4,
                          empty:
                              const Center(child: Text('No events available')),
                          renderEmptyRowsInTheEnd: false,
                        )
                    };
                  }),
                ),
              ],
            ),
            ...service.additionalUiGroups.entries.map((uiGroup) {
              return _buildGroup(
                context: context,
                title: uiGroup.key,
                children: [
                  ...uiGroup.value.map((cardProperties) {
                    return _buildPropertiesCard(
                      context: context,
                      properties: cardProperties,
                    );
                  })
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(
      {required String title,
      required List<Widget> children,
      required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required BuildContext context,
    double verticalPadding = 8,
    double horizontalPadding = 8,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: horizontalPadding),
        child: child,
      ),
    );
  }

  Widget _buildPropertiesCard({
    required BuildContext context,
    required Map<String, String> properties,
  }) {
    return _buildCard(
      context: context,
      horizontalPadding: 0,
      child: Column(
        children: [
          ...properties.entries.map((mapEntry) {
            return Column(
              children: [
                if (mapEntry.key != properties.entries.first.key)
                  const Divider(thickness: 1, height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(mapEntry.key),
                        Text(mapEntry.value),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
