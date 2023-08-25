import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class Filter<T> {
  Filter({this.category});

  FilterCategory? category;

  String get activeFilterText;

  bool get active;

  void reset();
  bool matches(T element);

  Iterable<T> filter(Iterable<T> elements) {
    return elements.where(matches);
  }
}

class ElementsFilter<T> extends Filter<T> {
  ElementsFilter({
    required Iterable<T> keys,
    bool initialValue = true,
  }) : elements =
            Map.fromEntries(keys.map((key) => MapEntry(key, initialValue)));

  final Map<T, bool> elements;

  Iterable<T> get activeElements =>
      elements.entries.where((element) => element.value).map((e) => e.key);

  @override
  String get activeFilterText =>
      '${category?.name}: ${activeElements.map((e) => e.toString()).join(', ')}';

  @override
  bool get active => elements.values.any((value) => value == false);

  @override
  void reset() {
    for (var key in elements.keys) {
      elements[key] = true;
    }
  }

  @override
  bool matches(T element) {
    if (elements.containsKey(element)) {
      return elements[element]!;
    }
    return false;
  }
}

class TextFilter extends Filter<String> {
  TextFilter({
    super.category,
    this.searchText,
  });

  String? searchText;

  @override
  bool get active => searchText?.isNotEmpty ?? false;

  @override
  String get activeFilterText => '${category?.name} contains $searchText';

  @override
  void reset() => searchText = '';

  @override
  bool matches(String element) {
    return searchText != null
        ? element.toLowerCase().contains(searchText!.toLowerCase())
        : true;
  }
}

abstract class RangeFilter<T extends Comparable<T>> extends Filter<T> {
  RangeFilter({
    this.min,
    this.max,
  });

  T? min;
  T? max;

  String format(T value) {
    return value.toString();
  }

  String get fromPhrase => 'greater than';
  String get toPhrase => 'less than';
  String get rangePhrase => 'to';

  @override
  String get activeFilterText => switch ((min, max)) {
        (null, null) => 'none',
        (null, _) => '${category?.name} $toPhrase ${format(max!)}',
        (_, null) => '${category?.name} $fromPhrase ${format(min!)}',
        (_, _) =>
          '${category?.name} ${format(min!)} $rangePhrase ${format(max!)}',
      };

  @override
  bool get active => min != null || max != null;

  @override
  void reset() {
    min = null;
    max = null;
  }

  @override
  bool matches(T element) {
    if (min != null && element.compareTo(min!) < 0) {
      return false;
    }
    if (max != null && element.compareTo(max!) > 0) {
      return false;
    }
    return true;
  }
}

class DateRangeFilter extends RangeFilter<DateTime> {
  DateRangeFilter({
    super.min,
    super.max,
  });

  @override
  String format(DateTime? value) {
    return value != null ? DateFormat('yyyy-MM-dd').format(value) : 'none';
  }

  @override
  String get activeFilterText => switch ((min, max)) {
        (null, null) => 'none',
        (null, _) => '${category?.name} before ${format(max!)}',
        (_, null) => '${category?.name} after ${format(min!)}',
        (_, _) => '${category?.name} from ${format(min!)} to ${format(max!)}',
      };
}

class FilterCategory {
  FilterCategory({
    required this.name,
    required this.filters,
  }) {
    for (var element in filters) {
      element.category = this;
    }
  }

  final String name;
  final List<Filter> filters;
}

class FilterCategories with ChangeNotifier {
  FilterCategories({
    required this.categories,
  });

  final List<FilterCategory> categories;

  List<Filter> get activeFilters {
    return categories
        .map((filterCategory) => filterCategory.filters)
        .expand((element) => element)
        .where((element) => element.active)
        .toList();
  }

  T getFilterOfCategory<T extends Filter>(String name) {
    for (var filterCategory in categories) {
      for (var filter in filterCategory.filters) {
        if (filter is T && filterCategory.name == name) {
          return filter;
        }
      }
    }
    throw Exception('Filter $name of type $T not found');
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class _FilterService {
  _FilterService({
    this.filterSettingsVisible = false,
  });

  bool filterSettingsVisible;
}

class FilterContainer extends InheritedWidget {
  FilterContainer({
    super.key,
    required this.filterCategories,
    VoidCallback? onFilterChanged,
    required super.child,
  }) : _filterService = _FilterService() {
    filterCategories.addListener(() => onFilterChanged?.call());
  }

  final _FilterService _filterService;
  final FilterCategories filterCategories;

  static FilterContainer of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FilterContainer>()!;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class FilterButton extends StatefulWidget {
  const FilterButton({
    super.key,
    this.onPressed,
  });

  final ValueChanged<bool>? onPressed;

  @override
  State<StatefulWidget> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  @override
  Widget build(BuildContext context) {
    final filterService = FilterContainer.of(context)._filterService;
    return IconButton(
      icon: Icon(
        filterService.filterSettingsVisible
            ? Icons.filter_list_off_outlined
            : Icons.filter_list_outlined,
      ),
      onPressed: () => setState(
        () {
          var newValue = !filterService.filterSettingsVisible;

          filterService.filterSettingsVisible = newValue;
          widget.onPressed?.call(newValue);
        },
      ),
    );
  }
}

class FilterSettingsView extends StatefulWidget {
  const FilterSettingsView({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _FilterSettingsViewState();
}

class _FilterSettingsViewState extends State<FilterSettingsView> {
  @override
  Widget build(BuildContext context) {
    final filterCategories = FilterContainer.of(context).filterCategories;
    return Column(
      children: [
        Expanded(
          child: ListenableBuilder(
            listenable: filterCategories,
            builder: (context, child) => ListView(
              children: [
                for (var filterCategory in filterCategories.categories)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(filterCategory.name,
                          style: Theme.of(context).textTheme.titleSmall),
                      const Divider(thickness: 0.5),
                      for (var filter in filterCategory.filters)
                        if (filter is ElementsFilter)
                          ..._buildElementsFilter(filter)
                        else if (filter is TextFilter)
                          ..._buildTextFilter(filter)
                        else if (filter is DateRangeFilter)
                          ..._buildDateFilter(filter),
                      const SizedBox(height: 20),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () => filterCategories.notifyListeners(),
            child: const Text('APPLY'),
          ),
        )
      ],
    );
  }

  Iterable<Widget> _buildElementsFilter(ElementsFilter filter) {
    return filter.elements.keys.map(
      (key) {
        return CheckboxListTile(
          value: filter.elements[key],
          onChanged: (value) => setState(() {
            filter.elements[key] = value ?? true;
          }),
          title: Text(key.toString()),
        );
      },
    );
  }

  Iterable<Widget> _buildTextFilter(TextFilter filter) {
    var controller = TextEditingController(text: filter.searchText);
    return [
      TextField(
        controller: controller,
        style: Theme.of(context).inputDecorationTheme.labelStyle,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: 'Contains Text',
          suffixIcon: IconButton(
            onPressed: controller.clear,
            icon: const Icon(Icons.clear),
          ),
        ),
        onChanged: (value) => filter.searchText = value,
      ),
    ];
  }

  Iterable<Widget> _buildDateFilter(DateRangeFilter filter) {
    Widget buildDateTextField({
      DateTime? value,
      DateTime? firstDate,
      DateTime? lastDate,
      ValueChanged<DateTime?>? onPicked,
    }) {
      var controller = TextEditingController(
        text: value != null ? filter.format(value) : null,
      );
      return SizedBox(
        width: 125,
        child: TextField(
          controller: controller,
          style: Theme.of(context).inputDecorationTheme.labelStyle,
          decoration: InputDecoration(
            hintText: 'any',
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIconConstraints: const BoxConstraints(
              minHeight: 15,
              minWidth: 15,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                iconSize: 14,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.text = '';
                  onPicked?.call(null);
                },
              ),
            ),
          ),
          textAlign: TextAlign.center,
          canRequestFocus: false,
          onTap: () async {
            var pickedDate = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime.now(),
            );
            if (pickedDate != null) {
              controller.text = filter.format(pickedDate);
              onPicked?.call(pickedDate);
            }
          },
        ),
      );
    }

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildDateTextField(
            value: filter.min,
            onPicked: (value) => filter.min = value,
          ),
          const Text('to'),
          buildDateTextField(
            value: filter.max,
            onPicked: (value) =>
                filter.max = value?.copyWith(hour: 23, minute: 59, second: 59),
          )
        ],
      )
    ];
  }
}

class ActiveFiltersView extends StatelessWidget {
  const ActiveFiltersView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final filterCategories = FilterContainer.of(context).filterCategories;

    var test = FilterCategories(categories: []);
    test.notifyListeners();

    return Wrap(
      children: filterCategories.activeFilters
          .map(
            (e) => InputChip(
              label: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Tooltip(
                  message: e.activeFilterText,
                  child: Text(e.activeFilterText),
                ),
              ),
              onDeleted: () {
                e.reset();
                filterCategories.notifyListeners();
              },
            ),
          )
          .toList(),
    );
  }
}
