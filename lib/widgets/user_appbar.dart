import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/providers/account_provider.dart';
import 'package:provider/provider.dart';

class UserAppbar extends StatelessWidget {
  final bool? isMobile;
  final Widget? leading;
  final Widget? title;
  const UserAppbar({super.key, this.isMobile, this.leading, this.title});

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<AccountProvider>().account;
    String preferedRole = context.watch<AccountProvider>().preferedRole;

    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: Config.diagonalGradient),
      ),
      leading: leading,
      title: title,
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
              onTap: () =>
                  context.go("/users/${preferedRole}s/${account.id}/settings"),
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
