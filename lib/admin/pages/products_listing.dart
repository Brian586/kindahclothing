import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/models/admin.dart';
import 'package:kindah/models/product.dart';
import 'package:kindah/providers/admin_provider.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_header.dart';
import '../widgets/product_listing_item.dart';

class ProductsListing extends StatefulWidget {
  const ProductsListing({super.key});

  @override
  State<ProductsListing> createState() => _ProductsListingState();
}

class _ProductsListingState extends State<ProductsListing> {
  @override
  Widget build(BuildContext context) {
    Admin admin = context.watch<AdminProvider>().admin;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomHeader(
            action: [
              CustomButton(
                title: "Add Product",
                iconData: Icons.add,
                height: 30.0,
                onPressed: () {
                  context
                      .read<AdminProvider>()
                      .changeDrawerItem("add_products");

                  context.go("/admin/${admin.id}/add_products");
                },
              )
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("products")
                .where("publisher", isEqualTo: admin.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<Product> products = [];

                snapshot.data!.docs.forEach((element) {
                  Product product = Product.fromDocument(element);

                  products.add(product);
                });

                if (products.isEmpty) {
                  return const Center(
                    child: Text("No Products Available"),
                  );
                } else {
                  return CustomWrapper(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(products.length, (index) {
                        Product product = products[index];

                        return ProductListingItem(
                          product: product,
                          editing: false,
                        );
                      }),
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
