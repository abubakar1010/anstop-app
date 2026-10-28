import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/services/app_mode.dart';
import 'package:ride_sharing/utils/driver/driver_custom_drawer.dart';
import 'package:ride_sharing/utils/passenger/passenger_custom_drawer.dart';
import 'package:ride_sharing/widgets/unread_badge.dart';

/// Navigation between the drawer's pages.
///
/// Every drawer page sits directly on top of home: opening one replaces the
/// drawer page that was open instead of stacking on it, so the system back
/// gesture always returns home, as in a standard app.
class DrawerNavigation {
  DrawerNavigation._();

  /// Route argument that marks a page as opened from the drawer: it then
  /// shows the menu button. The same page opened from inside a flow (e.g.
  /// payment methods from checkout) keeps its back button.
  static const fromDrawerArgument = {'fromDrawer': true};

  static bool _isHome(Route<dynamic> route) =>
      route.settings.name == AppMode.homeRoute || route.isFirst;

  static void go(String route) {
    if (Get.currentRoute == route) return;
    if (route == AppMode.homeRoute) {
      Get.until(_isHome);
      // Home was not in the stack (e.g. opened from a notification).
      if (Get.currentRoute != route) Get.offAllNamed(route);
      return;
    }
    Get.offNamedUntil(route, _isHome, arguments: fromDrawerArgument);
  }

  static bool openedFromDrawer(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return arguments is Map && arguments['fromDrawer'] == true;
  }
}

/// The drawer of the current mode, for pages both roles share.
class ModeDrawer extends StatelessWidget {
  const ModeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppMode.isDriver.value ? DriverCustomDrawer() : PassengerCustomDrawer());
  }
}

/// App bar leading button: the menu (with the unread badge) on a page opened
/// from the drawer, otherwise a back button.
class DrawerOrBackButton extends StatelessWidget {
  const DrawerOrBackButton({super.key, this.color = Colors.black, this.backIcon = Icons.arrow_back});

  final Color color;
  final IconData backIcon;

  @override
  Widget build(BuildContext context) {
    if (DrawerNavigation.openedFromDrawer(context)) {
      return IconButton(
        icon: WithUnreadBadge(child: Icon(Icons.menu, color: color)),
        onPressed: () => Scaffold.of(context).openDrawer(),
      );
    }
    return IconButton(
      icon: Icon(backIcon, color: color),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
