import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kindah/models/advance_payment.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/models/user_payment.dart';
import 'package:kindah/widgets/custom_tag.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:responsive_builder/responsive_builder.dart';

import '../../config.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/custom_textfield.dart';

class PaymentListItem extends StatefulWidget {
  final UserPayment? payment;
  const PaymentListItem({super.key, this.payment});

  @override
  State<PaymentListItem> createState() => _PaymentListItemState();
}

class _PaymentListItemState extends State<PaymentListItem> {
  bool paying = false;
  bool clearAdvance = false;
  bool isExpanded = false;
  TextEditingController advanceController = TextEditingController();

  String filterUserRole() {
    switch (widget.payment!.user!["userRole"]) {
      case "shop_attendant":
        return "Shop Attendant";
      case "fabric_cutter":
        return "Fabric Cutter";
      case "tailor":
        return "Tailor";
      case "finisher":
        return "Finisher";
      default:
        return "Tailor";
    }
  }

  void payUser(double amount, double advanceAmount) async {
    if (amount > 0.0) {
      String res = await showDialog(
          context: context,
          builder: (_) {
            return CustomPopup(
              title: "Pay User",
              onAccepted: () => Navigator.pop(context, "proceed"),
              onCancel: () => Navigator.pop(context, "cancelled"),
              acceptTitle: "PAY",
              body: Text(
                  "Do you wish to pay Ksh $amount to ${widget.payment!.user!["username"]}?"),
            );
          });

      if (res == "proceed") {
        setState(() {
          paying = true;
        });

        // Update in the user doc
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.payment!.user!["id"])
            .collection("user_payments")
            .doc(widget.payment!.id)
            .update({"status": "paid"});

        // Update globally
        await FirebaseFirestore.instance
            .collection("user_payments")
            .doc(widget.payment!.id)
            .update({"status": "paid"});

        // Check if there is "pending" advance
        if (advanceAmount > 0.0) {
          await clearAdvancePayment(false);
        }

        Fluttertoast.showToast(msg: "Payment Successful!");

        setState(() {
          paying = false;
        });
      } else {
        Fluttertoast.showToast(msg: "Payment Cancelled");
      }
    } else {
      Fluttertoast.showToast(msg: "Payment Error!");
    }
  }

  Future<void> clearAdvancePayment(bool isPartial) async {
    if (isPartial) {
      double paidAmount = int.parse(advanceController.text.trim()).toDouble();

      // Get the pending advance payment
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("advance_payments")
          .where("user.id", isEqualTo: widget.payment!.user!["id"])
          .where("status", isEqualTo: "pending")
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If documents exist
        // Definately its just one so we update it

        AdvancePayment advancePayment =
            AdvancePayment.fromDocument(querySnapshot.docs[0]);

        double balance = advancePayment.amount! - paidAmount;

        // Update balance for User
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.payment!.user!["id"])
            .collection("advance_payments")
            .doc(querySnapshot.docs[0].id)
            .update({
          "amount": balance,
        });

        // Update balance globally
        await querySnapshot.docs[0].reference.update({
          "amount": balance,
        });
      }
    } else {
      // Clear for User
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.payment!.user!["id"])
          .collection("advance_payments")
          .where("status", isEqualTo: "pending")
          .get()
          .then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((element) async {
            await element.reference.update({"status": "cleared"});
          });
        }
      });

      // Clear globally
      await FirebaseFirestore.instance
          .collection("advance_payments")
          .where("user.id", isEqualTo: widget.payment!.user!["id"])
          .where("status", isEqualTo: "pending")
          .get()
          .then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((element) async {
            await element.reference.update({"status": "cleared"});
          });
        }
      });
    }
  }

  void promptClearAdvancePayments() async {
    String res = await showDialog(
        context: context,
        builder: (_) {
          return CustomPopup(
            title: "Clear Advance",
            onAccepted: () {
              if (advanceController.text.isNotEmpty) {
                Navigator.pop(context, "proceed");
              } else {
                Fluttertoast.showToast(msg: "Please enter amount");
              }
            },
            onCancel: () => Navigator.pop(context, "cancelled"),
            acceptTitle: "Proceed",
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "Do you wish to clear advance payments for ${widget.payment!.user!["username"]}? Enter the amount below."),
                CustomTextField(
                  controller: advanceController,
                  hintText: "Ksh 0.00",
                  title: "Amount (Ksh) *",
                  inputType: TextInputType.number,
                ),
              ],
            ),
          );
        });

    if (res == "proceed" && advanceController.text.isNotEmpty) {
      setState(() {
        clearAdvance = true;
      });

      await clearAdvancePayment(true);

      Fluttertoast.showToast(msg: "Advance Payments cleared successfully!");

      setState(() {
        clearAdvance = false;
      });
    } else {
      Fluttertoast.showToast(msg: "Cancelled");
    }
  }

  Widget orderList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.payment!.orders!.length, (index) {
        String orderID = widget.payment!.orders![index];

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("orders")
              .doc(orderID)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            } else {
              template.Order order =
                  template.Order.fromDocument(snapshot.data!);

              return Card(
                child: ListTile(
                  leading: Image.network(
                    order.school!["imageUrl"],
                    height: 50.0,
                    width: 50.0,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    order.clientName!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                        color: Config.customGrey, fontWeight: FontWeight.w400),
                  ),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.school!["name"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat("dd MMM, HH:mm a").format(
                            DateTime.fromMillisecondsSinceEpoch(
                                order.timestamp!)),
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                  trailing: Text(
                    order.id!,
                    style: const TextStyle(color: Config.customBlue),
                  ),
                ),
              );
            }
          },
        );
      }),
    );
  }

  Widget displayAdvancePayments(double advanceTotal) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0.0,
      color: Colors.deepOrange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Advance Payments",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              "Ksh $advanceTotal",
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                  color: Config.customGrey, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(
              height: 10.0,
            ),
            clearAdvance
                ? const Text("Loading...")
                : advanceTotal < 1.0
                    ? const SizedBox()
                    : InkWell(
                        onTap: () => promptClearAdvancePayments(),
                        child: Card(
                          elevation: 0.0,
                          color: Colors.deepOrange.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Text(
                              "Clear Advance Payments",
                              style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
            const SizedBox(
              height: 30.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget displayPayCard(
      List<dynamic> orders, Tariff tariff, double advanceTotal) {
    bool payableIsNegative =
        ((orders.length * tariff.value!) - advanceTotal) < 0;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0.0,
      color: Config.customBlue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Orders Done",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        orders.length.toString(),
                        style: Theme.of(context).textTheme.headlineSmall!.apply(
                            color: Config.customGrey,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
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
            widget.payment!.status == "paid"
                ? const SizedBox()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 0.0,
                        color: Config.customBlue.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text(
                            "Tariff: Ksh ${tariff.value}",
                            style: const TextStyle(
                                color: Config.customBlue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "Amount Earned",
                        style: TextStyle(color: Config.customGrey),
                      ),
                      Text(
                        "Ksh ${orders.length * tariff.value!}",
                        style: Theme.of(context).textTheme.titleMedium!.apply(
                            color: Config.customBlue,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "Payable Amount (Income - Advance)",
                        style: TextStyle(color: Config.customGrey),
                      ),
                      Text(
                        "Ksh ${(orders.length * tariff.value!) - advanceTotal}",
                        style: Theme.of(context).textTheme.titleMedium!.apply(
                            color: Config.customBlue,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      paying
                          ? const Text("Loading...")
                          : payableIsNegative
                              ? const Text("Can't pay user at this moment")
                              : InkWell(
                                  onTap: () => payUser(
                                      (orders.length * tariff.value!) -
                                          advanceTotal,
                                      advanceTotal),
                                  child: Card(
                                    elevation: 0.0,
                                    color: Colors.green.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 5.0),
                                      child: Text(
                                        "Pay Ksh ${(orders.length * tariff.value!) - advanceTotal}",
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                    ],
                  )
            // const SizedBox(
            //   height: 10.0,
            // ),
          ],
        ),
      ),
    );
  }

  Widget displayPaymentAndAdvanceCards(
      double advanceTotal, Tariff currentTariff) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile =
            sizingInformation.isMobile || sizingInformation.isTablet;

        return isMobile
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  displayPayCard(
                      widget.payment!.orders!, currentTariff, advanceTotal),
                  displayAdvancePayments(advanceTotal)
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: displayPayCard(
                        widget.payment!.orders!, currentTariff, advanceTotal),
                  ),
                  Expanded(
                    flex: 1,
                    child: displayAdvancePayments(advanceTotal),
                  )
                ],
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool pending = widget.payment!.status == "pending";

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(widget.payment!.user!["id"])
          .collection("advance_payments")
          .where("status", isEqualTo: "pending")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<AdvancePayment> advancePayments = [];
          double advanceTotal = 0.0;

          snapshot.data!.docs.forEach((element) {
            AdvancePayment advancePayment =
                AdvancePayment.fromDocument(element);

            advancePayments.add(advancePayment);

            advanceTotal = advanceTotal + advancePayment.amount!;
          });

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("tariffs")
                // .where("users", arrayContainsAny: [filterUserRole()])
                .orderBy("timestamp", descending: true)
                .limit(1)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                Tariff currentTariff =
                    Tariff.fromDocument(snapshot.data!.docs[0]);

                double amount =
                    (currentTariff.value! * widget.payment!.orders!.length);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Card(
                    elevation: isExpanded ? 3.0 : 0.0,
                    color: isExpanded ? Colors.white : Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: ExpansionTile(
                      onExpansionChanged: (value) {
                        setState(() {
                          isExpanded = value;
                        });
                      },
                      leading: const Icon(
                        Icons.payment_rounded,
                        color: Config.customGrey,
                      ),
                      title: Text(
                        "PayID: ${widget.payment!.id!}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Created on: ${DateFormat("HH:mm a - dd, MMM").format(DateTime.fromMillisecondsSinceEpoch(widget.payment!.timestamp!))}",
                            style: const TextStyle(fontSize: 12.0),
                          ),
                          Text(
                            "User: ${widget.payment!.user!["username"]}, ${widget.payment!.user!["userRole"].split("_").join(" ")}.",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          CustomTag(
                            title: pending ? "Pending" : "Completed",
                            color: pending ? Colors.red : Colors.green,
                          )
                        ],
                      ),
                      trailing: Text(
                        "Ksh $amount",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: pending ? Colors.red : Colors.green,
                        ),
                      ),
                      children: [
                        displayPaymentAndAdvanceCards(
                            advanceTotal, currentTariff),
                        Text(
                          pending ? "Unpaid Orders" : "Paid Orders",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        orderList()
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
