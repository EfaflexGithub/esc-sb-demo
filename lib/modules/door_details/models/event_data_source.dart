import 'package:efa_smartconnect_modbus_demo/data/models/event_entry.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:efa_smartconnect_modbus_demo/shared/extensions/numeric_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDataSource extends DataTableSource {
  final List<EventEntry> eventEntries;

  EventDataSource({required this.eventEntries});

  @override
  DataRow? getRow(int index) {
    if (index >= eventEntries.length) {
      return null;
    }
    final event = eventEntries[index];
    return DataRow2(cells: [
      DataCell(Text(DateFormat.yMMMd('en_US').format(event.dateTime))),
      DataCell(Text(DateFormat.Hms('en_US').format(event.dateTime))),
      DataCell(Text(event.cycleCounter?.localized ?? '?')),
      DataCell(Text(event.code.toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => eventEntries.length;

  @override
  int get selectedRowCount => 0;
}
