import 'package:efa_smartconnect_modbus_demo/modules/door_details/bindings/door_details_binding.dart';
import 'package:efa_smartconnect_modbus_demo/modules/door_details/views/door_details_page.dart';
import 'package:efa_smartconnect_modbus_demo/modules/help_and_feedback/bindings/help_and_feedback_binding.dart';
import 'package:efa_smartconnect_modbus_demo/modules/help_and_feedback/views/help_and_feedback_page.dart';
import 'package:efa_smartconnect_modbus_demo/modules/root/bindings/root_binding.dart';
import 'package:efa_smartconnect_modbus_demo/modules/settings/views/settings_page.dart';
import 'package:get/get.dart';
import '../modules/root/views/root_view.dart';
import '../modules/door_overview/bindings/door_overview_binding.dart';
import '../modules/door_overview/views/door_overview_page.dart';
import '../modules/event_overview/bindings/event_overview_binding.dart';
import '../modules/event_overview/views/event_overview_page.dart';
part './routes.dart';

abstract class AppPages {
  AppPages._(); // make constructor private
  static const initial = Routes.doorOverview;

  static final routes = [
    GetPage(
      name: '/',
      page: () => const RootView(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
      binding: RootBinding(),
      children: [
        GetPage(
          name: _Paths.doorOverview,
          page: () => DoorOverviewPage(),
          binding: DoorOverviewBinding(),
          children: [
            GetPage(
              name: _Paths.doorDetails,
              page: () => const DoorDetailsPage(),
              binding: DoorDetailsBinding(),
            ),
          ],
        ),
        GetPage(
          name: _Paths.eventOverview,
          page: () => const EventOverviewPage(),
          binding: EventOverviewBinding(),
        ),
        GetPage(
          name: _Paths.settings,
          page: () => const SettingsPage(),
        ),
        GetPage(
          name: _Paths.helpAndFeedback,
          page: () => const HelpAndFeedbackPage(),
          binding: HelpAndFeedbackBinding(),
        ),
      ],
    ),
  ];
}
