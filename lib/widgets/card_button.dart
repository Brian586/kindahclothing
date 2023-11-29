import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';

class CardButton extends StatelessWidget {
  final String destinationUrl;
  final String title;
  const CardButton(
      {super.key, required this.destinationUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<AccountProvider>().account;
    String preferedRole = context.watch<AccountProvider>().preferedRole;
    return InkWell(
      onTap: () {
        context.read<AccountProvider>().changeDrawerItem(destinationUrl);
        context.go("/users/${preferedRole}s/${account.id}/$destinationUrl");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Card(
          color: Config.customBlue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SizedBox(
            height: 150.0,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20.0,
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .apply(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  "assets/images/order.png",
                  height: 150.0,
                  width: 120.0,
                  fit: BoxFit.contain,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
