import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:kindah/widgets/custom_scrollbar.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';
import '../widgets/product_listing_item.dart';

class EditProducts extends StatefulWidget {
  final bool isAdmin;
  const EditProducts({super.key, required this.isAdmin});

  @override
  State<EditProducts> createState() => _EditProductsState();
}

class _EditProductsState extends State<EditProducts> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return CustomScrollBar(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.isAdmin
                ? CustomHeader(
                    action: [
                      CustomButton(
                        title: "Add Product",
                        iconData: Icons.add,
                        height: 30.0,
                        onPressed: () {
                          context
                              .read<AdminProvider>()
                              .changeDrawerItem("add_products");

                          context.go("/admin/0001/add_products");
                        },
                      )
                    ],
                  )
                : const UserCustomHeader(
                    action: [],
                  ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("products")
                  .where("publisher", isEqualTo: "0001")
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
                            editing: true,
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
      ),
    );
  }
}
