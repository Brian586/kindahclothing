import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/widgets/adaptive_ui.dart';

import '../../APIs/m_pesa.dart';
import '../../APIs/paypal.dart';
import '../../config.dart';
import '../../widgets/count_down_timer.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/progress_widget.dart';

class NFCPaymentScreen extends StatefulWidget {
  final double? totalAmount;
  final String page;
  final String data;
  const NFCPaymentScreen(
      {super.key, this.totalAmount, required this.page, required this.data});

  @override
  State<NFCPaymentScreen> createState() => _NFCPaymentScreenState();
}

class _NFCPaymentScreenState extends State<NFCPaymentScreen> {
  bool loading = false;
  bool paymentProcessing = false;
  TextEditingController phoneController = TextEditingController();

  void processMPesaTransaction() async {
    if (phoneController.text.isNotEmpty) {
      Navigator.pop(context);

      setState(() {
        paymentProcessing = true;
      });

      var res = await MPesa().processTransaction(
          amount: widget.totalAmount.toString(),
          phone: phoneController.text.trim());

      var actualResult = json.decode(res);

      if (actualResult != "failed") {
        var paymentInfo = json.encode(actualResult);

        Navigator.pop(context, paymentInfo);

        setState(() {
          paymentProcessing = false;
        });
      } else {
        setState(() {
          paymentProcessing = false;
        });

        Fluttertoast.showToast(msg: "An ERROR Occured");

        Navigator.pop(context, "cancelled");
      }
    } else {
      Fluttertoast.showToast(msg: "Phone Number needed");
    }
  }

  void processPaypalTransaction() async {
    if (phoneController.text.isNotEmpty) {
      Navigator.pop(context);

      setState(() {
        paymentProcessing = true;
      });

      var res = "";

      switch (widget.page) {
        case "pos_cart":
          res = await PayPal().posPayment(
              widget.data, widget.totalAmount!, phoneController.text.trim());
          break;
        case "ecommerce":
          res = await PayPal().ecommercePayment(
              widget.data, widget.totalAmount!, phoneController.text.trim());
          break;
        case "uniform":
          res = await PayPal().uniformPayment(
              widget.data, widget.totalAmount!, phoneController.text.trim());
          break;
      }

      if (res != "failed" && res != "") {
        var actualResult = json.decode(res);

        var paymentInfo = json.encode(actualResult);

        Navigator.pop(context, paymentInfo);

        setState(() {
          paymentProcessing = false;
        });
      } else {
        setState(() {
          paymentProcessing = false;
        });

        Fluttertoast.showToast(msg: "An ERROR Occured");

        Navigator.pop(context, "cancelled");
      }
    } else {
      Fluttertoast.showToast(msg: "Phone Number needed");
    }
  }

  promptPaypalPayment() {
    showDialog(
      context: context,
      builder: (ctx) {
        return CustomPopup(
          title: "Client's Phone",
          onAccepted: () => processPaypalTransaction(),
          acceptTitle: "PROCEED",
          onCancel: () {
            setState(() {
              phoneController.clear();
            });

            this.setState(() {});

            Navigator.pop(context);
          },
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: phoneController,
                hintText: "2547XXXX",
                title: "Phone Number",
                inputType: TextInputType.phone,
              ),
            ],
          ),
        );
      },
    );
  }

  void promptMPesaPayment() {
    showDialog(
      context: context,
      builder: (ctx) {
        return CustomPopup(
          title: "Your Phone",
          onAccepted: () => processMPesaTransaction(),
          acceptTitle: "PROCEED",
          onCancel: () {
            setState(() {
              phoneController.clear();
            });

            this.setState(() {});

            Navigator.pop(context);
          },
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: phoneController,
                hintText: "2547XXXX",
                title: "Phone Number",
                inputType: TextInputType.phone,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget processingPaymentDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        circularProgress(),
        const SizedBox(
          height: 10.0,
        ),
        CountdownTimer(isStart: paymentProcessing),
        const SizedBox(
          height: 10.0,
        ),
        const Text(
          "Keep this window open as we process your payment...",
          textAlign: TextAlign.center,
          style: TextStyle(color: Config.customGrey),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return EcommAdaptiveUI(
      appbarTitle: "Payment",
      onBackPressed: () => Navigator.pop(context, "failed"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: paymentProcessing
              ? processingPaymentDisplay()
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/payment.jpg",
                        width: 200.0,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        "Amount Payable: Ksh ${widget.totalAmount}",
                        style: const TextStyle(color: Config.customBlue),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      const Text(
                        "Choose Payment Method",
                        style: TextStyle(
                            color: Config.customGrey,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      InkWell(
                        onTap: () => promptPaypalPayment(),
                        child: Image.asset(
                          "assets/images/paypal.png",
                          width: 150.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      InkWell(
                        onTap: () => promptMPesaPayment(),
                        child: Image.asset(
                          "assets/images/mpesa.png",
                          width: 150.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
