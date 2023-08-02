import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'side_navigation.dart';
import '../controllers/root_controller.dart';
import '../../../routes/pages.dart';
import 'package:context_menus/context_menus.dart';

class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(
      builder: (context, delegate, current) {
        return ContextMenuOverlay(
          child: Row(
            children: [
              SideNavigation(),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: GetRouterOutlet(
                  initialRoute: AppPages.initial,
                  anchorRoute: Routes.root,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
