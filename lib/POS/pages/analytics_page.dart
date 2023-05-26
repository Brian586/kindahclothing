import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/POS/models/invoice.dart';
import 'package:kindah/POS/widgets/invoice_data_card.dart';
import 'package:kindah/POS/widgets/pos_custom_header.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../widgets/pos_adaptive_ui.dart';
import '../widgets/pos_income_card.dart';

class AnalyticsPage extends StatefulWidget {
  final String userID;
  const AnalyticsPage({super.key, required this.userID});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return POSAdaptiveUI(
      userID: widget.userID,
      onBackPressed: () => context.go("/POS/${widget.userID}/home"),
      appbarTitle: "Insights",
      currentTab: "analytics",
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const POSCustomHeader(
                        title: "Analytics",
                        action: [],
                      ),
                      POSIncomeCard(invoices: invoices),
                      const SizedBox(
                        height: 10.0,
                      ),
                      InvoiceDataCard(invoices: invoices)
                    ],
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
