import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/application_event.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/application_event_service.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/numeric_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

class ApplicationEventDataSource extends AsyncDataTableSource {
  final service = Get.find<ApplicationEventService>();
  final ColorScheme colorScheme;
  late final serviceListener = service.listen((_) {
    refreshDatasource();
  });

  ApplicationEventDataSource({required this.colorScheme});

  @override
  void dispose() {
    serviceListener.cancel();
    super.dispose();
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final isar = service.isar;
    var totalCount = await isar.applicationEvents.count();

    var events = await isar.applicationEvents
        .where(sort: Sort.desc)
        .anyDateTime()
        .offset(startIndex)
        .limit(count)
        .findAll();

    var result = AsyncRowsResponse(
      totalCount,
      await Future.wait(events.map(
        (event) async {
          var cachedDoorData = await SmartDoorService.getCacheData(event.uuid);
          var message = await event.getMessage();
          var icon = switch (event.severity) {
            Severity.error => Icon(Icons.error, color: colorScheme.error),
            Severity.warning =>
              Icon(Icons.warning_amber_rounded, color: colorScheme.secondary),
            Severity.info =>
              Icon(Icons.info, color: colorScheme.secondaryContainer),
          };
          return DataRow(
            cells: [
              DataCell(icon),
              DataCell(Text(event.dateTime.localized)),
              DataCell(Text(cachedDoorData?['individual-name'] ?? event.uuid)),
              DataCell(Text(event.type.toString())),
              DataCell(Text(message)),
            ],
          );
        },
      ).toList()),
    );

    return result;
  }

  @override
  int get rowCount => service.isar.applicationEvents.countSync();
}
