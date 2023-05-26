import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/widgets/adaptive_ui.dart';

class PaypalSuccess extends StatefulWidget {
  final String payerID;
  final String paymentID;
  final String contact;
  final String timestamp;
  const PaypalSuccess(
      {super.key,
      required this.payerID,
      required this.paymentID,
      required this.contact,
      required this.timestamp});

  @override
  State<PaypalSuccess> createState() => _PaypalSuccessState();
}

class _PaypalSuccessState extends State<PaypalSuccess> {
  @override
  Widget build(BuildContext context) {
    return EcommAdaptiveUI(
      appbarTitle: "Paypal Payment",
      onBackPressed: () => context.go("/home"),
      body: Column(
        children: [
          Text(widget.payerID),
          Text(widget.contact),
          Text(widget.paymentID),
          Text(widget.timestamp)
        ],
      ),
    );
  }
}
