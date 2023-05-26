import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kindah/pages/user_intro.dart';
import 'package:kindah/widgets/adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:kindah/models/order.dart' as template;

import '../Ads/ad_state.dart';
import '../config.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
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
  bool loading = false;
  BannerAd? bannerAd;

  @override
  void initState() {
    super.initState();

    getAccountInfo();
  }

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

  void getAccountInfo() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userID)
        .get();

    Account account = Account.fromDocument(documentSnapshot);

    if (account.isNew!) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserIntro(
                    userType: "fabric_cutter",
                  )));

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userID)
          .update({"isNew": false});
    }

    Provider.of<AccountProvider>(context, listen: false).changeAccount(account);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<AccountProvider>().account;

    return loading
        ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: circularProgress(),
            ),
          )
        : AdaptiveUI(
            appbarLeading: null,
            appbarTitle: "Welcome, ${account.username}",
            appbarSubtitle: "Fabric Cutter",
            body: Column(
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
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
                              children: List.generate(orders.length, (index) {
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
          );
  }
}
