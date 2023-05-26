import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:kindah/models/order.dart' as template;

import '../Ads/ad_state.dart';
import '../config.dart';
import '../models/account.dart';
import '../pages/user_intro.dart';
import '../providers/account_provider.dart';
import '../widgets/adaptive_ui.dart';
import '../widgets/no_data.dart';
import '../widgets/order_design.dart';
import '../widgets/progress_widget.dart';

class Tailor extends StatefulWidget {
  final String? userID;
  const Tailor({super.key, this.userID});

  @override
  State<Tailor> createState() => _TailorState();
}

class _TailorState extends State<Tailor> {
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
                    userType: "tailor",
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
            appbarSubtitle: "Tailor",
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Choose Template \nTo Work On",
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
                      .where("processedStatus", isEqualTo: "processed")
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
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("orders")
                      .where("processedStatus", isEqualTo: "completed")
                      .where("tailor.id", isEqualTo: account.id)
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
                                    "Completed Orders",
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
              ],
            ),
          );
  }
}
