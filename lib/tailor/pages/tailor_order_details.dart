import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:kindah/models/order.dart' as template;

import '../../common_functions/update_done_orders.dart';
import '../../config.dart';
import '../../models/account.dart';
import '../../models/uniform.dart';
import '../../providers/account_provider.dart';
import '../../widgets/adaptive_ui.dart';
import '../../widgets/progress_widget.dart';
import '../../widgets/uniform_data_layout.dart';

class TailorOrderDetails extends StatefulWidget {
  final String? templateID;
  const TailorOrderDetails({super.key, this.templateID});

  @override
  State<TailorOrderDetails> createState() => _TailorOrderDetailsState();
}

class _TailorOrderDetailsState extends State<TailorOrderDetails> {
  bool loading = false;
  List<Uniform> chosenUniforms = [];

  void completeOrder(template.Order order, Account account) async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("order_count")
        .doc("order_count")
        .get();

    int completedOrders = documentSnapshot["completed"];

    int assignedOrders = documentSnapshot["assigned"];

    await FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.templateID)
        .update({
      "processedStatus": "completed",
      "assignedStatus": "assigned",
      "tailor": account.toMap()
    });

    await FirebaseFirestore.instance
        .collection("order_count")
        .doc("order_count")
        .update({
      "completed": completedOrders + 1,
      "assigned": assignedOrders - 1,
    });

    // UPDATE DONE ORDER=========================================
    // await UpdateDoneOrders.updatePendingOrders(account, order.id!);
    await UpdateDoneOrders.updateDoneOrders(
        chosenUniforms: chosenUniforms,
        orderId: order.id!,
        userRole: "tailor",
        isAdmin: false,
        userMap: account.toMap(),
        userID: account.id);

    showCustomToast("Updated Successfully!");

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Account account = context.watch<AccountProvider>().account;

    return AdaptiveUI(
      appbarLeading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
      ),
      appbarTitle: "Template Details",
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .doc(widget.templateID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          } else {
            template.Order order = template.Order.fromDocument(snapshot.data!);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: <TextSpan>[
                      const TextSpan(
                          text: 'Template ID: ',
                          style: TextStyle(color: Config.customGrey)),
                      TextSpan(
                          text: order.id,
                          style: const TextStyle(color: Config.customBlue)),
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: <TextSpan>[
                      const TextSpan(
                          text: "Client's Name: ",
                          style: TextStyle(color: Config.customGrey)),
                      TextSpan(
                          text: order.clientName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Config.customGrey)),
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: <TextSpan>[
                      const TextSpan(
                          text: "School: ",
                          style: TextStyle(color: Config.customGrey)),
                      TextSpan(
                          text: order.school!["name"],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Config.customGrey)),
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: <TextSpan>[
                      const TextSpan(
                          text: "Student Class: ",
                          style: TextStyle(color: Config.customGrey)),
                      TextSpan(
                          text: order.clientClass.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Config.customGrey)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Image.network(
                  order.school!["imageUrl"],
                  width: size.width,
                  height: 200.0,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Ordered on ${DateFormat("MMM dd, HH:mm a").format(DateTime.fromMillisecondsSinceEpoch(order.timestamp!))}",
                  style: const TextStyle(fontSize: 10.0),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  "Ordered Items",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("orders")
                      .doc(order.id)
                      .collection("uniforms")
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return circularProgress();
                    } else {
                      List<Uniform> uniforms = [];
                      chosenUniforms = [];

                      snapshot.data!.docs.forEach((element) {
                        Uniform uniform = Uniform.fromDocument(element);

                        uniforms.add(uniform);
                        chosenUniforms.add(uniform);
                      });

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(uniforms.length, (index) {
                          Uniform uniform = uniforms[index];

                          return UniformDataLayout(
                            uniform: uniform,
                            index: index,
                          );
                        }),
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Amount Paid: \nKsh ${order.totalAmount}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.pink, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                order.processedStatus == "completed"
                    ? Container()
                    : const Text(
                        "After completion, please press the button below...",
                        textAlign: TextAlign.center,
                      ),
                loading
                    ? Container()
                    : order.processedStatus == "completed"
                        ? Align(
                            alignment: Alignment.center,
                            child: TextButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.done_rounded,
                                  color: Colors.green,
                                ),
                                label: const Text(
                                  "Completed",
                                  style: TextStyle(color: Colors.green),
                                )),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: CustomButton(
                              onPressed: () => completeOrder(order, account),
                              title: "Completed",
                              iconData: Icons.done_rounded,
                            ))
              ],
            );
          }
        },
      ),
    );
  }
}
