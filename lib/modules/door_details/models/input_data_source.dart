import 'package:efa_smartconnect_modbus_demo/data/models/control_input.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputDataSource extends DataTableSource {
  final List<ControlInput> inputs;

  InputDataSource({required this.inputs});

  @override
  DataRow? getRow(int index) {
    if (index >= inputs.length) {
      return null;
    }
    final input = inputs[index];
    return DataRow2(cells: [
      DataCell(Text(input.toString())),
      DataCell(Text(switch ((input.virtual, input.label)) {
        (true, _) => 'virtual',
        (_, null) => '${input.connector}',
        _ => '${input.connector} (${input.label})',
      })),
      DataCell(Obx(() => switch (input.enabled.value) {
            null => const Text('?'),
            true => Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            _ => Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
          })),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => inputs.length;

  @override
  int get selectedRowCount => 0;
}
