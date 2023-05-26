import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController c = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Door Overview'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: null,
      ),
    );
  }
}
