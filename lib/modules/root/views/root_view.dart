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
            SideNavigation(),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GetRouterOutlet(
                    initialRoute: AppPages.initial,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
