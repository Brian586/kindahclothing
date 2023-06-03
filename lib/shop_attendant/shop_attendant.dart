import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/providers/account_provider.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/no_data.dart';
import 'package:kindah/widgets/order_design.dart';
import 'package:provider/provider.dart';
import 'package:kindah/models/order.dart' as template;

import '../Ads/ad_state.dart';
import '../user_panel/widgets/user_custom_header.dart';
import '../widgets/progress_widget.dart';

class ShopAttendant extends StatefulWidget {
  const ShopAttendant({
    super.key,
  });

  @override
  State<ShopAttendant> createState() => _ShopAttendantState();
}

class _ShopAttendantState extends State<ShopAttendant> {
  BannerAd? bannerAd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!kIsWeb) {
      final adState = Provider.of<AdState>(context);
      adState.initialization.then((status) {
        setState(() {
          bannerAd = BannerAd(
              size: AdSize.banner,
              adUnitId: adState.bannerAdUnitId,
              listener: adState.adListener,
              request: AdRequest())
            ..load();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Account account = context.watch<AccountProvider>().account;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const UserCustomHeader(
            action: [],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: CustomWrapper(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        context
                            .read<AccountProvider>()
                            .changeDrawerItem("add_order");
                        context.go(
                            "/users/${account.userRole}s/${account.id}/add_order");
                      },
                      child: Card(
                        color: Config.customBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        "Add New Template",
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Recent Templates",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Config.customGrey),
                          ),
                          SizedBox()
                        ],
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("orders")
                          .where("publisher", isEqualTo: account.id)
                          // .where("processedStatus", isNotEqualTo: "finished")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return circularProgress();
                        } else {
                          List<template.Order> orders = [];

                          snapshot.data!.docs.forEach((element) {
                            template.Order order =
                                template.Order.fromDocument(element);

                            orders.add(order);
                          });

                          if (orders.isEmpty) {
                            return const NoData(
                              title: "No Available Templates",
                            );
                          } else {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(orders.length, (index) {
                                template.Order order = orders[index];
                                bool isFinished =
                                    order.processedStatus == "finished";

                                return OrderDesign(
                                  order: order,
                                  isFinished: isFinished,
                                );
                              }),
                            );
                          }
                        }
                      },
                    ),
                    kIsWeb
                        ? const SizedBox(
                            height: 0.0,
                          )
                        : bannerAd != null
                            ? SizedBox(
                                height: 50.0,
                                child: AdWidget(ad: bannerAd!),
                              )
                            : const SizedBox(
                                height: 0.0,
                              ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("orders")
                          .where("processedStatus", isEqualTo: "finished")
                          .where("shopAttendant.id", isEqualTo: account.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return circularProgress();
                        } else {
                          List<template.Order> orders = [];

                          snapshot.data!.docs.forEach((element) {
                            template.Order order =
                                template.Order.fromDocument(element);

                            orders.add(order);
                          });

                          if (orders.isEmpty) {
                            return Container();
                          } else {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "Orders Ready To Be Dispatched",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Config.customGrey),
                                      ),
                                      SizedBox()
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      List.generate(orders.length, (index) {
                                    template.Order order = orders[index];

                                    return OrderDesign(
                                      order: order,
                                      isFinished: true,
                                    );
                                  }),
                                ),
                              ],
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
