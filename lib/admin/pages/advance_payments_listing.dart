import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/advance_list_item.dart';
import 'package:kindah/common_functions/update_done_orders.dart';
import 'package:kindah/models/advance_payment.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';

import '../../config.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/add_advance.dart';
import '../widgets/custom_header.dart';

class AdvancePaymentsListing extends StatefulWidget {
  final bool isAdmin;
  const AdvancePaymentsListing({super.key, required this.isAdmin});

  @override
  State<AdvancePaymentsListing> createState() => _AdvancePaymentsListingState();
}

class _AdvancePaymentsListingState extends State<AdvancePaymentsListing> {
  bool addAdvance = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.isAdmin
              ? CustomHeader(
                  action: [
                    addAdvance
                        ? TextButton.icon(
                            onPressed: () {
                              setState(() {
                                addAdvance = false;
                              });
                            },
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Config.customGrey,
                            ),
                            label: const Text(
                              "Close",
                              style: TextStyle(color: Config.customGrey),
                            ))
                        : CustomButton(
                            title: "Add Advance Payment",
                            iconData: Icons.add,
                            height: 30.0,
                            onPressed: () {
                              setState(() {
                                addAdvance = true;
                              });
                            },
                          )
                  ],
                )
              : UserCustomHeader(
                  action: [
                    addAdvance
                        ? TextButton.icon(
                            onPressed: () {
                              setState(() {
                                addAdvance = false;
                              });
                            },
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Config.customGrey,
                            ),
                            label: const Text(
                              "Close",
                              style: TextStyle(color: Config.customGrey),
                            ))
                        : CustomButton(
                            title: "Add Advance Payment",
                            iconData: Icons.add,
                            height: 30.0,
                            onPressed: () {
                              setState(() {
                                addAdvance = true;
                              });
                            },
                          )
                  ],
                ),
          addAdvance ? const AddAdvance() : const SizedBox(),
          Align(
            alignment: Alignment.topLeft,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("advance_payments")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                } else {
                  List<AdvancePayment> advancePayments = [];

                  snapshot.data!.docs.forEach((element) {
                    AdvancePayment payment =
                        AdvancePayment.fromDocument(element);

                    advancePayments.add(payment);
                  });

                  if (advancePayments.isEmpty) {
                    return const Center(
                      child: Text("No Payments Available"),
                    );
                  } else {
                    return CustomWrapper(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            List.generate(advancePayments.length, (index) {
                          AdvancePayment payment = advancePayments[index];

                          return AdvanceListItem(
                            advancePayment: payment,
                          );
                        }),
                      ),
                    );
                  }
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
