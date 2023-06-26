import 'package:get/get.dart';

extension RxBoolExtensions on RxBool {
  void toggle() {
    value = !value;
  }
}
