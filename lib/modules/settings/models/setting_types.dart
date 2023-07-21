import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationSettings<K> {
  ApplicationSettings({
    required this.categories,
  });
  final List<SettingsCategory<K>> categories;
}

class SettingsCategory<K> {
  const SettingsCategory({
    required this.label,
    required this.icon,
    this.selectedIcon,
    required this.groups,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  final List<SettingsGroup<K>> groups;
}

class SettingsGroup<K> {
  const SettingsGroup({
    required this.label,
    required this.settings,
  });
  final String label;
  final List<Setting<K, dynamic>> settings;
}

class Setting<K, T> {
  Setting({
    required this.storageKey,
    required this.title,
    this.description = "",
    required this.defaultValue,
  })  : valueObs = Rx<T>(defaultValue),
        temporaryValueObs = Rx<T>(defaultValue);

  Rx<T> valueObs;
  Rx<T> temporaryValueObs;

  T get value => valueObs.value;
  set value(T value) => valueObs.value = value;

  T get temporaryValue => temporaryValueObs.value;
  set temporaryValue(T value) => temporaryValueObs.value = value;
  final T defaultValue;

  Type get genericType => value.runtimeType;

  final K storageKey;
  final String title;
  final String description;

  Future<void> init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    value =
        (sharedPreferences.get(storageKey.toString()) as T?) ?? defaultValue;
    temporaryValue = value;
  }

  Future<bool> apply() async {
    if (temporaryValue != value) {
      value = temporaryValue;
      return await _saveValueToSharedPreferences(value);
    }
    return false;
  }

  void discard() {
    temporaryValue = value;
  }

  Future<bool> _saveValueToSharedPreferences(T value) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return await switch (value.runtimeType) {
      bool => sharedPreferences.setBool(storageKey.toString(), value as bool),
      int => sharedPreferences.setInt(storageKey.toString(), value as int),
      double =>
        sharedPreferences.setDouble(storageKey.toString(), value as double),
      String =>
        sharedPreferences.setString(storageKey.toString(), value as String),
      _ => throw UnsupportedError("Type ${value.runtimeType} not supported"),
    };
  }
}
