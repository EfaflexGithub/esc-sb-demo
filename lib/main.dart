import 'package:efa_smartconnect_modbus_demo/data/services/door_collection_service.dart';
import 'package:efa_smartconnect_modbus_demo/data/services/modbus_register_service.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/controllers/settings_controller.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/models/application_setttings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import './routes/pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await initializeApplication();
  bool darkMode = await Get.find<SettingsController<ApplicationSettingKeys>>()
          .getValueFromKey<bool>(ApplicationSettingKeys.appDarkMode) ??
      false;
  runApp(MyApp(brightness: darkMode ? Brightness.dark : Brightness.light));
}

Future<void> initializeApplication() async {
  // add LICENSE.md of the project to the LicenseRegistry
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('LICENSE.md');
    yield LicenseEntryWithLineBreaks(['EFA-SmartConnect Modbus Demo'], license);
  });
  await Hive.initFlutter();
  _registerServices();
}

void _registerServices() {
  Get.put(ModbusRegisterService(), permanent: true);
  Get.put(DoorCollectionService(), permanent: true);
  Get.put(SettingsController<ApplicationSettingKeys>(applicationSettings),
      permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.brightness = Brightness.light});

  final Brightness brightness;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: brightness,
    );

    return GetMaterialApp.router(
      title: 'EFA-SmartConnect Modbus Demo',
      theme: ThemeData(
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      getPages: AppPages.routes,
      defaultTransition: Transition.noTransition,
    );
  }
}
