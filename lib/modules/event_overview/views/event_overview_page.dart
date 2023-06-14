import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_overview_controller.dart';

class EventOverviewPage extends GetView<EventOverviewController> {
  const EventOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Obx(() => Text('${controller.count} unread events'))),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.warning),
      ),
    );
  }
}
