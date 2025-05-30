import 'package:efa_smartconnect_modbus_demo/shared/utils/callbacks.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum UserApplicationType {
  disabled,
  momentary,
  toggle,
}

class UserApplicationDefinition {
  final String value;
  final String label;
  final String description;
  final IconData? icon;
  final IconData? selectedIcon;
  final int momentaryDelay;

  UserApplicationType get _userApplicationType =>
      switch ((icon, selectedIcon)) {
        (null, null) => UserApplicationType.disabled,
        (_, null) => UserApplicationType.momentary,
        _ => UserApplicationType.toggle,
      };

  const UserApplicationDefinition.disabled({
    required this.value,
    required this.label,
    required this.description,
  })  : icon = null,
        selectedIcon = null,
        momentaryDelay = 0;

  const UserApplicationDefinition.momentary({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    this.momentaryDelay = 250,
  }) : selectedIcon = null;

  const UserApplicationDefinition.toggle({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    IconData? selectedIcon,
  })  : selectedIcon = selectedIcon ?? icon,
        momentaryDelay = 0;
}

class UserApplication {
  final AsyncValueChanged<bool> onStateChanged;
  UserApplicationType? get type => definition?._userApplicationType;

  final Rxn<UserApplicationDefinition> _definition;
  UserApplicationDefinition? get definition => _definition.value;
  set definition(UserApplicationDefinition? newDefinition) {
    _definition.value = newDefinition;
    if (type == UserApplicationType.momentary && state == true) {
      onStateChanged.call(false).then((_) => state = false);
    }
  }

  final Rxn<bool> _state;
  bool? get state => _state.value;
  set state(bool? newState) {
    var oldState = _state.value;
    _state.value = newState;
    if (oldState == null &&
        _state.value == true &&
        type == UserApplicationType.momentary) {
      onStateChanged.call(false).then((_) => _state.value = false);
    }
  }

  Future<void> activate() async {
    // create variables that hold non-modifiable references
    var state2 = state;
    var type2 = type;
    var definition2 = definition;

    // return if either state or the definition is uninitialized
    if (definition2 == null || type2 == null || state2 == null) {
      return;
    }

    if (type == UserApplicationType.toggle) {
      await onStateChanged.call(!state2);
      state = !state2;
    }
    if (type == UserApplicationType.momentary) {
      await onStateChanged.call(true);
      state = true;
      await Future.delayed(Duration(milliseconds: definition2.momentaryDelay));
      await onStateChanged.call(false);
      state = false;
    }
  }

  UserApplication({
    required UserApplicationDefinition? definition,
    bool? state,
    required this.onStateChanged,
  })  : _definition = Rxn<UserApplicationDefinition>(definition),
        _state = Rxn<bool>(state);
}
