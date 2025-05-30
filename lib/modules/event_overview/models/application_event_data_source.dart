import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/application_event.dart';
import 'package:efa_smartconnect_modbus_demo/data/providers/isar_provider.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/application_event_service.dart';
import 'package:efa_smartconnect_modbus_demo/shared/widgets/filters.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/datetime_extensions.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/door_respository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        name: 'Severity',
        filters: [
          ElementsFilter<Severity>(
            keys: Severity.values,
          ),
        ],
      ),
      FilterCategory(
        name: 'Date',
        filters: [
          DateRangeFilter(),
        ],
      ),
      FilterCategory(
        name: 'Door',
        filters: [
          TextFilter(
            name: 'Name',
          ),
          TextFilter(
            name: 'Equipment',
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
      FilterCategory(
        name: 'Event Types',
        filters: [
          ElementsFilter<EventType>(keys: EventType.values),
        ],
      ),
      FilterCategory(
        name: 'Message',
        filters: [
          TextFilter(
            name: 'Error Code',
          ),
        ],
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

  Future<
      QueryBuilder<ApplicationEvent, ApplicationEvent,
          QAfterFilterCondition>?> _buildQuery(Isar isar) async {
    var where = isar.applicationEvents.where(sort: Sort.desc);

    // apply date where
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
    if (eventFilter.activeElements.isEmpty) {
      return null;
    }
    var filterBuilder = filter.optional(
      eventFilter.active,
      (query) => query.anyOf(
        eventFilter.activeElements,
        (q, eventType) => q.typeEqualTo(eventType),
      ),
    );

    // apply severity filter
    var severityFilter = filterCategories
        .getFilterOfCategory<ElementsFilter<Severity>>('Severity');
    if (severityFilter.activeElements.isEmpty) {
      return null;
    }
    filterBuilder = filterBuilder.optional(
      severityFilter.active,
      (query) => query.anyOf(
        severityFilter.activeElements,
        (q, severity) => q.severityEqualTo(severity),
      ),
    );

    // apply door filters
    var doorNameFilterText =
        filterCategories.getFilterByName<TextFilter>('Name').searchText;
    var equipmentFilterText =
        filterCategories.getFilterByName<TextFilter>('Equipment').searchText;

    if (doorNameFilterText != null && doorNameFilterText.isNotEmpty) {
      var doorIds =
          await DoorRepository().searchIdsByName(search: doorNameFilterText);
      if (doorIds.isEmpty) {
        return null;
      }
      filterBuilder =
          filterBuilder.anyOf(doorIds, (q, doorId) => q.doorIdEqualTo(doorId));
    }
    if (equipmentFilterText != null && equipmentFilterText.isNotEmpty) {
      var doorIds = await DoorRepository()
          .searchIdsByEquipmentNumber(search: equipmentFilterText);
      if (doorIds.isEmpty) {
        return null;
      }
      filterBuilder =
          filterBuilder.anyOf(doorIds, (q, doorId) => q.doorIdEqualTo(doorId));
    }

    // Apply Error Code Filter
    var errorCodeFilterText =
        filterCategories.getFilterByName<TextFilter>('Error Code').searchText;

    if (errorCodeFilterText != null && errorCodeFilterText.isNotEmpty) {
      filterBuilder = filterBuilder.dataElementContains(errorCodeFilterText);
    }

    return filterBuilder;
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final isar = await IsarProvider.application;

    var query = await _buildQuery(isar);

    if (query == null) {
      return AsyncRowsResponse(0, []);
    }

    var totalCount = await query.count();
    var events = await query.offset(startIndex).limit(count).findAll();

    return AsyncRowsResponse(
      totalCount,
      await Future.wait(events.map(
        (event) async {
          var cachedDoorData = await DoorRepository().getById(event.doorId);
          int? equipmentNumber = cachedDoorData?.equipmentNumber;
          String? individualName = cachedDoorData?.individualName;
          Widget doorWidget = switch ((equipmentNumber, individualName)) {
            (null, null) => Text(event.doorId.toString()),
            (null, _) => Text(
                individualName!,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            (_, null) => Text(equipmentNumber!.toString()),
            (_, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    individualName!,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
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
