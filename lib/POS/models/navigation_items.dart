import 'package:flutter/material.dart';

enum NavigationItems {
  products,
  analytics,
  // home,
  // employees,
}

extension NavigationItemsExtensions on NavigationItems {
  IconData get icon {
    switch (this) {
      // case NavigationItems.home:
      //   return Iconsax.home;
      case NavigationItems.products:
        return Icons.conveyor_belt;
      case NavigationItems.analytics:
        return Icons.bar_chart_outlined;
      // case NavigationItems.employees:
      // return Iconsax.people;
      default:
        return Icons.add;
    }
  }
}
