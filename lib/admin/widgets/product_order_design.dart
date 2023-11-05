import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/product.dart';
import 'package:kindah/models/product_order.dart';
import 'package:kindah/widgets/progress_widget.dart';

class ProductOrderDesign extends StatefulWidget {
  final ProductOrder productOrder;
  final String type;
  const ProductOrderDesign(
      {super.key, required this.productOrder, required this.type});

  @override
  State<ProductOrderDesign> createState() => _ProductOrderDesignState();
}

class _ProductOrderDesignState extends State<ProductOrderDesign> {
  void updateProductOrder(String status) async {
    await FirebaseFirestore.instance
        .collection("product_orders")
        .doc(widget.productOrder.id)
        .update({"deliveryStatus": status, "shippingStatus": status});

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("order_count")
        .doc("product_order_count")
        .get();

    int pending = doc["pending"];

    int shipping = doc["shipping"];

    int delivered = doc["delivered"];

    if (status == "shipping") {
      await FirebaseFirestore.instance
          .collection("order_count")
          .doc("product_order_count")
          .update({
        "pending": pending - 1,
        "shipping": shipping + 1,
      });

      showCustomToast("Approved Successfully!");
    } else {
      await FirebaseFirestore.instance
          .collection("order_count")
          .doc("product_order_count")
          .update({
        "delivered": delivered + 1,
        "shipping": shipping - 1,
      });

      showCustomToast("Updated Successfully!");
    }
  }

  Widget buildTrailing() {
    switch (widget.type) {
      case "pending":
        return TextButton.icon(
          icon: const Icon(
            Icons.done_rounded,
            color: Colors.orange,
          ),
          onPressed: () => updateProductOrder("shipping"),
          label: const Text(
            "Approve \nFor Shipping",
            style: TextStyle(color: Colors.orange),
          ),
        );

      case "shipping":
        return TextButton.icon(
          icon: const Icon(
            Icons.done_rounded,
            color: Colors.green,
          ),
          onPressed: () => updateProductOrder("delivered"),
          label: const Text(
            "Deliver \nTo Client",
            style: TextStyle(color: Colors.green),
          ),
        );
      case "delivered":
        return const Text(
          "Delivered",
          style: TextStyle(color: Colors.green),
        );
      default:
        return const SizedBox(
          height: 0.0,
          width: 0.0,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.productOrder.title!),
      childrenPadding: const EdgeInsets.only(left: 10.0),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Created: ${DateFormat("HH:mm a - dd, MMM").format(DateTime.fromMillisecondsSinceEpoch(widget.productOrder.timestamp!))}",
            style: const TextStyle(fontSize: 12.0),
          ),
          Text("Products: ${widget.productOrder.orderedProducts!.length}")
        ],
      ),
      trailing: buildTrailing(),
      children:
          List.generate(widget.productOrder.orderedProducts!.length, (index) {
        var productID = widget.productOrder.orderedProducts![index];

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("products")
              .doc(productID.toString())
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            } else {
              if (!snapshot.data!.exists) {
                return Container();
              } else {
                Product product = Product.fromDocument(snapshot.data!);

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Config.customGrey.withOpacity(0.4),
                        width: 1.0,
                      )),
                  child: ListTile(
                    leading: Image.network(product.images![0],
                        width: 100.0, height: 100.0, fit: BoxFit.cover),
                    title: Text(product.title!),
                    subtitle: Text("Price (Ksh): ${product.price}"),
                  ),
                );
              }
            }
          },
        );
      }),
    );
  }
}
