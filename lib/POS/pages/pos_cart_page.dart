import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/POS/models/invoice.dart';
import 'package:kindah/POS/models/pos_product.dart';
import 'package:kindah/POS/models/pos_user.dart';
import 'package:kindah/POS/widgets/cart_list_card.dart';
import 'package:kindah/config.dart';
import 'package:kindah/widgets/ecomm_appbar.dart';
import 'package:kindah/widgets/no_data.dart';
import 'package:provider/provider.dart';

import '../../pages/payment_screen.dart';
import '../../pages/payment_successful.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/progress_widget.dart';

class POSCartPage extends StatefulWidget {
  final String userID;
  final bool isDesktop;
  const POSCartPage({super.key, required this.userID, required this.isDesktop});

  @override
  State<POSCartPage> createState() => _POSCartPageState();
}

class _POSCartPageState extends State<POSCartPage> {
  bool loading = false;

  void proceedToCheckout(double totalAmount, List<POSProduct> products) async {
    try {
      String data = POSProduct.encode(products);
      // Display payment screen

      String result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentScreen(
                    totalAmount: totalAmount,
                    data: data,
                    page: "pos_cart",
                  )));

      var res = json.decode(result);

      if (res != "cancelled") {
        setState(() {
          loading = true;
        });

        //Map<String, dynamic> paymentInfo = json.decode(result);

        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("POS_users")
            .doc(widget.userID)
            .get();

        POSUser user = POSUser.fromDocument(documentSnapshot);

        int count = user.orderCount!;

        String invoiceID =
            "InvoiceID_${(count + 1).toString().padLeft(6, "0")}";

        Invoice invoice = Invoice(
          id: invoiceID,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          totalAmount: totalAmount,
          store: user.storeID,
          posOperator: user.toMap(),
          paymentInfo: res,
          products:
              List.generate(products.length, (index) => products[index].id),
        );

        await FirebaseFirestore.instance
            .collection("POS_users")
            .doc(user.userID)
            .collection("product_orders")
            .doc(invoice.id)
            .set(invoice.toMap());

        await FirebaseFirestore.instance
            .collection("POS_users")
            .doc(widget.userID)
            .update({
          "order_count": count + 1,
        });

        await FirebaseFirestore.instance
            .collection("POS_users")
            .doc(widget.userID)
            .collection("cart")
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });

        Fluttertoast.showToast(msg: "Order Placed Successfully!");

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PaymentSuccessful(
                      text: "Payment Successful!",
                    )));

        await Provider.of<ProductProvider>(context, listen: false)
            .clearPOSCartList();

        if (!widget.isDesktop) {
          GoRouter.of(context).go("/POS/${widget.userID}/home");
        }

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "An ERROR Occurred :(");
      setState(() {
        loading = false;
      });
    }
  }

  Widget buildCosts(double totalAmount) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Config.customGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Subtotal",
                    style: TextStyle(
                      color: Config.customGrey,
                    ),
                  ),
                  Text(
                    "Ksh $totalAmount",
                    style: const TextStyle(
                      color: Config.customGrey,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Discount Sales",
                    style: TextStyle(
                      color: Config.customGrey,
                    ),
                  ),
                  Text(
                    "Ksh 0.00",
                    style: TextStyle(
                      color: Config.customGrey,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Total Sales Tax:",
                    style: TextStyle(
                      color: Config.customGrey,
                    ),
                  ),
                  Text(
                    "Ksh 0.00",
                    style: TextStyle(
                      color: Config.customGrey,
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: Config.customGrey,
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Amount:",
                    style: TextStyle(
                        color: Config.customGrey, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    "Ksh $totalAmount",
                    style: const TextStyle(
                        color: Config.customGrey, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    return loading
        ? circularProgress()
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("POS_users")
                .doc(widget.userID)
                .collection("cart")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                double totalAmount = 0.0;
                List<POSProduct> products = [];

                snapshot.data!.docs.forEach((element) async {
                  POSProduct product = POSProduct.fromDocument(element);
                  products.add(product);
                  totalAmount =
                      totalAmount + (product.price! * product.quantity!);
                });

                return products.isEmpty
                    ? const NoData(
                        title: "No Products Here",
                        imageUrl: "assets/images/favourites.png",
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              children: List.generate(products.length, (index) {
                                POSProduct product = products[index];

                                return CartListCard(
                                    product: product, userID: widget.userID);
                              }),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(0.0, 3.0),
                                      spreadRadius: 6.0,
                                      blurRadius: 6.0,
                                      color: Config.customGrey.withOpacity(0.3))
                                ]),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildCosts(totalAmount.round().toDouble()),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                CustomButton(
                                  onPressed: () {
                                    if (totalAmount > 0) {
                                      proceedToCheckout(
                                          totalAmount.round().toDouble(),
                                          products);
                                    }
                                  },
                                  title: "Continue To Payment",
                                  iconData: Icons.shopping_bag_rounded,
                                ),
                                const SizedBox(
                                  height: 20.0,
                                )
                              ],
                            ),
                          )
                        ],
                      );
              }
            },
          );
  }

  Widget buildMobile(BuildContext context, Size size) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(size.width, kToolbarHeight),
        child: EcommGeneralAppbar(
          onBackPressed: () => context.go("/POS/${widget.userID}/home"),
          title: "Current Order",
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildDesktop(BuildContext context, Size size) {
    return Column(
      children: [
        const SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Current Order",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .apply(color: Config.customGrey),
              ),
              const SizedBox()
            ],
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Expanded(
          child: buildBody(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // List<String> cartList = context.watch<ProductProvider>().posCartList;

    return widget.isDesktop
        ? buildDesktop(context, size)
        : buildMobile(context, size);
  }
}
