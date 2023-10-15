import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/admin.dart';
import 'package:kindah/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../models/drawer_item.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Widget groupedDrawerItems(String title, int firstIndex, int lastIndex) {
    List<DrawerItem> groupedItems = drawerItems
        .where((item) =>
            drawerItems.indexOf(item) >= firstIndex &&
            drawerItems.indexOf(item) <= lastIndex)
        .toList();

    return CustomExpansionTile(
        item: groupedItems[0],
        title: title,
        children: List.generate(
          groupedItems.length,
          (index) => DrawerItemDesign(item: drawerItems[(firstIndex + index)]),
        ));
  }

  Widget buildDrawerItemDesign(
      BuildContext context, int index, DrawerItem item) {
    if (index == 0 || index == 20 || index == 21 || index == 22) {
      return DrawerItemDesign(
        item: item,
      );
    } else if (index == 1) {
      return groupedDrawerItems("Orders", 1, 4);
    } else if (index == 5) {
      return groupedDrawerItems("Schools", 5, 7);
    } else if (index == 8) {
      return groupedDrawerItems("Uniforms", 8, 10);
    } else if (index == 11) {
      return groupedDrawerItems("Users", 11, 13);
    } else if (index == 14) {
      return groupedDrawerItems("Payments", 14, 15);
    } else if (index == 16) {
      return groupedDrawerItems("Ecommerce Products", 16, 19);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Drawer(
      child: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(gradient: Config.diagonalGradient),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListView(
                children: List.generate(drawerItems.length, (index) {
                  DrawerItem item = drawerItems[index];

                  return buildDrawerItemDesign(context, index, item);
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final DrawerItem item;
  final String title;
  final List<Widget> children;
  const CustomExpansionTile(
      {super.key,
      required this.item,
      required this.title,
      required this.children});

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      onExpansionChanged: (value) {
        setState(() {
          isExpanded = value;
        });
      },
      iconColor: isExpanded ? Colors.white : Colors.white70,
      leading: Icon(
        widget.item.iconData,
        color: isExpanded ? Colors.white : Colors.white70,
      ),
      childrenPadding: const EdgeInsets.only(left: 10.0),
      title: Text(
        widget.title,
        style: TextStyle(
            fontWeight: FontWeight.normal,
            color: isExpanded ? Colors.white : Colors.white70),
      ),
      children: widget.children,
    );
  }
}

class DrawerItemDesign extends StatefulWidget {
  final DrawerItem item;
  const DrawerItemDesign({
    super.key,
    required this.item,
  });

  @override
  State<DrawerItemDesign> createState() => _DrawerItemDesignState();
}

class _DrawerItemDesignState extends State<DrawerItemDesign> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String selectedDrawerItem =
        context.watch<AdminProvider>().selectedDrawerItem;
    Admin admin = context.watch<AdminProvider>().admin;
    bool isSelected = selectedDrawerItem == widget.item.urlID;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile =
            sizingInformation.isMobile || sizingInformation.isTablet;

        return Container(
          width: size.width,
          color: isSelected ? Colors.black26 : Colors.transparent,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: TextButton.icon(
                onPressed: () {
                  context
                      .read<AdminProvider>()
                      .changeDrawerItem(widget.item.urlID!);

                  context.go("/admin/${admin.id}/${widget.item.urlID}");

                  if (isMobile) {
                    Navigator.pop(context);
                  }
                },
                label: Text(
                  widget.item.name!,
                  style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.white70),
                ),
                icon: Icon(
                  widget.item.iconData,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
