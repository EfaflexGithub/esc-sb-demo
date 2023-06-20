import 'package:efa_smartconnect_modbus_demo/data/models/extension_board.dart';
import 'package:get/get.dart';

import './door_control.dart';

base class EfaTronic extends DoorControl {
  /// List of extension boards
  RxList<ExtensionBoard> extensionBoards = RxList<ExtensionBoard>();

  var dateTime = Rxn<DateTime>();

  var daylightSavingTime = Rxn<DaylightSavingTime>();

  var keepOpenTimeAutomatic = Rxn<int?>();

  var keepOpenTimeIntermediateStop = Rxn<int?>();

  var closedPositionAdjustment = Rxn<int?>();

  var openPositionAdjustment = Rxn<int?>();

  /// Get the extension board by type
  /// @param type Type of extension board
  /// @return Extension board
  T? findExtensionBoardByType<T extends ExtensionBoard>() {
    return extensionBoards
        .firstWhereOrNull((element) => element.runtimeType == T) as T?;
  }

  EfaTronic() {
    var string = String.fromCharCodes(List.filled(33, ' '.codeUnitAt(0)));
    displayContent.value = string.replaceRange(16, 17, '\n');
  }

  set displayContentLine1(String value) {
    displayContent.value = displayContent.value?.replaceRange(0, 16, value);
  }

  set displayContentLine2(String value) {
    displayContent.value = displayContent.value?.replaceRange(17, 33, value);
  }
}

enum DaylightSavingTime {
  Disabled,
  EU,
  UK,
  US;
}
