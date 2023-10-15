import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/fabric_cutter/pages/template_details.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:kindah/models/uniform.dart';
import 'package:kindah/shop_attendant/pages/edit_template.dart';
import 'package:kindah/shop_attendant/pages/finished_order_details.dart';
import 'package:kindah/tailor/pages/tailor_order_details.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../finisher/pages/finisher_order_details.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import 'custom_tag.dart';

class OrderDesign extends StatefulWidget {
  final template.Order order;
  final bool isFinished;
  const OrderDesign({super.key, required this.order, required this.isFinished});

  @override
  State<OrderDesign> createState() => _OrderDesignState();
}

class _OrderDesignState extends State<OrderDesign> {
  void onTemplateSelected(BuildContext context, String preferedRole) {
    switch (preferedRole) {
      case "tailor":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TailorOrderDetails(
                      templateID: widget.order.id,
                    )));
        break;
      case "fabric_cutter":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TemplateDetails(
                      templateID: widget.order.id,
                    )));
        break;
      case "shop_attendant":
        if (widget.isFinished) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FinishedOrderDetails(
                        templateID: widget.order.id,
                      )));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditTemplate(
                        templateID: widget.order.id,
                      )));
        }
        break;
      case "finisher":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FinisherOrderDetails(
                      templateID: widget.order.id,
                    )));
        break;
    }
  }

  Widget displayStatusTag() {
    switch (widget.order.processedStatus) {
      case "not processed":
        return const CustomTag(
          title: "Not Processed",
          color: Colors.red,
        );
      case "processed":
        return const CustomTag(
          title: "Processed",
          color: Colors.deepOrange,
        );
      case "completed":
        return const CustomTag(
          title: "Tailored",
          color: Colors.teal,
        );
      case "finished":
        return const CustomTag(
          title: "Completed",
          color: Colors.green,
        );
      default:
        return const SizedBox(
          height: 0.0,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Account account = context.watch<AccountProvider>().account;
    String preferedRole = context.watch<AccountProvider>().preferedRole;

    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => onTemplateSelected(context, preferedRole),
        splashColor: Config.customBlue.withOpacity(0.1),
        leading: Image.network(
          widget.order.school!["imageUrl"],
          height: 50.0,
          width: 50.0,
          fit: BoxFit.cover,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.order.clientName!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                    color: Config.customGrey, fontWeight: FontWeight.w400),
              ),
            ),
            Text(
              widget.order.id!,
              style: const TextStyle(color: Config.customBlue),
            ),
          ],
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.order.school!["name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              DateFormat("dd MMM, HH:mm a").format(
                  DateTime.fromMillisecondsSinceEpoch(widget.order.timestamp!)),
              style: const TextStyle(fontSize: 12.0),
            ),
            displayStatusTag(),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("orders")
                  .doc(widget.order.id)
                  .collection("uniforms")
                  .limit(2)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text(
                    "Loading...",
                    style: TextStyle(color: Colors.black12),
                  );
                } else {
                  List<Uniform> uniforms = [];

                  snapshot.data!.docs.forEach((element) {
                    Uniform uniform = Uniform.fromDocument(element);

                    uniforms.add(uniform);
                  });

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(uniforms.length, (index) {
                        Uniform uniform = uniforms[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2.0, vertical: 5.0),
                          child: Text(
                            "${uniform.name!}s: ${uniform.quantity}",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      }),
                    ),
                  );
                }
              },
            ),
            Container(
              height: 0.5,
              width: size.width,
              color: Config.customGrey.withOpacity(0.4),
            )
          ],
        ),
      ),
    );
  }
}
