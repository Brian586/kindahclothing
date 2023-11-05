import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kindah/APIs/m_pesa.dart';
import 'package:kindah/APIs/paypal.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/config.dart';
import 'package:kindah/widgets/count_down_timer.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/custom_popup.dart';
import 'package:kindah/widgets/ecomm_appbar.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../widgets/custom_textfield.dart';
import '../widgets/custom_wrapper.dart';
import '../widgets/progress_widget.dart';

class PaymentScreen extends StatefulWidget {
  final double? totalAmount;
  final String page;
  final String data;
  const PaymentScreen(
      {super.key, this.totalAmount, required this.page, required this.data});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool loading = false;
  bool paymentProcessing = false;
  TextEditingController phoneController = TextEditingController();
  String phoneNumber = "";

  void proceedBackToTemplate(Map<String, dynamic> map) {
    String jsonString = json.encode(map);

    Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context, jsonString);
  }

  void processCashPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return CustomPopup(
          title: "Client's Phone",
          onAccepted: () async {
            if (phoneNumber.isNotEmpty) {
              Navigator.pop(context);

              Map<String, dynamic> map = {
                "payment_method": "Cash",
                "status": "paid",
                "contact": phoneNumber.split("+").last.trim()
              };

              proceedBackToTemplate(map);
            } else {
              showCustomToast("Please fill the form");
            }
          },
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
              CustomPhoneField(
                controller: phoneController,
                onChanged: (phone) {
                  setState(() {
                    phoneNumber = phone.completeNumber;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void processMPesaTransaction() async {
    if (phoneNumber.isNotEmpty) {
      Navigator.pop(context);

      setState(() {
        paymentProcessing = true;
      });

      var res = await MPesa().processTransaction(
          amount: widget.totalAmount.toString(),
          phone: phoneNumber.split("+").last.trim());

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

        showCustomToast("An ERROR Occured");

        Navigator.pop(context, "cancelled");
      }
    } else {
      showCustomToast("Phone Number needed");
    }
  }

  void promptMPesaPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return CustomPopup(
          title: "Client's Phone",
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
              CustomPhoneField(
                controller: phoneController,
                onChanged: (phone) {
                  setState(() {
                    phoneNumber = phone.completeNumber;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void processPaypalTransaction() async {
    if (phoneNumber.isNotEmpty) {
      Navigator.pop(context);

      setState(() {
        paymentProcessing = true;
      });

      var res = "";

      switch (widget.page) {
        case "pos_cart":
          res = await PayPal().posPayment(widget.data, widget.totalAmount!,
              phoneNumber.split("+").last.trim());
          break;
        case "ecommerce":
          res = await PayPal().ecommercePayment(widget.data,
              widget.totalAmount!, phoneNumber.split("+").last.trim());
          break;
        case "uniform":
          res = await PayPal().uniformPayment(widget.data, widget.totalAmount!,
              phoneNumber.split("+").last.trim());
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

        showCustomToast("An ERROR Occured");

        Navigator.pop(context, "cancelled");
      }
    } else {
      showCustomToast("Phone Number needed");
    }
  }

  promptPaypalPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              CustomPhoneField(
                controller: phoneController,
                onChanged: (phone) {
                  setState(() {
                    phoneNumber = phone.completeNumber;
                  });
                },
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

  void processNFCPayment() async {
    String result = "failed";
    // String result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => NFCReceiver(
    //               totalAmount: widget.totalAmount!,
    //               page: widget.page,
    //               data: widget.data,
    //             )));

    if (result != "failed") {
      Navigator.pop(context, result);
    } else {
      showCustomToast("An ERROR Occurred :(");
    }
  }

  Widget buildBody(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: CustomWrapper(
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
                      CustomButton(
                        onPressed: () => processCashPayment(),
                        title: "Cash Payment",
                        iconData: Icons.payments_outlined,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      widget.page == "ecommerce"
                          ? const SizedBox(
                              height: 0.0,
                              width: 0.0,
                            )
                          : const SizedBox(
                              height: 0.0,
                              width: 0.0,
                            )
                      // : CustomButton(
                      //     onPressed: () => processNFCPayment(),
                      //     title: "NFC Payment",
                      //     iconData: Icons.payments_outlined,
                      //   )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildDesktop(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 4,
          child: Align(alignment: Alignment.topLeft, child: buildBody(context)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return loading
        ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: circularProgress(),
            ),
          )
        : ResponsiveBuilder(
            builder: (context, sizingInformation) {
              bool isMobile = sizingInformation.isMobile;

              return Scaffold(
                backgroundColor: Colors.white,
                appBar: PreferredSize(
                  preferredSize: Size(size.width, kToolbarHeight),
                  child: EcommGeneralAppbar(
                    onBackPressed: () => Navigator.pop(context, "cancelled"),
                    title: "Payment",
                  ),
                ),
                body: isMobile ? buildBody(context) : buildDesktop(context),
              );
            },
          );
  }
}
