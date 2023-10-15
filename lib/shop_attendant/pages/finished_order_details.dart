import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../models/uniform.dart';
import '../../widgets/adaptive_ui.dart';
import '../../widgets/progress_widget.dart';
import '../../widgets/uniform_data_layout.dart';

class FinishedOrderDetails extends StatefulWidget {
  final String? templateID;
  const FinishedOrderDetails({super.key, this.templateID});

  @override
  State<FinishedOrderDetails> createState() => _FinishedOrderDetailsState();
}

class _FinishedOrderDetailsState extends State<FinishedOrderDetails> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // Account account = context.watch<AccountProvider>().account;

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

                      snapshot.data!.docs.forEach((element) {
                        Uniform uniform = Uniform.fromDocument(element);

                        uniforms.add(uniform);
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
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Contact client",
                    textAlign: TextAlign.center,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: () =>
                        launch("tel:+${order.paymentInfo!["contact"]}"),
                    icon: const Icon(
                      Icons.call_outlined,
                      color: Colors.green,
                    ),
                    label: const Text(
                      "CALL",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
