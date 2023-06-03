import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/product_order_design.dart';
import 'package:kindah/models/product_order.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../../POS/widgets/pos_custom_header.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/no_data.dart';
import '../widgets/custom_header.dart';
import '../widgets/dash_card.dart';

class Inventory extends StatefulWidget {
  final bool isAdmin;
  const Inventory({super.key, required this.isAdmin});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  Widget buildOrderListing(String type) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("product_orders")
          .where("deliveryStatus", isEqualTo: type)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<ProductOrder> productOrders = [];

          snapshot.data!.docs.forEach((element) {
            ProductOrder productOrder = ProductOrder.fromDocument(element);

            productOrders.add(productOrder);
          });

          if (productOrders.isEmpty) {
            return const NoData(
              title: "No Products",
              imageUrl: "assets/images/favourites.png",
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(productOrders.length, (index) {
                ProductOrder productOrder = productOrders[index];

                return ProductOrderDesign(
                    productOrder: productOrder, type: type);
              }),
            );
          }
        }
      },
    );
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
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("order_count")
                .doc("product_order_count")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                int pending = snapshot.data!["pending"];
                int delivered = snapshot.data!["delivered"];
                int shipping = snapshot.data!["shipping"];

                return Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20.0,
                        ),
                        DashCard(
                          backgroundColor: Colors.pink.shade800,
                          imageUrl: "assets/images/order.png",
                          pathTo: "",
                          count: pending,
                          title: "Pending Approval",
                        ),
                        DashCard(
                          backgroundColor: Colors.blue.shade700,
                          imageUrl: "assets/images/shipping.png",
                          pathTo: "",
                          count: shipping,
                          title: "Shipping",
                        ),
                        DashCard(
                          backgroundColor: Colors.purple.shade600,
                          imageUrl: "assets/images/delivered.png",
                          pathTo: "",
                          count: delivered,
                          title: "Delivered",
                        )
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          Align(
            alignment: Alignment.topLeft,
            child: CustomWrapper(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const POSCustomHeader(
                    action: [],
                    title: "Pending Approval",
                  ),
                  buildOrderListing("pending"),
                  const POSCustomHeader(
                    action: [],
                    title: "Shipping",
                  ),
                  buildOrderListing("shipping"),
                  const POSCustomHeader(
                    action: [],
                    title: "Delivered",
                  ),
                  buildOrderListing("delivered"),
                  const SizedBox(
                    height: 50.0,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
