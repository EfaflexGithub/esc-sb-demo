import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserApplicationData {
  final String value;
  final String label;
  final String description;
  final IconData? icon;
  final IconData? selectedIcon;
  bool get selectable => selectedIcon != null;
  bool get enabled => icon != null;
  bool get unknown => value == '-1';

  const UserApplicationData({
    required this.value,
    required this.label,
    required this.description,
    required IconData icon,
  })  : icon = icon,
        selectedIcon = null;

  const UserApplicationData.selectable({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    IconData? selectedIcon,
    bool selected = false,
  }) : selectedIcon = selectedIcon ?? icon;

  const UserApplicationData.disabled({
    required this.value,
    required this.label,
    required this.description,
  })  : icon = null,
        selectedIcon = null;
}

class UserApplication extends UserApplicationData {
  Rxn<bool> selected;

  UserApplication({
    required super.value,
    required super.label,
    required super.description,
    required super.icon,
  }) : selected = Rxn<bool>();

  UserApplication.selectable({
    required String value,
    required String label,
    required String description,
    required IconData icon,
    IconData? selectedIcon,
    bool selected = false,
  })  : selected = Rxn<bool>(selected),
        super.selectable(
            value: value,
            label: label,
            description: description,
            icon: icon,
            selectedIcon: selectedIcon);

  UserApplication.disabled({
    required String value,
    required String label,
    required String description,
  })  : selected = Rxn<bool>(false),
        super.disabled(value: value, label: label, description: description);

  factory UserApplication.fromData(UserApplicationData userApplication) {
    if (!userApplication.enabled) {
      return UserApplication.disabled(
        value: userApplication.value,
        label: userApplication.label,
        description: userApplication.description,
      );
    }
    if (userApplication.selectable) {
      return UserApplication.selectable(
        value: userApplication.value,
        label: userApplication.label,
        description: userApplication.description,
        icon: userApplication.icon!,
        selectedIcon: userApplication.selectedIcon,
      );
    } else {
      return UserApplication(
        value: userApplication.value,
        label: userApplication.label,
        description: userApplication.description,
        icon: userApplication.icon!,
      );
    }
  }
}
