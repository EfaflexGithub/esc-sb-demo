import 'package:data_table_2/data_table_2.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/application_event_service.dart';
import 'package:efa_smartconnect_modbus_demo/modules/event_overview/models/application_event_data_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventOverviewController extends GetxController {
  Future<void> deleteAll() async {
    final appEventService = ApplicationEventService.find();
    await appEventService.deleteAll();
  }

  AsyncDataTableSource getDataSource(BuildContext context) {
    return ApplicationEventDataSource(
        colorScheme: Theme.of(context).colorScheme);
  }
}
