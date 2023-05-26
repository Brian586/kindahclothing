import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/user_payment.dart';

import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';

class PaymentsListing extends StatefulWidget {
  const PaymentsListing({super.key});

  @override
  State<PaymentsListing> createState() => _PaymentsListingState();
}

class _PaymentsListingState extends State<PaymentsListing> {
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
                  return CustomWrapper(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(payments.length, (index) {
                        UserPayment payment = payments[index];
                        bool isAdvance = payment.paymentType == "advance";

                        return ExpansionTile(
                          leading: const Icon(
                            Icons.payment_rounded,
                            color: Config.customGrey,
                          ),
                          title: Text(payment.id!),
                          subtitle: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Paid on: ${DateFormat("HH:mm a - dd, MMM").format(DateTime.fromMillisecondsSinceEpoch(payment.timestamp!))}",
                                style: const TextStyle(fontSize: 12.0),
                              ),
                              Text(
                                  "Paid To: ${payment.user!["username"]}, ${payment.user!["userRole"].split("_").join(" ")}.")
                            ],
                          ),
                          trailing: Text(
                            "Ksh ${payment.amount.toString()}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAdvance ? Colors.red : Colors.green),
                          ),
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
