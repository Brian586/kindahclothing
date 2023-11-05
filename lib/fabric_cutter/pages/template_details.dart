import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/config.dart';
import 'package:kindah/fabric_cutter/pages/choose_tailor.dart';
import 'package:kindah/models/uniform.dart';
import 'package:kindah/widgets/adaptive_ui.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:kindah/widgets/uniform_data_layout.dart';
import 'package:provider/provider.dart';
import 'package:kindah/models/order.dart' as template;

import '../../common_functions/update_done_orders.dart';
import '../../dialog/error_dialog.dart';
import '../../models/account.dart';
import '../../providers/account_provider.dart';

class TemplateDetails extends StatefulWidget {
  final String? templateID;
  const TemplateDetails({super.key, this.templateID});

  @override
  State<TemplateDetails> createState() => _TemplateDetailsState();
}

class _TemplateDetailsState extends State<TemplateDetails> {
  bool isProcessing = false;
  List<Uniform> chosenUniforms = [];

  void selectForProcessing(Account account, template.Order order) async {
    setState(() {
      isProcessing = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.templateID)
          .update({
        "processedStatus": "processing",
        "fabricCutter": account.toMap(),
      });

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("order_count")
          .doc("order_count")
          .get();

      int processedCount = documentSnapshot["processed"];

      await FirebaseFirestore.instance
          .collection("order_count")
          .doc("order_count")
          .update({
        "processed": processedCount + 1,
      });

      // UPDATE DONE ORDER=========================================
      // await UpdateDoneOrders.updatePendingOrders(account, widget.templateID!);

      await UpdateDoneOrders.updateDoneOrders(
          chosenUniforms: chosenUniforms,
          orderId: order.id!,
          userRole: "fabric_cutter",
          isAdmin: false,
          userMap: account.toMap(),
          userID: account.id);

      setState(() {
        isProcessing = false;
      });
    } catch (e) {
      print(e.toString());

      showErrorDialog(context, e.toString());

      showCustomToast("An ERROR Occured :(");

      setState(() {
        isProcessing = false;
      });
    }
  }

  void assignToTailor() async {
    try {
      String userID = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChooseTailor(
                    templateID: widget.templateID,
                  )));

      if (userID != "error") {
        DocumentSnapshot tailorSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(userID)
            .get();

        Account tailor = Account.fromDocument(tailorSnapshot);

        await FirebaseFirestore.instance
            .collection("orders")
            .doc(widget.templateID)
            .update({
          "assignedStatus": "assigned",
          "processedStatus": "processed",
          "tailor": tailor.toMap()
        });

        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("order_count")
            .doc("order_count")
            .get();

        int assignedCount = documentSnapshot["assigned"];

        await FirebaseFirestore.instance
            .collection("order_count")
            .doc("order_count")
            .update({
          "assigned": assignedCount + 1,
        });

        showCustomToast("Assigned Successfully!");
      }
    } catch (e) {
      print(e.toString());

      showErrorDialog(context, e.toString());

      showCustomToast("An ERROR Occured :(");
    }
  }

  Widget _button(template.Order order, Account account) {
    switch (order.processedStatus) {
      case "not processed":
        return CustomButton(
          onPressed: () => selectForProcessing(account, order),
          title: "Process this order",
          iconData: Icons.cut_rounded,
        );
      case "processing":
        return CustomButton(
          onPressed: () => assignToTailor(),
          title: "Assign to Tailor",
          iconData: Icons.assignment_turned_in_outlined,
        );
      case "processed":
        return Container();
      default:
        return CustomButton(
          onPressed: () => selectForProcessing(account, order),
          title: "Process this order",
          iconData: Icons.cut_rounded,
        );
    }
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
                ListTile(
                  leading: Image.network(
                    order.school!["logo"] ?? "",
                    height: 100.0,
                    width: 100.0,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.school_outlined,
                      color: Config.customGrey,
                    ),
                  ),
                  title: Text(order.school!["name"]),
                  subtitle: Text(
                      "${order.school!["city"]}, ${order.school!["country"]}"),
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
                isProcessing
                    ? const Text(
                        "Selecting template...",
                      )
                    : Align(
                        alignment: Alignment.center,
                        child: _button(order, account))
              ],
            );
          }
        },
      ),
    );
  }
}
