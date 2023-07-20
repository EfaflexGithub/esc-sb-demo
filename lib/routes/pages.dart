import 'package:efa_smartconnect_modbus_demo/modules/help_and_feedback/bindings/help_and_feedback_binding.dart';
import 'package:efa_smartconnect_modbus_demo/modules/help_and_feedback/views/help_and_feedback_page.dart';
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
      name: Routes.root,
      page: () => const RootView(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
      children: [
        GetPage(
          name: Routes.doorOverview,
          page: () => const DoorOverviewPage(),
          binding: DoorOverviewBinding(),
        ),
        GetPage(
          name: Routes.eventOverview,
          page: () => const EventOverviewPage(),
          binding: EventOverviewBinding(),
        ),
        GetPage(
          name: Routes.helpAndFeedback,
          page: () => const HelpAndFeedbackPage(),
          binding: HelpAndFeedbackBinding(),
        ),
      ],
    ),
  ];
}
