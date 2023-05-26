import 'package:flutter/material.dart';

class NavModel {
  final String? title;
  final String? route;
  final IconData? iconData;

  NavModel({this.title, this.route, this.iconData});
}

List<NavModel> navs = [
  NavModel(
    title: "Home",
    route: "home",
    iconData: Icons.dashboard_outlined,
  ),
  NavModel(
    title: "Analytics",
    route: "analytics",
    iconData: Icons.insights,
  ),
  NavModel(
    title: "Orders",
    route: "orders",
    iconData: Icons.shopping_bag_outlined,
  ),
  NavModel(
    title: "Upload",
    route: "upload",
    iconData: Icons.cloud_upload_outlined,
  ),
  NavModel(
    title: "Categories",
    route: "categories",
    iconData: Icons.category_outlined,
  ),
  NavModel(
    title: "Settings",
    route: "settings",
    iconData: Icons.settings_rounded,
  ),
];
