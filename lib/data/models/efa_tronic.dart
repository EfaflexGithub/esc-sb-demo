import 'dart:async';

import 'package:efa_smartconnect_modbus_demo/data/models/control_input.dart';
import 'package:efa_smartconnect_modbus_demo/data/models/control_output.dart';
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

  final _controlOutputChangeRequestController =
      StreamController<(ControlOutput, bool)>();

  @override
  Stream<(ControlOutput, bool)> get onControlOutputChangeRequest =>
      _controlOutputChangeRequestController.stream;

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

  void _outputChangeRequested(ControlOutput output, bool value) {
    _controlOutputChangeRequestController.add((output, value));
  }

  @override
  List<ControlInput> get controlInputs => _controlInputs;

  final List<ControlInput> _controlInputs = [
    ControlInput(
      description: "Input 1",
      connector: "-X23:52",
      label: "E1",
    ),
    ControlInput(
      description: "Input 2",
      connector: "-X23:53",
      label: "E2",
    ),
    ControlInput(
      description: "Input 3",
      connector: "-X23:54",
      label: "E3",
    ),
    ControlInput(
      description: "Input 4",
      connector: "-X25:72",
      label: "E4",
    ),
    ControlInput(
      description: "Input 5",
      connector: "-X25:75",
      label: "E5",
    ),
    ControlInput(
      description: "Input 6",
      connector: "-X26:82",
      label: "E6",
    ),
    ControlInput(
      description: "Input 7",
      connector: "-X26:85",
      label: "E7",
    ),
    ControlInput(
      description: "Input 8",
      connector: "-X24:61",
      label: "S1",
    ),
    ControlInput(
      description: "Input 9",
      connector: "-X24:64",
      label: "S2",
    ),
    ControlInput(
      description: "Input 10",
      connector: "-X24:65",
      label: "SE",
    ),
    ControlInput(
      description: "Input 11",
      connector: "-X27:92",
      label: "SA",
    ),
    ControlInput(
      description: "Input 12",
      connector: "-X27:93",
      label: "SB",
    ),
    ControlInput(
      description: "Input 21",
      connector: "-X33:331",
      label: "E21",
    ),
    ControlInput(
      description: "Input 22",
      connector: "-X33:334",
      label: "E22",
    ),
    ControlInput(
      description: "Input 23",
      connector: "-X34:341",
      label: "E23",
    ),
    ControlInput(
      description: "Input 24",
      connector: "-X36:361",
      label: "E24",
    ),
    ControlInput(
      description: "Input 25",
      connector: "-X36:362",
      label: "E25",
    ),
    ControlInput(
      description: "Input 26",
      connector: "-X36:363",
      label: "E26",
    ),
    ControlInput(
      description: "Radio 1",
      connector: "M2a:5",
    ),
    ControlInput(
      description: "Radio 2",
      connector: "M2a:4",
    ),
    ControlInput(
      description: "Detector 1",
      connector: "-L1",
    ),
    ControlInput(
      description: "Detector 2",
      connector: "-L2",
    ),
    ControlInput(
      description: "Detector 3",
      connector: "-X35:350-351",
      label: "I3a/b",
    ),
    ControlInput(
      description: "Detector 4",
      connector: "-X35:352-353",
      label: "I4a/b",
    ),
    ControlInput(
      description: "Safety Strip SE",
      connector: "-X24:65",
      label: "SE",
    ),
    ControlInput(
      description: "Safety Strip SE2",
      connector: "-X22:43",
      label: "SE2",
    ),
    ControlInput(
      description: "E-Stop Int",
      connector: "-X21:1-2",
      label: "NA1/2",
    ),
    ControlInput(
      description: "E-Stop Ext 1",
      connector: "-X22:41-42",
      label: "NA3/4",
    ),
    ControlInput(
      description: "E-Stop Ext 2",
      connector: "-X20:31-32",
      label: "NA5/6",
    ),
    ControlInput(
      description: "Open-Keypad",
      connector: "-X400:3",
    ),
    ControlInput(
      description: "Stop-Keypad",
      connector: "-X400:2",
    ),
    ControlInput(
      description: "Close-Keypad",
      connector: "-X400:1",
    ),
    ControlInput(
      description: "Input 13",
      virtual: true,
    ),
    ControlInput(
      description: "Input 14",
      virtual: true,
    ),
    ControlInput(
      description: "Input 15",
      virtual: true,
    ),
    ControlInput(
      description: "Input 27",
      virtual: true,
    ),
    ControlInput(
      description: "Input 28",
      virtual: true,
    ),
    ControlInput(
      description: "Input 31",
      virtual: true,
    ),
    ControlInput(
      description: "Input 3A",
      virtual: true,
    ),
    ControlInput(
      description: "Input 3B",
      virtual: true,
    ),
    ControlInput(
      description: "Input 3C",
      virtual: true,
    ),
    ControlInput(
      description: "Input 3D",
      virtual: true,
    ),
    ControlInput(
      description: "Input 3E",
      virtual: true,
    ),
    ControlInput(
      description: "Input 3F",
      virtual: true,
    ),
    ControlInput(
      description: "Input 41",
      virtual: true,
    ),
    ControlInput(
      description: "Input 42",
      virtual: true,
    ),
    ControlInput(
      description: "Input 43",
      virtual: true,
    ),
    ControlInput(
      description: "Input 44",
      virtual: true,
    ),
    ControlInput(
      description: "Input 45",
      virtual: true,
    ),
    ControlInput(
      description: "Input 46",
      virtual: true,
    ),
    ControlInput(
      description: "Input 47",
      virtual: true,
    ),
    ControlInput(
      description: "Input 48",
      virtual: true,
    ),
    ControlInput(
      description: "Input 49",
      virtual: true,
    ),
    ControlInput(
      description: "Input 4A",
      virtual: true,
    ),
    ControlInput(
      description: "Input 4B",
      virtual: true,
    ),
    ControlInput(
      description: "Input 4C",
      virtual: true,
    ),
    ControlInput(
      description: "Input 4D",
      virtual: true,
    ),
    ControlInput(
      description: "Input 4E",
      virtual: true,
    ),
    ControlInput(
      description: "Input 4F",
      virtual: true,
    ),
    ControlInput(
      description: "Input 51",
      virtual: true,
    ),
    ControlInput(
      description: "Input 52",
      virtual: true,
    ),
    ControlInput(
      description: "Input 53",
      virtual: true,
    ),
    ControlInput(
      description: "Input 54",
      virtual: true,
    ),
    ControlInput(
      description: "Input 55",
      virtual: true,
    ),
    ControlInput(
      description: "Input 56",
      virtual: true,
    ),
    ControlInput(
      description: "Input 57",
      virtual: true,
    ),
    ControlInput(
      description: "Input 58",
      virtual: true,
    ),
    ControlInput(
      description: "Input 59",
      virtual: true,
    ),
    ControlInput(
      description: "Input 5A",
      virtual: true,
    ),
    ControlInput(
      description: "Input 5B",
      virtual: true,
    ),
    ControlInput(
      description: "Input 5C",
      virtual: true,
    ),
    ControlInput(
      description: "Input 5D",
      virtual: true,
    ),
    ControlInput(
      description: "Input 5E",
      virtual: true,
    ),
    ControlInput(
      description: "Input 5F",
      virtual: true,
    ),
  ];

  @override
  List<ControlOutput> get controlOutputs => _controlOutputs;

  late final List<ControlOutput> _controlOutputs = [
    ControlOutput(
      description: "Relay 1",
      connector: "-X14:10-12",
      label: "K1",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Relay 2",
      connector: "-X15:20-22",
      label: "K2",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Relay 3",
      connector: "-X16:30-32",
      label: "K3",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "TST SRA-A",
      connector: "-X16:68",
      label: "M2a",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Relay 5",
      connector: "-X31:316",
      label: "K5",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Relay 6",
      connector: "-X31:317",
      label: "K6",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Relay 7",
      connector: "-X31:318",
      label: "K7",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Relay 8",
      connector: "-X31.319",
      label: "K8",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Relay 9",
      connector: "-X32:320-322",
      label: "K9",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Relay 10",
      connector: "-X32:323-325",
      label: "K10",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Output 28",
      connector: "-X18:35",
      label: "O28",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Output 29",
      connector: "-X18:37",
      label: "O29",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Test Output 1",
      connector: "-X24:66",
      label: "T1",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Test Output 2",
      connector: "-X25:76",
      label: "T2",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Test Output 3",
      connector: "-X26:86",
      label: "T3",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Test Output 4",
      connector: "-X33:333",
      label: "T4",
      onChangeRequested: _outputChangeRequested,
    ),
    ControlOutput(
      description: "Break (24 V)",
      connector: "-X17:34",
      label: "B+",
    ),
    ControlOutput(
      description: "LED Open",
      connector: "-X400:5",
    ),
    ControlOutput(
      description: "LED Stop",
      connector: "-X400:6",
    ),
    ControlOutput(
      description: "LED Close",
      connector: "-X400:7",
    ),
    ControlOutput(
      description: "Output 21",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 22",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 23",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 24",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 27",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 2B",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 2C",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 2D",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 2E",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 2F",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 31",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 32",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 33",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 34",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 35",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 36",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 37",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 38",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 41",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 42",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 43",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 44",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 45",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 46",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 47",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 48",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 49",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 4A",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 4B",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 4C",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 4D",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 4E",
      virtual: true,
    ),
    ControlOutput(
      description: "Output 4F",
      virtual: true,
    ),
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
