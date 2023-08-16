import 'package:efa_smartconnect_modbus_demo/data/models/extension_board.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/information_entry.dart';
import 'package:get/get.dart';

import './door_control.dart';

base class EfaTronic extends DoorControl {
  EfaTronic() {
    var string = String.fromCharCodes(List.filled(33, ' '.codeUnitAt(0)));
    displayContent.value = string.replaceRange(16, 17, '\n');
  }

  /// List of extension boards
  RxList<ExtensionBoard> extensionBoards = RxList<ExtensionBoard>();

  var dateTime = Rxn<DateTime>();

  var daylightSavingTime = Rxn<DaylightSavingTime>();

  var keepOpenTimeAutomatic = Rxn<int?>();

  var keepOpenTimeIntermediateStop = Rxn<int?>();

  var closedPositionAdjustment = Rxn<int?>();

  var openPositionAdjustment = Rxn<int?>();

  @override
  List<List<InformationEntry>> get controlInformation => [
        [
          DateInformationEntry(
            description: 'Controller Date and Time',
            value: dateTime.value,
            editable: true,
            onSaved: (value) async {
              dateTime.value = value;
            },
          ),
          EnumInformationEntry<DaylightSavingTime>(
            description: 'Daylight Saving Time',
            value: daylightSavingTime.value,
            values: DaylightSavingTime.values,
            editable: true,
            onSaved: (value) async {
              daylightSavingTime.value = value;
            },
          ),
        ],
        [
          IntInformationEntry(
            description: 'Keep Open Time Automatic',
            value: keepOpenTimeAutomatic.value,
            editable: true,
            onSaved: (value) async {
              keepOpenTimeAutomatic.value = value;
            },
            min: 0,
            max: 9999,
          ),
          IntInformationEntry(
            description: 'Keep Open Time Intermediate Stop',
            value: keepOpenTimeIntermediateStop.value,
            editable: true,
            onSaved: (value) async {
              keepOpenTimeIntermediateStop.value = value;
            },
            min: 0,
            max: 9999,
          ),
        ],
        [
          IntInformationEntry(
            description: 'Open Position Adjustment',
            value: openPositionAdjustment.value,
            editable: true,
            onSaved: (value) async {
              openPositionAdjustment.value = value;
            },
            min: -60,
            max: 60,
          ),
          IntInformationEntry(
            description: 'Closed Position Adjustment',
            value: closedPositionAdjustment.value,
            editable: true,
            onSaved: (value) async {
              closedPositionAdjustment.value = value;
            },
            min: -120,
            max: 120,
          ),
        ],
      ];

  /// Get the extension board by type
  /// @param type Type of extension board
  /// @return Extension board
  T? findExtensionBoardByType<T extends ExtensionBoard>() {
    return extensionBoards
        .firstWhereOrNull((element) => element.runtimeType == T) as T?;
  }

  set displayContentLine1(String value) {
    displayContent.value = displayContent.value?.replaceRange(0, 16, value);
  }

  set displayContentLine2(String value) {
    displayContent.value = displayContent.value?.replaceRange(17, 33, value);
  }
}

enum DaylightSavingTime {
  disabled,
  eu,
  uk,
  us;

  @override
  String toString() {
    return switch (this) {
      disabled => 'Disabled',
      eu => 'EU',
      uk => 'UK',
      us => 'US',
    };
  }
}
