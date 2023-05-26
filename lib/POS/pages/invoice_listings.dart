import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kindah/POS/models/invoice.dart';
import 'package:kindah/POS/widgets/pos_adaptive_ui.dart';
import 'package:kindah/POS/widgets/pos_custom_header.dart';
import 'package:kindah/config.dart';
import 'package:kindah/widgets/no_data.dart';
import 'package:kindah/widgets/progress_widget.dart';

class InvoiceListings extends StatefulWidget {
  final String userID;
  const InvoiceListings({super.key, required this.userID});

  @override
  State<InvoiceListings> createState() => _InvoiceListingsState();
}

class _InvoiceListingsState extends State<InvoiceListings> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return POSAdaptiveUI(
      userID: widget.userID,
      onBackPressed: () => context.go("/POS/${widget.userID}/home"),
      appbarTitle: "Orders",
      currentTab: "orders",
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const POSCustomHeader(
              title: "Recent Orders",
              action: [],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("POS_users")
                  .doc(widget.userID)
                  .collection("product_orders")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                } else {
                  List<Invoice> invoices = [];

                  snapshot.data!.docs.forEach((element) {
                    Invoice invoice = Invoice.fromDocument(element);

                    invoices.add(invoice);
                  });

                  if (invoices.isEmpty) {
                    return const NoData(
                      title: "No Orders Here",
                      imageUrl: "assets/images/favourites.png",
                    );
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(invoices.length, (index) {
                        Invoice invoice = invoices[index];

                        return ListTile(
                          title: Text(
                            invoice.id!,
                            style: const TextStyle(color: Config.customBlue),
                          ),
                          subtitle: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Created: ${DateFormat("HH:mm a - dd, MMM").format(DateTime.fromMillisecondsSinceEpoch(invoice.timestamp!))}"),
                              Text("Amount Paid (Ksh): ${invoice.totalAmount}"),
                              Text(
                                  "Products Ordered: ${invoice.products!.length}"),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Client Phone: +${invoice.paymentInfo!["contact"]}",
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                              Container(
                                height: 0.5,
                                width: size.width,
                                color: Config.customGrey.withOpacity(0.3),
                              )
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              DocumentSnapshot documentSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection("POS_users")
                                      .doc(widget.userID)
                                      .collection("product_orders")
                                      .doc(invoice.id)
                                      .get();

                              await documentSnapshot.reference.delete();

                              DocumentSnapshot doc = await FirebaseFirestore
                                  .instance
                                  .collection("POS_users")
                                  .doc(widget.userID)
                                  .get();

                              int orderCount = doc["order_count"];

                              await FirebaseFirestore.instance
                                  .collection("POS_users")
                                  .doc(widget.userID)
                                  .update({
                                "order_count": orderCount - 1,
                              });
                            },
                            icon: const Icon(
                              Icons.delete_outlined,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }),
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
