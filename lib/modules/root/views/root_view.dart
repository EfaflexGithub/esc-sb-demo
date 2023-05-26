import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'side_navigation.dart';
import '../controllers/root_controller.dart';
import '../../../routes/pages.dart';

class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(
      builder: (context, delegate, current) {
        // final title = current?.location;
        return Row(
          children: [
            const SideNavigation(),
            Expanded(
              child: Scaffold(
                // appBar: AppBar(
                //   title: Text(title ?? ''),
                //   centerTitle: true,
                // ),
                body: GetRouterOutlet(
                  initialRoute: Routes.DOOR_OVERVIEW,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
