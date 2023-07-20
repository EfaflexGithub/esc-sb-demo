import 'package:efa_smartconnect_modbus_demo/modules/settings/models/setting_types.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/models/application_setttings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController<K> extends GetxController {
  SettingsController(this.applicationSettings);

  @override
  void onInit() async {
    super.onInit();
    await initializeSettings(applicationSettings.categories);
  }

  final selectedCategoryIndex = RxnInt();

  final changes = false.obs;

  SettingsCategory<K>? get selectedCategory {
    int? index = selectedCategoryIndex.value;
    return index != null ? applicationSettings.categories[index] : null;
  }

  ApplicationSettings<K> applicationSettings;

  void handleDrawerDestinationSelected(int index) {
    selectedCategoryIndex.value = index;
  }

  Future<void> initializeSettings(List<SettingsCategory> categories) async {
    for (var category in categories) {
      for (var group in category.groups) {
        for (var setting in group.settings) {
          await setting.init();
        }
      }
    }
    handleDrawerDestinationSelected(0);
  }

  Future<void> saveSettings() async {
    for (var category in applicationSettings.categories) {
      for (var group in category.groups) {
        for (var setting in group.settings) {
          await setting.apply();
        }
      }
    }
    reevaluateChanges();
  }

  void discardSettings() {
    for (var category in applicationSettings.categories) {
      for (var group in category.groups) {
        for (var setting in group.settings) {
          setting.discard();
        }
      }
    }
  }

  void reevaluateChanges() {
    for (var category in applicationSettings.categories) {
      for (var group in category.groups) {
        for (var setting in group.settings) {
          if (setting.value != setting.temporaryValue) {
            changes.value = true;
            return;
          }
        }
      }
    }
    changes.value = false;
  }

  Setting<K, dynamic>? getSettingFromKey(K key) {
    for (var category in applicationSettings.categories) {
      for (var group in category.groups) {
        for (var setting in group.settings) {
          if (setting.storageKey == key) {
            return setting;
          }
        }
      }
    }
    return null;
  }

  Future<T?> getValueFromKey<T>(K key) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    var value = sharedPreferences.get(key.toString());
    if (value == null) {
      var setting = getSettingFromKey(key);
      if (setting == null) {
        return null;
      }
      return setting.defaultValue as T;
    } else if (value is T) {
      return value as T;
    }
    return null;
  }
}
