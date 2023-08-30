part of './pages.dart';

abstract class Routes {
  static const root = _Paths.root;
  static const doorOverview = _Paths.doorOverview;
  // static const doorDetails = _Paths.doorDetails;
  static const eventOverview = _Paths.eventOverview;
  static const settings = _Paths.settings;
  static const helpAndFeedback = _Paths.helpAndFeedback;

  static String doorDetails(int smartDoorId) => '$doorOverview/$smartDoorId';

  Routes._();
}

abstract class _Paths {
  static const root = '/';
  static const doorOverview = '/door-overview';
  static const doorDetails = '/:smartDoorId';
  static const eventOverview = '/event-overview';
  static const settings = '/settings';
  static const helpAndFeedback = '/help-and-feedback';
}
