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
                _buildTextPropertiesCard(
                  context: context,
                  properties: service.uiConfiguration,
                ),
              ],
            ),
            _buildGroup(
              context: context,
              title: 'Door Information',
              children: [
                Obx(() => _buildTextPropertiesCard(
                      context: context,
                      properties: {
                        "Individual Name": door.individualName.value ?? '?',
                        "Equipment Number":
                            door.equipmentNumber.value?.toString() ?? '?',
                        "Construction Type": door.profile.value ?? '?',
                      },
                    )),
                Obx(() => _buildTextPropertiesCard(
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
                Obx(() => _buildTextPropertiesCard(
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
                Obx(() => _buildTextPropertiesCard(
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
                    return _buildTextPropertiesCard(
                      context: context,
                      properties: cardProperties,
                    );
                  })
                ],
              );
            }),
            _buildGroup(
              context: context,
              title: "User Applications",
              children: [
                _buildWidgetPropertiesCard(
                  context: context,
                  actions: [
                    FilledButton.tonal(
                      onPressed: () async {
                        await controller.saveUserApplications();
                      },
                      child: const Text('Save'),
                    )
                  ],
                  properties: {
                    for (var i = 0; i < controller.userApplicationsCount; i++)
                      "User Application $i": DropdownMenu<String>(
                        enableFilter: false,
                        enableSearch: false,
                        requestFocusOnTap: false,
                        initialSelection:
                            service.userApplications[i].definition?.value,
                        onSelected: (value) {
                          if (value != null) {
                            controller.userApplicationsTempValues[i] = value;
                          }
                        },
                        dropdownMenuEntries: service.supportedUserApplications
                            .map((userApplication) => DropdownMenuEntry<String>(
                                value: userApplication.value,
                                label: userApplication.label,
                                leadingIcon: Icon(userApplication.icon),
                                trailingIcon: Tooltip(
                                  message: userApplication.description,
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    size: 17,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.4),
                                  ),
                                )))
                            .toList(),
                      )
                  },
                ),
              ],
            ),
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
    List<Widget>? actions,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: horizontalPadding),
        child: Column(
          children: [
            child,
            if (actions != null)
              ButtonBar(
                children: actions,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextPropertiesCard({
    required BuildContext context,
    required Map<String, String> properties,
  }) {
    return _buildWidgetPropertiesCard(
      context: context,
      properties: properties.map((key, value) => MapEntry(key, Text(value))),
    );
  }

  Widget _buildWidgetPropertiesCard({
    required BuildContext context,
    required Map<String, Widget> properties,
    List<Widget>? actions,
  }) {
    return _buildCard(
      context: context,
      horizontalPadding: 0,
      verticalPadding: 0,
      actions: actions,
      child: Column(
        children: [
          ...properties.entries.map((mapEntry) {
            return Column(
              children: [
                if (mapEntry.key != properties.entries.first.key)
                  const Divider(thickness: 1, height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 23),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(mapEntry.key),
                      mapEntry.value,
                    ],
                  ),
                ),
              ],
            );
          }),
          if (actions != null) const Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }
}
