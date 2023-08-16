import 'package:efa_smartconnect_modbus_demo/data/services/door_collection_service.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/modbus_tcp_service.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/controllers/settings_controller.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/models/application_setttings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoorOverviewController extends GetxController {
  final showCheckboxColumn = false.obs;

  final doorCollectionService = DoorCollectionService.find();

  final enableStopServiceIcon = false.obs;

  final enableStartServiceIcon = false.obs;

  final enableRemoveIcon = false.obs;

  late final Rx<int> eventHighlightTime;
  late final Rx<int> eventHighlightCycles;
  late final Rx<bool> showUnknownUserApplications;

  @override
  void onInit() {
    super.onInit();
    eventHighlightTime = SettingsController.find<AppSettingKeys>()
        .getObservableValueFromKey<int>(AppSettingKeys.eventHighlightingTime);
    eventHighlightCycles = SettingsController.find<AppSettingKeys>()
        .getObservableValueFromKey(AppSettingKeys.eventHighlightingCycles);
    showUnknownUserApplications = SettingsController.find<AppSettingKeys>()
        .getObservableValueFromKey(AppSettingKeys.showUnknownUserApplications);
  }

  PersistentBottomSheetController? bottomSheetController;

  void updateIconStates() {
    bool startServiceIcon = false;
    bool stopServiceIcon = false;
    bool deleteIcon = false;
    for (var service in doorCollectionService.smartDoorServices) {
      if (service.selected.value) {
        deleteIcon = true;
        if (service.isServiceRunning.value) {
          stopServiceIcon = true;
        } else {
          startServiceIcon = true;
        }
      }
    }
    enableStartServiceIcon.value = startServiceIcon;
    enableStopServiceIcon.value = stopServiceIcon;
    enableRemoveIcon.value = deleteIcon;
  }

  void startSelectedServices() {
    doorCollectionService.smartDoorServices
        .where((service) => service.selected.value)
        .forEach((service) {
      service.start();
    });
  }

  void stopSelectedServices() {
    doorCollectionService.smartDoorServices
        .where((service) => service.selected.value)
        .forEach((service) {
      service.stop();
    });
  }

  Future<void> removeSelectedServices() async {
    await doorCollectionService.removeWhere(
      (service) => service.selected.value,
    );
  }

  void leaveEditMode() {
    for (var service in doorCollectionService.smartDoorServices) {
      service.selected.value = false;
    }
    bottomSheetController?.close();
    bottomSheetController = null;
    showCheckboxColumn.value = false;
    updateIconStates();
  }

  void showAddModbusTcpDoorDialog() {
    final settingsController = SettingsController.find<AppSettingKeys>();
    final TextEditingController ipController = TextEditingController(
        text: settingsController.getValueFromKey<String>(
            AppSettingKeys.defaultModbusTcpHostAddress));
    final TextEditingController portController = TextEditingController(
        text: settingsController
            .getValueFromKey<int>(AppSettingKeys.defaultModbusTcpPort)
            .toString());
    final TextEditingController refreshRateController = TextEditingController(
        text: settingsController
            .getValueFromKey<int>(AppSettingKeys.defaultModbusTcpRefreshRate)
            .toString());
    final TextEditingController licenseController = TextEditingController(
        text: settingsController.getValueFromKey<String>(
            AppSettingKeys.defaultModbusTcpLicenseKey));

    Get.defaultDialog(
      title: 'Add New Modbus Tcp Door',
      middleText: "Provide required information to add the new door.",
      titlePadding: const EdgeInsets.all(20),
      contentPadding: const EdgeInsets.all(20),
      textConfirm: "Add",
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
      content: Container(
        constraints: const BoxConstraints(minWidth: 400),
        child: Column(
          children: [
            TextField(
              controller: ipController,
              decoration: const InputDecoration(labelText: 'IP'),
            ),
            TextField(
              controller: portController,
              decoration: const InputDecoration(labelText: 'Port'),
            ),
            TextField(
              controller: refreshRateController,
              decoration: const InputDecoration(labelText: 'Refresh Rate'),
            ),
            TextField(
              controller: licenseController,
              decoration: const InputDecoration(labelText: 'License Key'),
            ),
          ],
        ),
      ),
      onConfirm: () async {
        String ip = ipController.text;
        String port = portController.text;
        int refreshRate = int.parse(refreshRateController.text, radix: 10);
        // String licenseKey = licenseController.text;

        var service = await doorCollectionService.add(
          ModbusTcpService.fromConfig(
            ModbusTcpServiceConfiguration(
              ip: ip,
              port: int.parse(port),
              refreshRate: Duration(milliseconds: refreshRate),
            ),
          ),
        ) as ModbusTcpService;

        await service.start();

        Get.back(); // Close the dialog
      },
    );
  }
}
