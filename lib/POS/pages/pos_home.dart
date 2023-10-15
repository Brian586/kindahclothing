import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/POS/pages/pos_cart_page.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config.dart';
import '../models/nav_model.dart';
import '../widgets/custom_nav_bar.dart';
import 'pos_product_page.dart';

class POSHome extends StatefulWidget {
  final String userID;
  const POSHome({super.key, required this.userID});

  @override
  State<POSHome> createState() => _POSHomeState();
}

class _POSHomeState extends State<POSHome> {
  Widget buildBody(BuildContext context) {
    return POSProductPage(userID: widget.userID);
  }

  Widget buildDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CustomNavBar(
            currentPage: "home",
            userID: widget.userID,
          ),
        ),
        Expanded(
          flex: 8,
          child: Align(alignment: Alignment.topLeft, child: buildBody(context)),
        ),
        Expanded(
          flex: 5,
          child: POSCartPage(userID: widget.userID, isDesktop: true),
        ),
      ],
    );
  }

  choiceAction(BuildContext context, NavModel nav) {
    GoRouter.of(context).go("/POS/${widget.userID}/${nav.route}");
  }

  List<Widget> buildActions() {
    return [
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("POS_users")
            .doc(widget.userID)
            .collection("cart")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          } else {
            int count = snapshot.data!.docs.length;

            return Stack(
              children: [
                IconButton(
                    onPressed: () =>
                        GoRouter.of(context).go("/POS/${widget.userID}/cart"),
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white60,
                    )),
                Positioned(
                  top: 5.0,
                  right: 0.0,
                  child: count == 0
                      ? const SizedBox()
                      : Container(
                          decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.circular(7.0)),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10.0),
                              ),
                            ),
                          ),
                        ),
                )
              ],
            );
          }
        },
      ),
      PopupMenuButton<NavModel>(
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
          //size: 25.0,
        ),
        offset: const Offset(0.0, 10.0),
        onSelected: (v) {
          choiceAction(context, v);
        },
        itemBuilder: (BuildContext context) {
          return navs.map((NavModel nav) {
            return PopupMenuItem<NavModel>(
              value: nav,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    nav.iconData,
                    color: Config.customGrey,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(nav.title!)
                ],
              ),
            );
          }).toList();
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.isMobile;

        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration:
                  const BoxDecoration(gradient: Config.diagonalGradient),
            ),
            title: const Text("Kindah POS"),
            actions: isMobile ? buildActions() : null,
          ),
          body: isMobile ? buildBody(context) : buildDesktop(context),
        );
      },
    );
  }
}
