import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/drawer_item.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';

class UserPanelDrawer extends StatelessWidget {
  const UserPanelDrawer({
    super.key,
  });

  Widget groupedDrawerItems(
    String title,
    List<dynamic> accessRights,
    int firstIndex,
    int lastIndex,
  ) {
    List<DrawerItem> groupedItems = drawerItems
        .where((item) =>
            drawerItems.indexOf(item) >= firstIndex &&
            drawerItems.indexOf(item) <= lastIndex)
        .toList();

    int filteredGroupedCount = 0;

    groupedItems.forEach((item) {
      if (accessRights.contains(drawerItems.indexOf(item))) {
        filteredGroupedCount = filteredGroupedCount + 1;
      }
    });

    return filteredGroupedCount == 0
        ? Container()
        : UserCustomExpansionTile(
            item: groupedItems[0],
            title: title,
            children: List.generate(
              groupedItems.length,
              (index) => accessRights.contains((firstIndex + index))
                  ? UserDrawerItemDesign(
                      item: drawerItems[(firstIndex + index)])
                  : Container(),
            ));
  }

  Widget buildDrawerItemDesign(BuildContext context, int index, DrawerItem item,
      List<dynamic> accessRights) {
    if (index == 0 || index == 20 || index == 21 || index == 22) {
      return accessRights.contains((index))
          ? UserDrawerItemDesign(
              item: item,
            )
          : Container();
    } else if (index == 1) {
      return groupedDrawerItems("Orders", accessRights, 1, 4);
    } else if (index == 5) {
      return groupedDrawerItems("Schools", accessRights, 5, 7);
    } else if (index == 8) {
      return groupedDrawerItems("Uniforms", accessRights, 8, 10);
    } else if (index == 11) {
      return groupedDrawerItems("Users", accessRights, 11, 13);
    } else if (index == 14) {
      return groupedDrawerItems("Payments", accessRights, 14, 15);
    } else if (index == 16) {
      return groupedDrawerItems("Ecommerce Products", accessRights, 16, 19);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Account account = context.watch<AccountProvider>().account;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          DrawerHeader(
            child: Image.asset(
              "assets/images/logo.png",
              width: size.width,
              fit: BoxFit.contain,
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(account.id)
                .collection("access_rights")
                .doc("access_rights")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                // Get Access rights
                List<dynamic> accessRights = [];

                accessRights.add(0);
                accessRights.add(22);

                if (snapshot.data!.exists) {
                  List<dynamic> accessItems = snapshot.data!["items"];

                  // Add AccessItems to AccessRights
                  accessItems.forEach((item) {
                    accessRights.add(item + 1);
                  });
                }
                // Sort numbers from smallest to largest
                accessRights.sort();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(drawerItems.length, (index) {
                    DrawerItem item = drawerItems[index];

                    return buildDrawerItemDesign(
                        context, index, item, accessRights);
                  }),
                );
              }
            },
          )
        ],
      ),
    );
  }
}

class UserCustomExpansionTile extends StatefulWidget {
  final DrawerItem item;
  final String title;
  final List<Widget> children;
  const UserCustomExpansionTile(
      {super.key,
      required this.item,
      required this.title,
      required this.children});

  @override
  State<UserCustomExpansionTile> createState() =>
      _UserCustomExpansionTileState();
}

class _UserCustomExpansionTileState extends State<UserCustomExpansionTile> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      onExpansionChanged: (value) {
        setState(() {
          isExpanded = value;
        });
      },
      iconColor: isExpanded ? Config.customBlue : Config.customGrey,
      leading: Icon(
        widget.item.iconData,
        color: isExpanded ? Config.customBlue : Config.customGrey,
      ),
      childrenPadding: const EdgeInsets.only(left: 10.0),
      title: Text(
        widget.title,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: isExpanded ? Config.customBlue : Config.customGrey,
        ),
      ),
      children: widget.children,
    );
  }
}

class UserDrawerItemDesign extends StatefulWidget {
  final DrawerItem item;
  const UserDrawerItemDesign({
    super.key,
    required this.item,
  });

  @override
  State<UserDrawerItemDesign> createState() => _UserDrawerItemDesignState();
}

class _UserDrawerItemDesignState extends State<UserDrawerItemDesign> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String selectedDrawerItem =
        context.watch<AccountProvider>().selectedDrawerItem;
    Account account = context.watch<AccountProvider>().account;
    bool isSelected = selectedDrawerItem == widget.item.urlID;

    return Container(
      width: size.width,
      color:
          isSelected ? Config.customBlue.withOpacity(0.1) : Colors.transparent,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextButton.icon(
            onPressed: () {
              context
                  .read<AccountProvider>()
                  .changeDrawerItem(widget.item.urlID!);

              context.go(
                  "/users/${account.userRole}s/${account.id}/${widget.item.urlID}");
            },
            label: Text(
              widget.item.name!,
              style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Config.customBlue : Config.customGrey),
            ),
            icon: Icon(
              widget.item.iconData,
              color: isSelected ? Config.customBlue : Config.customGrey,
            ),
          ),
        ),
      ),
    );
  }
}
