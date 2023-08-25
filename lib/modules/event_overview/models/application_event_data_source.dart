import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/application_event.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/application_event_service.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/smart_door_service.dart';
import 'package:efa_smartconnect_modbus_demo/shared/widgets/filters.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/datetime_extensions.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class ApplicationEventDataSource extends AsyncDataTableSource {
  final service = ApplicationEventService.find();
  final ColorScheme colorScheme;
  late final serviceListener = service.listen((_) {
    refreshDatasource();
  });

  final FilterCategories filterCategories = FilterCategories(
    categories: [
      FilterCategory(
        name: 'Date',
        filters: [
          DateRangeFilter(),
        ],
      ),
      FilterCategory(
        name: 'Door',
        filters: [TextFilter()],
      ),
      FilterCategory(
        name: 'Event Types',
        filters: [
          ElementsFilter<EventType>(keys: EventType.values),
        ],
      ),
      FilterCategory(
        name: 'Message',
        filters: [TextFilter()],
      ),
    ],
  );

  ApplicationEventDataSource({
    required this.colorScheme,
  });

  @override
  void dispose() {
    serviceListener.cancel();
    super.dispose();
  }

  QueryBuilder<ApplicationEvent, ApplicationEvent, QAfterFilterCondition>
      _buildQuery(Isar isar) {
    var where = isar.applicationEvents.where(sort: Sort.desc);

    // apply date filter
    var dateFilter =
        filterCategories.getFilterOfCategory<DateRangeFilter>('Date');
    var filter = switch ((dateFilter.min, dateFilter.max)) {
      (null, null) => where.anyDateTime().filter(),
      (null, _) =>
        where.dateTimeLessThan(dateFilter.max!, include: true).filter(),
      (_, null) =>
        where.dateTimeGreaterThan(dateFilter.min!, include: true).filter(),
      (_, _) =>
        where.dateTimeBetween(dateFilter.min!, dateFilter.max!).filter(),
    };

    // apply event type filter
    var eventFilter = filterCategories
        .getFilterOfCategory<ElementsFilter<EventType>>('Event Types');
    var filterBuilder = filter.optional(
      eventFilter.active,
      (query) => query.anyOf(
        eventFilter.activeElements,
        (q, eventType) => q.typeEqualTo(eventType),
      ),
    );

    return filterBuilder;
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final isar = service.isar;

    var query = _buildQuery(isar);

    var totalCount = await query.count();
    var events = await query.offset(startIndex).limit(count).findAll();

    return AsyncRowsResponse(
      totalCount,
      await Future.wait(events.map(
        (event) async {
          var cachedDoorData = await SmartDoorService.getCacheData(event.uuid);
          int? equipmentNumber = cachedDoorData?['equipment-number'];
          String? individualName = cachedDoorData?['individual-name'];
          Widget doorWidget = switch ((equipmentNumber, individualName)) {
            (null, null) => Text(event.uuid),
            (null, _) => Text(individualName!),
            (_, null) => Text(equipmentNumber!.toString()),
            (_, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(individualName!),
                  Opacity(
                      opacity: 0.6, child: Text(equipmentNumber!.toString())),
                ],
              ),
          };

          var message = await event.getMessage();
          var icon = switch (event.severity) {
            Severity.error => Icon(Icons.error, color: colorScheme.error),
            Severity.warning =>
              Icon(Icons.warning_amber_rounded, color: colorScheme.secondary),
            Severity.info =>
              Icon(Icons.info_outline, color: colorScheme.secondaryContainer),
          };
          return DataRow(
            cells: [
              DataCell(icon),
              DataCell(Text(event.dateTime.localized)),
              DataCell(doorWidget),
              DataCell(Text(event.type.toString())),
              DataCell(Text(message)),
            ],
          );
        },
      ).toList()),
    );
  }
}
