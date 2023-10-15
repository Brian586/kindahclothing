import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/models/advance_payment.dart';
import 'package:kindah/widgets/custom_tag.dart';

import '../../common_functions/ordinal_getter.dart';
import '../../common_functions/payment_functions.dart';
import '../../config.dart';

class AdvanceListItem extends StatefulWidget {
  final AdvancePayment? advancePayment;
  const AdvanceListItem({super.key, this.advancePayment});

  @override
  State<AdvanceListItem> createState() => _AdvanceListItemState();
}

class _AdvanceListItemState extends State<AdvanceListItem> {
  bool clearAdvance = false;

  @override
  void initState() {
    super.initState();

    checkForMissedInstallments();
  }

  int getPeriodInMilliseconds() {
    switch (widget.advancePayment!.installmentPeriod) {
      case "Daily":
        return 8.64e+7.toInt();
      case "Weekly":
        return 6.048e+8.toInt();
      case "Every Fortnight":
        return 1.21e+9.toInt();
      case "Monthly":
        return 2.628e+9.toInt();
      case "Every 3 Months":
        return 7.884e+9.toInt();
      case "Every 6 Months":
        return 1.577e+10.toInt();
      case "Yearly":
        return 3.154e+10.toInt();
      default:
        return 0;
    }
  }

  int myLargestNumber(List<dynamic> numbers) {
    return numbers
        .reduce((value, element) => value > element ? value : element);
  }

  Future<void> checkForMissedInstallments() async {
    List<dynamic> selectedNumbers = [];

    List<dynamic> paidInstallments = widget.advancePayment!.paidInstallments!;
    List<dynamic> missedInstallments =
        widget.advancePayment!.missedInstallments!;
    int timestamp = widget.advancePayment!.timestamp!;

    // Look for the largest number
    if (paidInstallments.isNotEmpty) {
      int latestPaidInstallment = myLargestNumber(paidInstallments);
      selectedNumbers.add(latestPaidInstallment);
    }

    if (missedInstallments.isNotEmpty) {
      int latestMissedInstallment = myLargestNumber(missedInstallments);
      selectedNumbers.add(latestMissedInstallment);
    }

    selectedNumbers.add(timestamp);

    int largestTimestamp = myLargestNumber(selectedNumbers);

    int nowTimestamp = DateTime.now().millisecondsSinceEpoch;
    // Get period the advance has been active (Since the last payment or last miss)
    int difference = nowTimestamp - largestTimestamp;

    int periodDifference = difference - getPeriodInMilliseconds();

    int dueDate = largestTimestamp + getPeriodInMilliseconds();

    // If the "periodDifference" is +ve then add a missed payment
    if (periodDifference > 0) {
      // Update for User
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.advancePayment!.user!["id"])
          .collection("advance_payments")
          .doc(widget.advancePayment!.id)
          .update({
        "missedInstallments": FieldValue.arrayUnion([dueDate])
      });

      // Clear globally
      await FirebaseFirestore.instance
          .collection("advance_payments")
          .doc(widget.advancePayment!.id)
          .update({
        "missedInstallments": FieldValue.arrayUnion([dueDate])
      });
    }
  }

  Widget listPayments(
      List<dynamic> payments, double installmentAmount, bool isPaid) {
    return payments.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPaid ? "Paid Installments" : "Missed Installments",
                style: Theme.of(context).textTheme.headlineSmall!.apply(
                    color: Config.customGrey, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(payments.length, (index) {
                  return ListTile(
                    tileColor: isPaid
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    title: Text(
                        "${(index + 1)}${ordinal((index + 1), 100)} Installment"),
                    subtitle: Text(DateFormat("HH:mm a - dd, MMM").format(
                        DateTime.fromMillisecondsSinceEpoch(payments[index]))),
                    trailing: Text(
                      "Ksh $installmentAmount",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isPaid ? Colors.green : Colors.red),
                    ),
                  );
                }),
              ),
            ],
          )
        : const SizedBox();
  }

  Widget displayCount(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          count.toString(),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .apply(color: Config.customGrey, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  void proceedToClearAdvance() async {
    setState(() {
      clearAdvance = true;
    });

    await promptClearAdvancePayments(context, [widget.advancePayment!]);

    setState(() {
      clearAdvance = false;
    });
  }

  Widget getTheNextDueDate() {
    List<dynamic> selectedNumbers = [];

    List<dynamic> paidInstallments = widget.advancePayment!.paidInstallments!;
    List<dynamic> missedInstallments =
        widget.advancePayment!.missedInstallments!;
    int timestamp = widget.advancePayment!.timestamp!;

    // Look for the largest number
    if (paidInstallments.isNotEmpty) {
      int latestPaidInstallment = myLargestNumber(paidInstallments);
      selectedNumbers.add(latestPaidInstallment);
    }

    if (missedInstallments.isNotEmpty) {
      int latestMissedInstallment = myLargestNumber(missedInstallments);
      selectedNumbers.add(latestMissedInstallment);
    }

    selectedNumbers.add(timestamp);

    int largestTimestamp = myLargestNumber(selectedNumbers);

    int dueDate = largestTimestamp + getPeriodInMilliseconds();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Due Date for the next Installment"),
        Text(DateFormat("HH:mm a - dd, MMM")
            .format(DateTime.fromMillisecondsSinceEpoch(dueDate))),
        const SizedBox(
          height: 10.0,
        ),
        InkWell(
          onTap: () => proceedToClearAdvance(),
          child: const CustomTag(
            title: "Clear Installment",
            color: Colors.green,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCleared = widget.advancePayment!.status == "cleared";
    String installmentPeriod = widget.advancePayment!.installmentPeriod!;
    int installmentCount = widget.advancePayment!.installmentCount!;
    double installmentAmount =
        widget.advancePayment!.amount! / installmentCount;
    int missedInstallmentsCount =
        widget.advancePayment!.missedInstallments!.length;
    int paidInstallmentsCount = widget.advancePayment!.paidInstallments!.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Card(
        child: ExpansionTile(
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.all(10.0),
          leading: const Icon(
            Icons.payment_rounded,
            color: Config.customGrey,
          ),
          title: Text(
            "PayID: ${widget.advancePayment!.id!}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Paid on: ${DateFormat("HH:mm a - dd, MMM").format(DateTime.fromMillisecondsSinceEpoch(widget.advancePayment!.timestamp!))}",
                style: const TextStyle(fontSize: 12.0),
              ),
              Text(
                "Paid To: ${widget.advancePayment!.user!["username"]}, ${widget.advancePayment!.user!["userRole"].split("_").join(" ")}.",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              CustomTag(
                title: widget.advancePayment!.status,
                color: isCleared ? Colors.green : Colors.red,
              )
            ],
          ),
          trailing: Text(
            "Ksh ${widget.advancePayment!.amount.toString()}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCleared ? Colors.green : Colors.red),
          ),
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Installment period: $installmentPeriod",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Number of Installments: $installmentCount",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                CustomTag(
                  title: "Amount: Ksh $installmentAmount",
                  color: Colors.deepOrange,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                widget.advancePayment!.status == "pending"
                    ? getTheNextDueDate()
                    : const SizedBox(),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 1,
                  child:
                      displayCount("Paid Installments", paidInstallmentsCount),
                ),
                Expanded(
                  flex: 1,
                  child: displayCount(
                      "Missed Installments", missedInstallmentsCount),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                )
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            listPayments(widget.advancePayment!.paidInstallments!,
                installmentAmount, true),
            const SizedBox(
              height: 10.0,
            ),
            listPayments(widget.advancePayment!.missedInstallments!,
                installmentAmount, false)
          ],
        ),
      ),
    );
  }
}
