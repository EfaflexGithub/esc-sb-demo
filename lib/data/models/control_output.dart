import 'package:efa_smartconnect_modbus_demo/data/models/control_input.dart';
import 'package:get/get.dart';

class ControlOutput extends ControlInput {
  final Function(ControlOutput sender, bool value)? onChangeRequested;

  RxBool showInOverview;

  ControlOutput({
    required super.description,
    super.virtual = false,
    super.connector,
    super.label,
    super.enabled,
    bool showInOverview = false,
    this.onChangeRequested,
  }) : showInOverview = RxBool(showInOverview);
}
