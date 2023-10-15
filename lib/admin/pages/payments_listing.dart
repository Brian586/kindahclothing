import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/models/user_payment.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';

import '../../widgets/custom_scrollbar.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';
import '../widgets/payment_list_item.dart';

class PaymentsListing extends StatefulWidget {
  final bool isAdmin;
  const PaymentsListing({super.key, required this.isAdmin});

  @override
  State<PaymentsListing> createState() => _PaymentsListingState();
}

class _PaymentsListingState extends State<PaymentsListing> {
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
                ? const CustomHeader(
                    action: [],
                  )
                : const UserCustomHeader(
                    action: [],
                  ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("user_payments")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                } else {
                  List<UserPayment> payments = [];

                  snapshot.data!.docs.forEach((element) {
                    UserPayment payment = UserPayment.fromDocument(element);

                    payments.add(payment);
                  });

                  if (payments.isEmpty) {
                    return const Center(
                      child: Text("No Payments Available"),
                    );
                  } else {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: CustomWrapper(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(payments.length, (index) {
                            UserPayment payment = payments[index];

                            return PaymentListItem(
                              payment: payment,
                            );
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
      ),
    );
  }
}
