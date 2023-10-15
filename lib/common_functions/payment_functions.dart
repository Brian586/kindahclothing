import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/advance_payment.dart';
import '../widgets/custom_popup.dart';
import '../widgets/custom_tag.dart';
import 'ordinal_getter.dart';

Future<String> promptClearAdvancePayments(
    BuildContext context, List<AdvancePayment> advancePayments) async {
  // First we need to know which installment is being paid
  int paidCount = advancePayments[0].paidInstallments!.length;
  int numberOfInstallments = advancePayments[0].installmentCount!;
  double installmentAmount = advancePayments[0].amount! / numberOfInstallments;
  int currentInstallment = paidCount + 1;
  Map<String, dynamic> user = advancePayments[0].user!;

  String res = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return CustomPopup(
          title: "Clear Advance",
          onAccepted: () => Navigator.pop(context, "proceed"),
          onCancel: () => Navigator.pop(context, "cancelled"),
          acceptTitle: "Proceed",
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "Do you wish to clear $currentInstallment${ordinal(currentInstallment, 100)} advance installment of Ksh $installmentAmount for ${user["username"]}?"),
              CustomTag(
                title: "Amount: Ksh $installmentAmount",
                color: Colors.deepOrange,
              )
            ],
          ),
        );
      });

  if (res == "proceed") {
    bool isCleared = advancePayments[0].paidInstallments!.length + 1 ==
        advancePayments[0].installmentCount;

    bool isPartial = !isCleared;

    // User has paid last installment so advance has been cleared
    await clearAdvancePayment(isPartial, installmentAmount, user["id"]);

    await Fluttertoast.showToast(msg: "Advance Installment paid successfully!");

    return "success";
  } else {
    Fluttertoast.showToast(msg: "Cancelled");

    return "cancelled";
  }
}

Future<void> clearAdvancePayment(
    bool isPartial, double amount, String userID) async {
  // Clear for User
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userID)
      .collection("advance_payments")
      .where("status", isEqualTo: "pending")
      .get()
      .then((querySnapshot) async {
    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.forEach((element) async {
        await element.reference.update({
          "status": isPartial ? "pending" : "cleared",
          "paidInstallments":
              FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch])
        });
      });
    }
  });

  // Clear globally
  await FirebaseFirestore.instance
      .collection("advance_payments")
      .where("user.id", isEqualTo: userID)
      .where("status", isEqualTo: "pending")
      .get()
      .then((querySnapshot) async {
    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.forEach((element) async {
        await element.reference.update({
          "status": isPartial ? "pending" : "cleared",
          "paidInstallments":
              FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch])
        });
      });
    }
  });
}
