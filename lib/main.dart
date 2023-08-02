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

void main() async {
  await initializeApplication();
  runApp(const MyApp());
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
  Get.put(SettingsController<AppSettingKeys>(applicationSettings),
      permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildThemeData(
      {required BuildContext context,
      Brightness brightness = Brightness.light,
      Color seedColor = const Color.fromARGB(255, 246, 120, 40)}) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.inversePrimary,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: Theme.of(context).textTheme.bodyMedium,
      ),
      useMaterial3: true,
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final darkModeSetting = Get.find<SettingsController<AppSettingKeys>>()
        .getSettingFromKey(AppSettingKeys.appDarkMode);

    darkModeSetting.temporaryValueObs.listen((value) {
      Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    });

    final themeMode = darkModeSetting.value ? ThemeMode.dark : ThemeMode.light;

    return GetMaterialApp.router(
      title: 'EFA-SmartConnect Modbus Demo',
      theme: _buildThemeData(context: context),
      darkTheme: _buildThemeData(context: context, brightness: Brightness.dark),
      themeMode: themeMode,
      getPages: AppPages.routes,
      defaultTransition: Transition.noTransition,
    );
  }
}
