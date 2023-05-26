import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config.dart';
import '../models/nav_model.dart';

class CustomNavBar extends StatefulWidget {
  final String currentPage;
  final String userID;
  const CustomNavBar(
      {super.key, required this.currentPage, required this.userID});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  void onPressed(BuildContext context, String value) {
    GoRouter.of(context).go("/POS/${widget.userID}/$value");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(navs.length, (index) {
        NavModel nav = navs[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: IconButton(
            onPressed: () => onPressed(context, nav.route!),
            icon: Icon(
              nav.iconData,
              color: widget.currentPage == nav.route
                  ? Config.customBlue
                  : Config.customGrey,
            ),
          ),
        );
      }),
    );
  }
}
