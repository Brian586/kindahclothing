import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/admin.dart';
import 'package:kindah/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class AdminAppBar extends StatelessWidget {
  final bool? isMobile;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const AdminAppBar({super.key, this.isMobile, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    Admin admin = context.watch<AdminProvider>().admin;

    return AppBar(
      backgroundColor: Colors.white,
      leading: isMobile!
          ? IconButton(
              onPressed: () => scaffoldKey!.currentState!.openDrawer(),
              icon: const Icon(
                Icons.menu_rounded,
                color: Config.customGrey,
              ),
            )
          : null,
      title: Image.asset(
        "assets/images/admin_logo.png",
        height: kToolbarHeight,
        fit: BoxFit.contain,
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isMobile!
                ? Container()
                : Text(
                    admin.username!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Config.customGrey, fontWeight: FontWeight.w700),
                  ),
            const SizedBox(
              width: 10.0,
            ),
            CircleAvatar(
              backgroundImage: const AssetImage("assets/images/profile.png"),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              radius: 15.0,
              foregroundImage:
                  admin.photoUrl! == "" ? null : NetworkImage(admin.photoUrl!),
            )
          ],
        ),
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            IconButton(
              onPressed: () {
                context.read<AdminProvider>().changeDrawerItem("notifications");

                context.go("/admin/${admin.id}/notifications");
              },
              icon: const Icon(
                Icons.notifications_none,
                color: Config.customGrey,
                size: 25.0,
              ),
            ),
            const Positioned(
              top: 10.0,
              right: 5.0,
              child: Icon(
                Icons.circle,
                color: Colors.red,
                size: 10.0,
              ),
            )
          ],
        ),
        IconButton(
          onPressed: () {
            context.read<AdminProvider>().changeDrawerItem("settings");

            context.go("/admin/${admin.id}/settings");
          },
          icon: const Icon(
            Icons.settings_rounded,
            color: Config.customGrey,
          ),
        )
      ],
    );
  }
}
