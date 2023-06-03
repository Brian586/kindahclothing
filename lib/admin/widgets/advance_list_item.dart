import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/models/advance_payment.dart';

import '../../config.dart';

class AdvanceListItem extends StatefulWidget {
  final AdvancePayment? advancePayment;
  const AdvanceListItem({super.key, this.advancePayment});

  @override
  State<AdvanceListItem> createState() => _AdvanceListItemState();
}

class _AdvanceListItemState extends State<AdvanceListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: ExpansionTile(
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
            )
          ],
        ),
        trailing: Text(
          "Ksh ${widget.advancePayment!.amount.toString()}",
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ),
    );
  }
}
