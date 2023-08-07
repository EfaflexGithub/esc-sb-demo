import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:efa_smartconnect_modbus_demo/modules/event_overview/controllers/event_overview_controller.dart';

class EventOverviewPage extends GetView<EventOverviewController> {
  const EventOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: AsyncPaginatedDataTable2(
          header: const Text('Application Events'),
          actions: [
            IconButton(
                icon: Icon(Icons.delete_sweep,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () => controller.deleteAll()),
          ],
          columns: const [
            DataColumn2(
              label: Text(''),
              fixedWidth: 50,
            ),
            DataColumn2(
              label: Text('Date/Time'),
              fixedWidth: 200,
            ),
            DataColumn2(
              label: Text('Door'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('Type'),
              fixedWidth: 200,
            ),
            DataColumn2(
              label: Text('Message'),
              size: ColumnSize.L,
            ),
          ],
          empty: const Center(child: Text('No events available.')),
          source: controller.getDataSource(context),
          autoRowsToHeight: true,
          renderEmptyRowsInTheEnd: false,
          wrapInCard: false,
          loading: Container(
            color: Theme.of(context).colorScheme.background.withOpacity(0.7),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
