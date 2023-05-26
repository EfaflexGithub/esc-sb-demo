import 'package:get/get.dart';
import '../modules/root/views/root_view.dart';
import '../modules/door_overview/bindings/door_overview_binding.dart';
import '../modules/door_overview/views/door_overview_page.dart';
import '../modules/event_overview/bindings/event_overview_binding.dart';
import '../modules/event_overview/views/event_overview_page.dart';
part './routes.dart';

abstract class AppPages {
  AppPages._(); // make constructor private

  static const INITIAL = Routes.DOOR_OVERVIEW;

  static final routes = [
    GetPage(
        name: '/',
        page: () => RootView(),
        participatesInRootNavigator: true,
        preventDuplicates: true,
        children: [
          GetPage(
            name: Routes.DOOR_OVERVIEW,
            page: () => DoorOverviewPage(),
            binding: DoorOverviewBinding(),
          ),
          GetPage(
            name: Routes.EVENT_OVERVIEW,
            page: () => EventOverviewPage(),
            binding: EventOverviewBinding(),
          ),
        ]),
  ];

  static final modalRoutes = [
    GetPage(
      name: Routes.SETTINGS,
      page: () => DoorOverviewPage(),
    ),
    GetPage(
      name: Routes.HELP_FEEDBACK,
      page: () => DoorOverviewPage(),
    ),
  ];
}
