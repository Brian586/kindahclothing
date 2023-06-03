import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/order_progress_indicator.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:kindah/user_panel/widgets/user_custom_header.dart';

import '../../POS/widgets/pos_custom_header.dart';
import '../../config.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/admin_order_design.dart';
import '../widgets/custom_header.dart';
import '../widgets/order_data_card.dart';
import '../widgets/orders_pie_chart.dart';

class OrderStatus extends StatefulWidget {
  final bool isAdmin;
  const OrderStatus({super.key, required this.isAdmin});

  @override
  State<OrderStatus> createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  String filter = "All";

  String getAppropriateFilter() {
    switch (filter) {
      case "Tailored":
        return "completed";
      case "Completed":
        return "finished";
      default:
        return filter.toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.isAdmin
              ? const CustomHeader(
                  action: [],
                )
              : const UserCustomHeader(
                  action: [],
                ),
          const Align(
              alignment: Alignment.topLeft,
              child: CustomWrapper(child: OrderDataCard())),
          const OrdersPieChart(),
          const GeneralOrderProgressIndicator(),
          POSCustomHeader(
            action: [
              PopupMenuButton<String>(
                offset: const Offset(0.0, 10.0),
                onSelected: (v) {
                  setState(() {
                    filter = v;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return [
                    "All",
                    "Not Processed",
                    "Processed",
                    "Tailored",
                    "Completed"
                  ].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          filter,
                          style: const TextStyle(color: Config.customGrey),
                        ),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Config.customGrey,
                          //size: 25.0,
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
            title: "Orders Listing",
          ),
          StreamBuilder<QuerySnapshot>(
            stream: filter == "All"
                ? FirebaseFirestore.instance.collection("orders").snapshots()
                : FirebaseFirestore.instance
                    .collection("orders")
                    .where("processedStatus", isEqualTo: getAppropriateFilter())
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<template.Order> orders = [];

                snapshot.data!.docs.forEach((element) {
                  template.Order order = template.Order.fromDocument(element);

                  orders.add(order);
                });

                if (orders.isEmpty) {
                  return const Text("No Available Templates");
                } else {
                  return CustomWrapper(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(orders.length, (index) {
                          template.Order order = orders[index];

                          return AdminOrderDesign(order: order);
                        }),
                      ),
                    ),
                  );
                }
              }
            },
          )
        ],
      ),
    );
  }
}
