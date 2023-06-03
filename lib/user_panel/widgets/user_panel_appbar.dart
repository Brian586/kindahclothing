import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config.dart';
import '../../models/account.dart';
import '../../providers/account_provider.dart';

class UserPanelAppbar extends StatelessWidget {
  final bool? isMobile;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const UserPanelAppbar({
    super.key,
    this.isMobile,
    this.scaffoldKey,
  });

  String filterUserRole(Account account) {
    switch (account.userRole) {
      case "shop_attendant":
        return "Shop Attendant";
      case "fabric_cutter":
        return "Fabric Cutter";
      case "tailor":
        return "Tailor";
      case "finisher":
        return "Finisher";
      default:
        return "Tailor";
    }
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<AccountProvider>().account;

    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: Config.diagonalGradient),
      ),
      leading: isMobile!
          ? IconButton(
              onPressed: () => scaffoldKey!.currentState!.openDrawer(),
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
              ),
            )
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, ${account.username}",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            filterUserRole(account),
            style: const TextStyle(fontSize: 13.0, color: Colors.white60),
          )
        ],
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isMobile!
                ? Container()
                : Text(
                    account.username!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
            const SizedBox(
              width: 10.0,
            ),
            InkWell(
              onTap: () {
                context.read<AccountProvider>().changeDrawerItem("settings");
                context
                    .go("/users/${account.userRole}s/${account.id}/settings");
              },
              child: CircleAvatar(
                backgroundImage: const AssetImage("assets/images/profile.png"),
                backgroundColor: Colors.white,
                radius: 15.0,
                foregroundImage: account.photoUrl! == ""
                    ? null
                    : NetworkImage(account.photoUrl!),
              ),
            )
          ],
        ),
        const SizedBox(
          width: 20.0,
        ),
      ],
    );
  }
}
