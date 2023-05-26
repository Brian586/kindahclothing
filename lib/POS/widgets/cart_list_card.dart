import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:kindah/POS/models/pos_product.dart";

class CartListCard extends StatefulWidget {
  final POSProduct product;
  final String userID;
  const CartListCard({super.key, required this.product, required this.userID});

  @override
  State<CartListCard> createState() => _CartListCardState();
}

class _CartListCardState extends State<CartListCard> {
  TextEditingController quantityController = TextEditingController();
  int quantityValue = 1;
  bool updating = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      quantityController.text = widget.product.quantity.toString();
      quantityValue = widget.product.quantity!;
    });
  }

  void onChanged(int value) async {
    setState(() {
      updating = true;
    });

    await FirebaseFirestore.instance
        .collection("POS_users")
        .doc(widget.userID)
        .collection("cart")
        .doc(widget.product.id)
        .update({"quantity": value});

    setState(() {
      updating = false;
    });
  }

  Widget quantityTextField() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: quantityValue > 1
              ? () {
                  setState(() {
                    quantityValue--;
                    quantityController.text = quantityValue.toString();
                  });

                  print(quantityValue);
                  onChanged(quantityValue);
                }
              : null,
        ),
        const SizedBox(
          width: 5,
        ),
        SizedBox(
          width: 70.0,
          child: TextField(
            controller: quantityController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
            ),
            // onChanged: onChanged,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              quantityValue++;
              quantityController.text = quantityValue.toString();
            });
            print(quantityValue);
            onChanged(quantityValue);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  widget.product.image!,
                  height: 150.0,
                  width: 150.0,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "Ksh ${widget.product.price!}",
                    style: const TextStyle(
                        color: Colors.pink, fontWeight: FontWeight.bold),
                  ),
                  quantityTextField()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
