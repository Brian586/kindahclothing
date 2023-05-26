import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:provider/provider.dart';

import '../../models/admin.dart';
import '../../providers/admin_provider.dart';

class DashCard extends StatelessWidget {
  final Color? backgroundColor;
  final String? imageUrl;
  final String? pathTo;
  final int? count;
  final String? title;

  const DashCard(
      {super.key,
      this.backgroundColor,
      this.imageUrl,
      this.pathTo,
      this.count,
      this.title});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Admin admin = context.watch<AdminProvider>().admin;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: backgroundColor,
      elevation: 5.0,
      child: SizedBox(
        height: 150.0,
        width: 200.0,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    imageUrl!,
                    height: 100.0,
                    width: 100.0,
                    fit: BoxFit.contain,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              count.toString(),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            title!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .apply(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10.0))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: pathTo == ""
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Text(
                          "Product Orders",
                          style: TextStyle(
                              color: Config.customGrey,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "View Details",
                            style: TextStyle(
                                color: Config.customGrey,
                                fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            onPressed: () {
                              context
                                  .read<AdminProvider>()
                                  .changeDrawerItem(pathTo!);

                              context.go("/admin/${admin.id}/$pathTo");
                            },
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Config.customGrey,
                            ),
                          )
                        ],
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
