import 'package:efa_smartconnect_modbus_demo/routes/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yaml/yaml.dart';

class SideNavigationController extends GetxController {
  final selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
    late final String routeName;
    switch (index) {
      case 0:
        routeName = Routes.doorOverview;
        break;
      case 1:
        routeName = Routes.eventOverview;
        break;
      default:
        throw ArgumentError("Invalid index: $index");
    }
    Get.rootDelegate.toNamed(routeName);
  }

  void showAbout({
    required BuildContext context,
    required Widget applicationIcon,
  }) async {
    final yamlString = await rootBundle.loadString('pubspec.yaml');
    final yamlMap = loadYaml(yamlString);
    final title = yamlMap['title'];
    final description = yamlMap['description'];
    final version = yamlMap['version'];
    const applicationLegalese =
        'EFAFLEX Tor- und Sicherheitssysteme GmbH & Co. KG and Contributors';

    List<String> descriptions = [
      description,
      '''This application is licensed under the GNU General Public License version 3 (GPLv3).
The GPLv3 allows you to use, modify, and distribute this software freely.
However, any modifications or derivative works you create must also be distributed under the GPLv3,
ensuring that the source code remains open and accessible.'''
    ];

    if (context.mounted) {
      final currentYear = DateTime.now().year;
      showAboutDialog(
        context: context,
        applicationIcon: applicationIcon,
        applicationName: title,
        applicationVersion: version,
        children: List.generate(
          descriptions.length,
          (index) => Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text(
              descriptions[index],
            ),
          ),
        ),
        applicationLegalese: '\u{a9} $currentYear $applicationLegalese',
      );
    }
  }
}
