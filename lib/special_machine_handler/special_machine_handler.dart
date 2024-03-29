import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kindah/special_machine_handler/widgets/machine_handler_dods.dart';
import 'package:provider/provider.dart';

import '../Ads/ad_state.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../user_panel/widgets/user_custom_header.dart';
import '../widgets/custom_scrollbar.dart';
import '../widgets/custom_wrapper.dart';

class SpecialMachineHandler extends StatefulWidget {
  const SpecialMachineHandler({super.key});

  @override
  State<SpecialMachineHandler> createState() => _SpecialMachineHandlerState();
}

class _SpecialMachineHandlerState extends State<SpecialMachineHandler> {
  BannerAd? bannerAd;
  final ScrollController _controller = ScrollController();

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
    String preferedRole = context.watch<AccountProvider>().preferedRole;

    return CustomScrollBar(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const UserCustomHeader(
              action: [],
            ),
            MachineHandlerDataGrid(
                account: account, preferedRole: preferedRole),
            const Align(
              alignment: Alignment.topLeft,
              child: CustomWrapper(
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // const CardButton(
                      //     destinationUrl: "add_order",
                      //     title: "Add New Template"),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 10.0),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         "Recently Created Templates",
                      //         maxLines: 2,
                      //         style: Theme.of(context).textTheme.titleLarge,
                      //       ),
                      //       const SizedBox()
                      //     ],
                      //   ),
                      // ),
                      // StreamBuilder<QuerySnapshot>(
                      //   stream: FirebaseFirestore.instance
                      //       .collection("orders")
                      //       .where("publisher", isEqualTo: account.id)
                      //       // .where("processedStatus", isNotEqualTo: "finished")
                      //       .snapshots(),
                      //   builder: (context, snapshot) {
                      //     if (!snapshot.hasData) {
                      //       return circularProgress();
                      //     } else {
                      //       List<template.Order> orders = [];

                      //       snapshot.data!.docs.forEach((element) {
                      //         template.Order order =
                      //             template.Order.fromDocument(element);

                      //         orders.add(order);
                      //       });

                      //       if (orders.isEmpty) {
                      //         return const NoData(
                      //           title: "No Available Templates",
                      //         );
                      //       } else {
                      //         return Column(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: List.generate(orders.length, (index) {
                      //             template.Order order = orders[index];
                      //             bool isFinished =
                      //                 order.processedStatus == "finished";

                      //             return OrderDesign(
                      //               order: order,
                      //               isFinished: isFinished,
                      //             );
                      //           }),
                      //         );
                      //       }
                      //     }
                      //   },
                      // ),
                      // kIsWeb
                      //     ? const SizedBox(
                      //         height: 0.0,
                      //       )
                      //     : bannerAd != null
                      //         ? SizedBox(
                      //             height: 50.0,
                      //             child: AdWidget(ad: bannerAd!),
                      //           )
                      //         : const SizedBox(
                      //             height: 0.0,
                      //           ),
                      // StreamBuilder<QuerySnapshot>(
                      //   stream: FirebaseFirestore.instance
                      //       .collection("orders")
                      //       .where("processedStatus", isEqualTo: "finished")
                      //       .where("shopAttendant.id", isEqualTo: account.id)
                      //       .snapshots(),
                      //   builder: (context, snapshot) {
                      //     if (!snapshot.hasData) {
                      //       return circularProgress();
                      //     } else {
                      //       List<template.Order> orders = [];

                      //       snapshot.data!.docs.forEach((element) {
                      //         template.Order order =
                      //             template.Order.fromDocument(element);

                      //         orders.add(order);
                      //       });

                      //       if (orders.isEmpty) {
                      //         return Container();
                      //       } else {
                      //         return Column(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: [
                      //             Padding(
                      //               padding: const EdgeInsets.symmetric(
                      //                   vertical: 10.0),
                      //               child: Row(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.spaceBetween,
                      //                 children: [
                      //                   Text(
                      //                     "Orders Ready To Be Dispatched",
                      //                     maxLines: 2,
                      //                     style: Theme.of(context)
                      //                         .textTheme
                      //                         .titleLarge,
                      //                   ),
                      //                   const SizedBox()
                      //                 ],
                      //               ),
                      //             ),
                      //             Column(
                      //               mainAxisSize: MainAxisSize.min,
                      //               children:
                      //                   List.generate(orders.length, (index) {
                      //                 template.Order order = orders[index];

                      //                 return OrderDesign(
                      //                   order: order,
                      //                   isFinished: true,
                      //                 );
                      //               }),
                      //             ),
                      //           ],
                      //         );
                      //       }
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
