import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './routes/pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.light,
    );

    return GetMaterialApp.router(
      title: 'Flutter Demo',
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
