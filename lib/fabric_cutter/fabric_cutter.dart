import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kindah/pages/user_intro.dart';
import 'package:kindah/widgets/adaptive_ui.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:kindah/models/order.dart' as template;

import '../Ads/ad_state.dart';
import '../config.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../user_panel/widgets/user_custom_header.dart';
import '../widgets/no_data.dart';
import '../widgets/order_design.dart';
import '../widgets/progress_widget.dart';

class FabricCutter extends StatefulWidget {
  final String? userID;
  const FabricCutter({super.key, this.userID});

  @override
  State<FabricCutter> createState() => _FabricCutterState();
}

class _FabricCutterState extends State<FabricCutter> {
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
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("orders")
                          .where("processedStatus", isEqualTo: "processing")
                          .where("fabricCutter.id", isEqualTo: account.id)
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
                                        "Currently \nProcessing",
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
                                      isFinished: false,
                                    );
                                  }),
                                ),
                              ],
                            );
                          }
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Choose Template \nTo Process",
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
                          .where("processedStatus", isEqualTo: "not processed")
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

                                return OrderDesign(
                                  order: order,
                                  isFinished: false,
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
