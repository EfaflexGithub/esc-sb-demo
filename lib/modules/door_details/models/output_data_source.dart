import 'package:efa_smartconnect_modbus_demo/data/models/control_output.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OutputDataSource extends DataTableSource {
  final List<ControlOutput> outputs;

  OutputDataSource({required this.outputs});

  @override
  DataRow? getRow(int index) {
    if (index >= outputs.length) {
      return null;
    }
    final output = outputs[index];
    return DataRow2(cells: [
      DataCell(Text(output.toString())),
      DataCell(Text(switch ((output.virtual, output.label)) {
        (true, _) => 'virtual',
        (_, null) => '${output.connector}',
        _ => '${output.connector} (${output.label})',
      })),
      DataCell(Obx(() => switch (output.enabled.value) {
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
      DataCell(output.onChangeRequested != null
          ? Obx(() => Switch(
                value: output.enabled.value ?? false,
                onChanged: (value) =>
                    output.onChangeRequested?.call(output, value),
              ))
          : const SizedBox()),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => outputs.length;

  @override
  int get selectedRowCount => 0;
}
