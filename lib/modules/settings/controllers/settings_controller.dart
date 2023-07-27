import 'package:efa_smartconnect_modbus_demo/modules/settings/models/setting_types.dart';
import 'package:get/get.dart';

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

  Setting<K, dynamic> getSettingFromKey(K key) {
    for (var category in applicationSettings.categories) {
      for (var group in category.groups) {
        for (var setting in group.settings) {
          if (setting.storageKey == key) {
            return setting;
          }
        }
      }
    }
    throw Exception('Setting not found');
  }

  T getValueFromKey<T>(K key) {
    for (var category in applicationSettings.categories) {
      for (var group in category.groups) {
        for (var setting in group.settings) {
          if (setting.storageKey == key) {
            return setting.value as T;
          }
        }
      }
    }
    throw Exception('Setting not found');
  }

  Rx<T> getObservableValueFromKey<T>(K key) {
    for (var category in applicationSettings.categories) {
      for (var group in category.groups) {
        for (var setting in group.settings) {
          if (setting.storageKey == key) {
            return setting.valueObs as Rx<T>;
          }
        }
      }
    }
    throw Exception('Setting not found');
  }

  static SettingsController<K> find<K>() {
    return Get.find<SettingsController<K>>();
  }
}
