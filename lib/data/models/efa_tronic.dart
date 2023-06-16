import 'package:efa_smartconnect_modbus_demo/data/models/extension_board.dart';
import 'package:get/get.dart';

import './door_control.dart';

base class EfaTronic extends DoorControl {
  /// List of extension boards
  RxList<ExtensionBoard> extensionBoards = RxList<ExtensionBoard>();

  /// Get the extension board by type
  /// @param type Type of extension board
  /// @return Extension board
  T? findExtensionBoardByType<T extends ExtensionBoard>() {
    return extensionBoards
        .firstWhereOrNull((element) => element.runtimeType == T) as T?;
  }
}
