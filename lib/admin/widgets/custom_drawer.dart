import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/admin.dart';
import 'package:kindah/providers/admin_provider.dart';
import 'package:provider/provider.dart';

import '../../models/drawer_item.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Widget buildDrawerItemDesign(
      BuildContext context, int index, DrawerItem item) {
    if (index == 0 || index == 20 || index == 21 || index == 22) {
      return DrawerItemDesign(
        item: item,
      );
    } else if (index == 1) {
      return CustomExpansionTile(item: item, title: "Orders", children: [
        DrawerItemDesign(item: drawerItems[1]),
        DrawerItemDesign(item: drawerItems[2]),
        DrawerItemDesign(item: drawerItems[3]),
        DrawerItemDesign(item: drawerItems[4]),
      ]);
    } else if (index == 5) {
      return CustomExpansionTile(item: item, title: "Schools", children: [
        DrawerItemDesign(item: drawerItems[5]),
        DrawerItemDesign(item: drawerItems[6]),
        DrawerItemDesign(item: drawerItems[7])
      ]);
    } else if (index == 8) {
      return CustomExpansionTile(item: item, title: "Uniforms", children: [
        DrawerItemDesign(item: drawerItems[8]),
        DrawerItemDesign(item: drawerItems[9]),
        DrawerItemDesign(item: drawerItems[10]),
      ]);
    } else if (index == 11) {
      return CustomExpansionTile(item: item, title: "Users", children: [
        DrawerItemDesign(item: drawerItems[11]),
        DrawerItemDesign(item: drawerItems[12]),
        DrawerItemDesign(item: drawerItems[13]),
      ]);
    } else if (index == 14) {
      return CustomExpansionTile(item: item, title: "Payments", children: [
        DrawerItemDesign(item: drawerItems[14]),
        DrawerItemDesign(item: drawerItems[15]),
      ]);
    } else if (index == 16) {
      return CustomExpansionTile(
          item: item,
          title: "Ecommerce Products",
          children: [
            DrawerItemDesign(item: drawerItems[16]),
            DrawerItemDesign(item: drawerItems[17]),
            DrawerItemDesign(item: drawerItems[18]),
            DrawerItemDesign(item: drawerItems[19]),
          ]);
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

    return Container(
      width: size.width,
      color: isSelected ? Colors.black26 : Colors.transparent,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextButton.icon(
            onPressed: () {
              context
                  .read<AdminProvider>()
                  .changeDrawerItem(widget.item.urlID!);

              context.go("/admin/${admin.id}/${widget.item.urlID}");
            },
            label: Text(
              widget.item.name!,
              style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
  }
}
