import 'package:efa_smartconnect_modbus_demo/modules/event_overview/controllers/event_overview_controller.dart';
import 'package:efa_smartconnect_modbus_demo/modules/event_overview/models/application_event_data_source.dart';
import 'package:efa_smartconnect_modbus_demo/shared/widgets/filters.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventOverviewPage extends GetView<EventOverviewController> {
  const EventOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataSource =
        ApplicationEventDataSource(colorScheme: Theme.of(context).colorScheme);

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FilterContainer(
            filterCategories: dataSource.filterCategories,
            onFilterChanged: () => dataSource.refreshDatasource(),
            child: Row(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  child: Obx(
                    () => SizedBox(
                      width:
                          controller.filterSettingsVisible.value ? 310 : null,
                      child: controller.filterSettingsVisible.value
                          ? Column(
                              children: [
                                const SizedBox(height: 67),
                                Expanded(
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            'Filter Settings',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                        ),
                                        const Divider(
                                          thickness: 1,
                                          height: 1,
                                        ),
                                        const Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: FilterSettingsView(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: AsyncPaginatedDataTable2(
                    header: Row(
                      children: [
                        FilterButton(
                          onPressed: (value) =>
                              controller.filterSettingsVisible.value = value,
                        ),
                        const ActiveFiltersView(),
                      ],
                    ),
                    // EventFilterView(
                    //   filterCategories: controller.filtersCategories,
                    // ),
                    showFirstLastButtons: true,
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
                    source: dataSource,
                    autoRowsToHeight: true,
                    renderEmptyRowsInTheEnd: false,
                    loading: Container(
                      color: Theme.of(context)
                          .colorScheme
                          .background
                          .withOpacity(0.7),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
