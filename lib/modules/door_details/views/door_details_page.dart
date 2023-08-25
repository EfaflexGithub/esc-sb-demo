import 'package:context_menus/context_menus.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/information_entry.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/datetime_extensions.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/numeric_extensions.dart';
import 'package:efa_smartconnect_modbus_demo/shared/widgets/adaptive_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/door_details_controller.dart';
import '../models/event_data_source.dart';

class DoorDetailsPage extends GetView<DoorDetailsController> {
  const DoorDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = controller.smartDoorService;
    final door = service.door;
    return Scaffold(
      appBar: AppBar(
        title: Text(door.individualName ?? 'door details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.rootDelegate.popRoute(popMode: PopMode.History);
          },
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        child: SingleChildScrollView(
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
                    properties: {
                      ...service.uiConfiguration,
                      "UUID": service.uuid,
                    },
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
                          "Individual Name": door.individualName ?? '?',
                          "Equipment Number":
                              door.equipmentNumber?.toString() ?? '?',
                          "Construction Type": door.profile ?? '?',
                        },
                      )),
                  Obx(() => _buildTextPropertiesCard(
                        context: context,
                        properties: {
                          "Status": door.openingStatus.toString(),
                          "Opening Position":
                              door.openingPosition?.toPercentage() ?? '?',
                          "Current Speed": "${door.currentSpeed ?? '?'} Hz",
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
                          "Series": door.doorControl?.series.value ?? '?',
                          "Serial Number": door.doorControl?.serialNumber.value
                                  ?.toString() ??
                              '?',
                          "Firmware":
                              door.doorControl?.firmwareVersion.value ?? '?',
                          "Current Cycle Counter":
                              door.cycleCounter?.localized ?? '?',
                        },
                      )),
                  Obx(() => _buildTextPropertiesCard(
                        context: context,
                        properties: {
                          "Display Content":
                              door.doorControl?.displayContent.value ?? '?',
                        },
                      )),
                  if (door.doorControl != null)
                    ...door.doorControl!.controlInformation.map((e) =>
                        _buildEditablePropertiesCard(
                            context: context, informationEntries: e)),
                ],
              ),
              _buildGroup(
                context: context,
                title: 'Events',
                children: [
                  SizedBox(
                    height: 315,
                    child: Obx(() {
                      var doorControl = door.doorControl;
                      return switch (doorControl) {
                        null => const Text(
                            'Events not available as door control is not set'),
                        _ => PaginatedDataTable2(
                            source: EventDataSource(
                                eventEntries:
                                    doorControl.eventEntries.toList()),
                            columns: ['Date', 'Time', 'Cycles', 'Code']
                                .map((title) => DataColumn2(label: Text(title)))
                                .toList(),
                            showCheckboxColumn: false,
                            rowsPerPage: 4,
                            empty: const Center(
                                child: Text('No events available')),
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
                          inputDecorationTheme: const InputDecorationTheme(
                            isDense: true,
                          ),
                          dropdownMenuEntries: service.supportedUserApplications
                              .map(
                                (userApplication) => DropdownMenuEntry<String>(
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
                                  ),
                                ),
                              )
                              .toList(),
                        )
                    },
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildEditablePropertiesCard({
    required BuildContext context,
    required List<InformationEntry> informationEntries,
  }) {
    var showSaveButton = false;
    var enableSaveButton = false.obs;

    for (var e in informationEntries) {
      if (e.editable && e.value != null) {
        showSaveButton = true;
        break;
      }
    }

    void reevaluateEnableSaveButton() {
      bool enableButton = false;
      for (var entry in informationEntries) {
        if (entry.editable &&
            entry.value != null &&
            entry.value != entry.tempValue) {
          enableButton = true;
          break;
        }
      }
      enableSaveButton.value = enableButton;
    }

    void updateTempValue<T>(InformationEntry entry, T value) {
      entry.tempValue = value;
      reevaluateEnableSaveButton();
    }

    reevaluateEnableSaveButton();

    return _buildWidgetPropertiesCard(
      context: context,
      properties: {
        for (var entry in informationEntries)
          if (!entry.editable)
            entry.description: Text(entry.value.toString())
          else if (entry.value == null)
            entry.description: const Text('?')
          else if (entry is IntInformationEntry)
            entry.description: _buildEditableIntWidget(
              entry.value!,
              context: context,
              min: entry.min,
              max: entry.max,
              onChanged: (value) => updateTempValue(entry, value),
            )
          else if (entry is StringInformationEntry)
            entry.description: _buildEditableStringWidget(
              entry.value!,
              context: context,
              onChanged: (value) => updateTempValue(entry, value),
            )
          else if (entry is DateInformationEntry)
            entry.description: _buildEditableDateWidget(
              entry.value!,
              context: context,
              firstDate: entry.min,
              lastDate: entry.max,
              onChanged: (value) => updateTempValue(entry, value),
            )
          else if (entry is EnumInformationEntry<Enum>)
            entry.description: _buildEditableEnumWidget(
              entry.value!,
              entry.values,
              onChanged: (value) => updateTempValue(entry, entry.values[value]),
            )
      },
      actions: showSaveButton
          ? [
              Obx(() => TextButton(
                    onPressed: enableSaveButton.value
                        ? () async {
                            await controller
                                .saveInformationEntries(informationEntries);
                            reevaluateEnableSaveButton();
                          }
                        : null,
                    child: const Text('Save'),
                  ))
            ]
          : null,
    );
  }

  Widget _buildEditableIntWidget(
    int value, {
    required BuildContext context,
    ValueChanged<int>? onChanged,
    int? min,
    int? max,
  }) {
    final controller = TextEditingController(
      text: value.toString(),
    );
    final min_ = min ?? -2147483648;
    final max_ = max ?? 2147483647;
    final errorText = RxnString();

    void validateText() {
      final int? parsedValue = int.tryParse(controller.text);
      if (parsedValue == null || parsedValue < min_ || parsedValue > max_) {
        errorText.value = 'Invalid';
      } else {
        errorText.value = null;
      }
    }

    return Row(
      children: [
        Obx(
          () => AdaptiveTextField(
            controller: controller,
            style: Theme.of(context).inputDecorationTheme.labelStyle,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  min_ < 0 ? RegExp(r'[0-9\-]') : RegExp(r'[0-9]')),
            ],
            // inputFormatters: [NumericRangeInputFormatter(min: 5, max: 20)],
            textAlign: TextAlign.end,
            onChanged: (value) {
              validateText();
              if (errorText.value == null) {
                onChanged?.call(int.parse(value));
              }
            },
            decoration: InputDecoration(
              errorText: errorText.value,
            ),
          ),
        ),
        Tooltip(
          message: 'Must be between $min_ and $max_',
          child: Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableStringWidget(
    String value, {
    required BuildContext context,
    ValueChanged<String>? onChanged,
  }) {
    var controller = TextEditingController(
      text: value,
    );
    return AdaptiveTextField(
      controller: controller,
      style: Theme.of(context).inputDecorationTheme.labelStyle,
      textAlign: TextAlign.end,
      onChanged: (value) => onChanged?.call(value),
    );
  }

  Widget _buildEditableDateWidget(
    DateTime value, {
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    TimeOfDay? initialTime,
    ValueChanged<DateTime>? onChanged,
  }) {
    String formattedDate(DateTime date) {
      return [
        DateFormat.yMd('en_US').format(date),
        DateFormat.Hm('en_US').format(date),
      ].join(', ');
    }

    var textController = TextEditingController(text: formattedDate(value));

    void updateDate(DateTime newDate) {
      textController.text = formattedDate(newDate);
      onChanged?.call(newDate);
    }

    return Row(
      children: [
        SizedBox(
          width: 125,
          child: TextField(
            controller: textController,
            style: Theme.of(context).inputDecorationTheme.labelStyle,
            textAlign: TextAlign.end,
            canRequestFocus: false,
            onTap: () async {
              var pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate ?? DateTime.now(),
                firstDate: firstDate ?? DateTime(1900),
                lastDate: lastDate ?? DateTime(3000),
              );
              if (pickedDate != null && context.mounted) {
                var pickedTime = await showTimePicker(
                  context: context,
                  initialTime: initialTime ?? TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  var newDate = pickedDate.copyWithTimeOfDay(pickedTime);
                  updateDate(newDate);
                }
              }
            },
          ),
        ),
        const SizedBox(width: 5),
        IconButton(
          onPressed: () => updateDate(DateTime.now()),
          icon: const Icon(Icons.restore),
        ),
      ],
    );
  }

  Widget _buildEditableEnumWidget<T extends Enum>(
    T value,
    List<T> values, {
    ValueChanged<int>? onChanged,
  }) {
    return DropdownMenu<int>(
      initialSelection: value.index,
      requestFocusOnTap: false,
      onSelected: (value) => value != null ? onChanged?.call(value) : null,
      dropdownMenuEntries: values
          .map((e) => DropdownMenuEntry(
                value: e.index,
                label: e.toString(),
              ))
          .toList(),
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
                      ContextMenuRegion(
                          contextMenu: GenericContextMenu(
                            buttonConfigs: [
                              ContextMenuButtonConfig('Copy', onPressed: () {
                                var widget = mapEntry.value;
                                if (widget is Text) {
                                  Clipboard.setData(
                                      ClipboardData(text: widget.data ?? ""));
                                }
                              })
                            ],
                          ),
                          child: mapEntry.value),
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
