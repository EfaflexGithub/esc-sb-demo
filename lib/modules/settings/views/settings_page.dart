import 'package:efa_smartconnect_modbus_demo/modules/settings/models/setting_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsPage<K> extends GetView<SettingsController<K>> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            primary: false,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              // backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              title: const Text('Application Settings'),
            ),
            body: Row(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.background,
                  child: Obx(
                    () => NavigationDrawer(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      indicatorColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                      onDestinationSelected:
                          controller.handleDrawerDestinationSelected,
                      selectedIndex: controller.selectedCategoryIndex.value,
                      children: [
                        const SizedBox(height: 16),
                        ...controller.applicationSettings.categories
                            .map((category) {
                          return NavigationDrawerDestination(
                            label: Text(category.label),
                            icon: Icon(category.icon),
                          );
                        }).toList()
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Obx(
                      () => ListView(
                          children: controller.selectedCategory?.groups
                                  .map(
                                    (group) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(group.label,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          const SizedBox(height: 8),
                                          _buildSettingsGroupCard(group,
                                              context: context),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList() ??
                              []),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Theme.of(context).colorScheme.background,
          child: ButtonBar(
            children: [
              Obx(() => OutlinedButton(
                    onPressed: controller.changes.value
                        ? controller.saveSettings
                        : null,
                    child: const Text('Save'),
                  )),
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  controller.discardSettings();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroupCard(SettingsGroup<K> settingsGroup,
      {required BuildContext context}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: colorScheme.background,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          for (var setting in settingsGroup.settings)
            Column(
              children: [
                if (setting is Setting<K, bool>)
                  _buildSwitchSettingRow(setting, context: context)
                else if (setting is Setting<K, String>)
                  _buildStringSettingRow(setting, context: context)
                else if (setting is Setting<K, int>)
                  _buildIntSettingRow(setting, context: context),
                if (setting != settingsGroup.settings.last)
                  const Divider(indent: 0, height: 1),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSwitchSettingRow(Setting<K, bool> setting,
      {required BuildContext context}) {
    final switchValue = RxBool(setting.temporaryValue);

    return _buildSettingRowWithOptionRight(
      title: setting.title,
      description: setting.description,
      rightWidget: Obx(
        () => Switch(
          trackOutlineColor:
              MaterialStateProperty.resolveWith((_) => Colors.transparent),
          value: switchValue.value,
          onChanged: (value) {
            switchValue.value = value;
            setting.temporaryValue = value;
            controller.reevaluateChanges();
          },
        ),
      ),
      context: context,
    );
  }

  Widget _buildStringSettingRow(Setting<K, String> setting,
      {required BuildContext context}) {
    var textEditingController = TextEditingController(
      text: setting.temporaryValue,
    );
    return _buildSettingRowWithOptionRight(
      title: setting.title,
      description: setting.description,
      rightWidget: _buildVariableWidthTextField(
          controller: textEditingController,
          onFocusChange: (value) {
            if (value == false) {
              setting.temporaryValue = textEditingController.text;
            }
            controller.reevaluateChanges();
          }),
      context: context,
    );
  }

  Widget _buildIntSettingRow(Setting<K, int> setting,
      {required BuildContext context}) {
    var textEditingController = TextEditingController(
      text: setting.temporaryValue.toString(),
    );
    return _buildSettingRowWithOptionRight(
      title: setting.title,
      description: setting.description,
      rightWidget: _buildVariableWidthTextField(
          controller: textEditingController,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onFocusChange: (value) {
            if (value == false) {
              setting.temporaryValue = int.parse(textEditingController.text);
            }
            controller.reevaluateChanges();
          }),
      context: context,
    );
  }

  Widget _buildSettingRowWithOptionRight(
      {required String title,
      required String description,
      required Widget rightWidget,
      required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              if (description.isNotEmpty)
                Text(description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.5))),
            ],
          ),
          rightWidget,
        ],
      ),
    );
  }

  Widget _buildVariableWidthTextField(
      {double minWidth = 100,
      double maxWidth = 400,
      TextEditingController? controller,
      List<TextInputFormatter>? inputFormatters,
      void Function(bool)? onFocusChange}) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
      child: IntrinsicWidth(
        child: Focus(
          onFocusChange: (value) =>
              onFocusChange != null ? onFocusChange(value) : null,
          child: TextField(
            controller: controller,
            autocorrect: false,
            textAlign: TextAlign.end,
            inputFormatters: inputFormatters,
          ),
        ),
      ),
    );
  }
}
