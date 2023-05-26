import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/admin_order_design.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:kindah/models/order.dart' as template;

import '../widgets/custom_header.dart';

class OrdersListing extends StatefulWidget {
  const OrdersListing({super.key});

  @override
  State<OrdersListing> createState() => _OrdersListingState();
}

class _OrdersListingState extends State<OrdersListing> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomHeader(
            action: [],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("orders").snapshots(),
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
