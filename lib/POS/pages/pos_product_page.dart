import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/POS/models/pos_product.dart';
import 'package:kindah/POS/models/pos_user.dart';
import 'package:kindah/POS/responsive.dart';
import 'package:kindah/POS/widgets/pos_product_card.dart';
import 'package:kindah/config.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../APIs/request_assistant.dart';
import '../../widgets/no_data.dart';
import '../widgets/pos_category_button.dart';

class POSProductPage extends StatefulWidget {
  final String userID;
  const POSProductPage({super.key, required this.userID});

  @override
  State<POSProductPage> createState() => _POSProductPageState();
}

class _POSProductPageState extends State<POSProductPage> {
  Widget buildCategories(BuildContext context, String selectedCategory) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("POS_users")
          .doc(widget.userID)
          .collection("categories")
          .doc("categories")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text(
            "Loading Categories",
            style: TextStyle(color: Colors.white54),
          );
        } else {
          List<dynamic> categories = snapshot.data!["cat"];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(categories.length, (index) {
                // bool isSelected = categories[index] == selectedCategory;

                return POSCategoryButton(
                  category: categories[index],
                );
              }),
            ),
          );
        }
      },
    );
  }

  Widget buildDesktop(List<POSProduct> products) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2 / 3,
      children: List.generate(products.length, (index) {
        POSProduct product = products[index];

        return POSProductCard(
          product: product,
          isDesktop: true,
          userID: widget.userID,
        );
      }),
    );
  }

  Widget buildMobile(List<POSProduct> products) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2 / 3,
      children: List.generate(products.length, (index) {
        POSProduct product = products[index];

        return POSProductCard(
          product: product,
          isDesktop: false,
          userID: widget.userID,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    String selectedCategory =
        context.watch<CategoryProvider>().selectedPOSCategory;
    Size size = MediaQuery.of(context).size;

    bool isAll = selectedCategory == "All";

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("POS_users")
          .doc(widget.userID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          POSUser user = POSUser.fromDocument(snapshot.data!);

          return Container(
            color: Config.customGrey.withOpacity(0.05),
            height: size.height,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        "Welcome, ${user.username}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      subtitle: const Text("Discover whatever you need easily"),
                    ),
                    buildCategories(context, selectedCategory),
                    const SizedBox(
                      height: 20.0,
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: isAll
                          ? FirebaseFirestore.instance
                              .collection("POS_products")
                              .where("publisher", isEqualTo: widget.userID)
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection("POS_products")
                              .where("category", isEqualTo: selectedCategory)
                              .where("publisher", isEqualTo: widget.userID)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return circularProgress();
                        } else {
                          List<POSProduct> products = [];

                          snapshot.data!.docs.forEach((prod) {
                            POSProduct product = POSProduct.fromDocument(prod);

                            products.add(product);
                          });

                          if (products.isEmpty) {
                            return const NoData(
                              title: "No Products Here",
                              imageUrl: "assets/images/favourites.png",
                            );
                          } else {
                            return Responsive.isMobile(context)
                                ? buildMobile(products)
                                : buildDesktop(products);
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
