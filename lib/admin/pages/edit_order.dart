import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/edit_order_design.dart';
import 'package:kindah/models/order.dart' as template;

import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';

class EditOrder extends StatefulWidget {
  const EditOrder({super.key});

  @override
  State<EditOrder> createState() => _EditOrderState();
}

class _EditOrderState extends State<EditOrder> {
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

                          return EditOrderDesign(order: order);
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
