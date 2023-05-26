import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kindah/widgets/adaptive_ui.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../Ads/ad_state.dart';
import '../models/product.dart';
import '../models/product_order.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/progress_widget.dart';
import 'payment_screen.dart';
import 'payment_successful.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool loading = false;
  BannerAd? bannerAd;

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

  void proceedToCheckout(double totalAmount, List<Product> products) async {
    try {
      String data = Product.encode(products);
      // Display payment screen

      String result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentScreen(
                    totalAmount: totalAmount,
                    data: data,
                    page: 'ecommerce',
                  )));

      if (result != "cancelled") {
        setState(() {
          loading = true;
        });

        Map<String, dynamic> paymentInfo = json.decode(result);

        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("order_count")
            .doc("product_order_count")
            .get();

        int count = documentSnapshot["count"];

        int pending = documentSnapshot["pending"];

        String orderID = "OrderID_${(count + 1).toString().padLeft(6, "0")}";

        ProductOrder productOrder = ProductOrder(
            id: orderID,
            title: orderID,
            paidAmount: totalAmount,
            deliveryStatus: "pending",
            shippingStatus: "not shipping",
            paidStatus: "paid",
            orderedProducts: products.map((e) => e.id).toList(),
            timestamp: DateTime.now().millisecondsSinceEpoch,
            paymentInfo: paymentInfo);

        await FirebaseFirestore.instance
            .collection("product_orders")
            .doc(productOrder.id)
            .set(productOrder.toMap());

        await FirebaseFirestore.instance
            .collection("order_count")
            .doc("product_order_count")
            .update({"count": count + 1, "pending": pending + 1});

        Fluttertoast.showToast(msg: "Order Placed Successfully!");

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PaymentSuccessful(
                      text: "Payment Successful!",
                    )));

        await Provider.of<ProductProvider>(context, listen: false)
            .clearCartList();

        GoRouter.of(context).go("/home");

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "An ERROR Occurred :(");
    }
  }

  @override
  Widget build(BuildContext context) {
    return EcommAdaptiveUI(
      appbarTitle: "Cart List",
      onBackPressed: () => context.go("/home"),
      body: loading
          ? circularProgress()
          : FutureBuilder<List<Product>>(
              future: ProductProvider().getProductCart(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                } else {
                  List<Product> products = snapshot.data!;

                  double totalAmount = 0.0;

                  products.forEach(
                    (prod) {
                      totalAmount =
                          totalAmount + (prod.price! * prod.quantity!);
                    },
                  );

                  return products.isEmpty
                      ? const Text("No Product Available")
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: List.generate(products.length, (index) {
                                Product product = products[index];

                                return ProductListCard(
                                  product: product,
                                );
                              }),
                            ),
                            const SizedBox(
                              height: 10.0,
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
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              "Total Amount: \nKsh $totalAmount",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            CustomButton(
                              onPressed: () {
                                if (totalAmount > 0) {
                                  proceedToCheckout(totalAmount, products);
                                }
                              },
                              title: "Checkout",
                              iconData: Icons.shopping_bag_rounded,
                            )
                          ],
                        );
                }
              },
            ),
    );
  }
}
