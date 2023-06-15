import 'package:efa_smartconnect_modbus_demo/data/models/efa_tronic.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/door_collection_service.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/modbus_tcp_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoorOverviewController extends GetxController {
  final doorCollectionService = Get.find<DoorCollectionService>();

  showAddModbusTcpDoorDialog() {
    final TextEditingController ipController =
        // TextEditingController(text: "10.10.20.70");
        TextEditingController(text: "192.168.10.11");
    final TextEditingController portController =
        TextEditingController(text: "502");
    final TextEditingController refreshRate =
        TextEditingController(text: "1000");
    final TextEditingController licenseController = TextEditingController();

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
      content: Column(
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
            controller: refreshRate,
            decoration: const InputDecoration(labelText: 'Refresh Rate'),
          ),
          TextField(
            controller: licenseController,
            decoration: const InputDecoration(labelText: 'License Key'),
          ),
        ],
      ),
      onConfirm: () async {
        String ip = ipController.text;
        String port = portController.text;
        // String licenseKey = licenseController.text;

        final doorCollectionService = Get.find<DoorCollectionService>();

        var service = doorCollectionService.add(
          ModbusTcpService(
            ModbusTcpServiceConfiguration(
              ip: ip,
              port: int.parse(port),
            ),
          ),
        ) as ModbusTcpService;

        service.door.doorControl = EfaTronic().obs;

        await service.updateIndividualName();
        await service.updateCycles();

        Get.back(); // Close the dialog
      },
    );
  }
}
