import 'package:flutter/material.dart';

class DrawerItem {
  final String? name;
  final IconData? iconData;
  final String? urlID;

  DrawerItem({this.name, this.iconData, this.urlID});
}

List<DrawerItem> drawerItems = [
  DrawerItem(
    //0 ==
    name: "Dashboard",
    iconData: Icons.home_rounded,
    urlID: "dashboard",
  ),
  DrawerItem(
    //1 ==
    name: "All Orders",
    iconData: Icons.list_alt_rounded,
    urlID: "orders",
  ),
  DrawerItem(
    //2 ==
    name: "Order Status",
    iconData: Icons.checklist_outlined,
    urlID: "order_status",
  ),
  DrawerItem(
    //3 ==
    name: "Add Order",
    iconData: Icons.format_list_bulleted_add,
    urlID: "add_order",
  ),
  DrawerItem(
    //4 ==
    name: "Edit Orders",
    iconData: Icons.edit_rounded,
    urlID: "edit_orders",
  ),
  DrawerItem(
    //5 ==
    name: "All Schools",
    iconData: Icons.school_rounded,
    urlID: "schools",
  ),
  DrawerItem(
    //6 ==
    name: "Add Schools",
    iconData: Icons.school_rounded,
    urlID: "add_schools",
  ),
  DrawerItem(
    //7 ==
    name: "Edit Schools",
    iconData: Icons.edit_rounded,
    urlID: "edit_schools",
  ),
  DrawerItem(
    //8 ==
    name: "All Uniforms",
    iconData: Icons.school_rounded,
    urlID: "uniforms",
  ),
  DrawerItem(
    //9 ==
    name: "Add Uniforms",
    iconData: Icons.school_rounded,
    urlID: "add_uniforms",
  ),
  DrawerItem(
    //10 ==
    name: "Edit Uniforms",
    iconData: Icons.edit_rounded,
    urlID: "edit_uniforms",
  ),
  DrawerItem(
    //11 ==
    name: "All Users",
    iconData: Icons.people_alt_rounded,
    urlID: "users",
  ),
  DrawerItem(
    //12 ==
    name: "Add Users",
    iconData: Icons.person_add_outlined,
    urlID: "add_users",
  ),
  DrawerItem(
    //13 ==
    name: "Edit Users",
    iconData: Icons.edit_rounded,
    urlID: "edit_users",
  ),
  DrawerItem(
    //14 ==
    name: "All Payments",
    iconData: Icons.payments_outlined,
    urlID: "payments",
  ),
  DrawerItem(
    //15 ==
    name: "Advance Payments",
    iconData: Icons.payments_outlined,
    urlID: "advance_payments",
  ),
  DrawerItem(
    //16 ==
    name: "All Products",
    iconData: Icons.photo,
    urlID: "products",
  ),
  DrawerItem(
    //17 ==
    name: "Add Products",
    iconData: Icons.add_a_photo_rounded,
    urlID: "add_products",
  ),
  DrawerItem(
    //18 ==
    name: "Edit Products",
    iconData: Icons.edit,
    urlID: "edit_products",
  ),
  DrawerItem(
    //19 ==
    name: "Product Categories",
    iconData: Icons.category_rounded,
    urlID: "product_categories",
  ),
  DrawerItem(
    //20 ==
    name: "My Tariffs",
    iconData: Icons.currency_exchange_outlined,
    urlID: "my_tariffs",
  ),
  DrawerItem(
    //21 ==
    name: "Inventory",
    iconData: Icons.inventory_outlined,
    urlID: "inventory",
  ),
  DrawerItem(
    //22 ==
    name: "General Settings",
    iconData: Icons.settings_rounded,
    urlID: "settings",
  ),
];
