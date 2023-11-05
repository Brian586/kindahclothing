import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/providers/uniform_provider.dart';
import 'package:provider/provider.dart';

import '../../config.dart';

class TariffUniformDesign extends StatefulWidget {
  final String uniformName;
  const TariffUniformDesign({
    super.key,
    required this.uniformName,
  });

  @override
  State<TariffUniformDesign> createState() => _TariffUniformDesignState();
}

class _TariffUniformDesignState extends State<TariffUniformDesign> {
  TextEditingController priceController = TextEditingController();
  bool enabled = false;

  void updateTariff(BuildContext context) {
    Provider.of<UniformProvider>(context, listen: false).updateTariffPrice(
        name: widget.uniformName,
        newPrice: int.parse(priceController.text.trim()).toDouble());

    setState(() {
      enabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> tariffUniform = context
        .watch<UniformProvider>()
        .tariffUniforms
        .where((element) => element["name"] == widget.uniformName)
        .toList()
        .first;
    priceController.text = tariffUniform["price"].toString();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.uniformName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 150.0, minWidth: 80.0),
                child: TextField(
                  controller: priceController,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      color: !enabled ? Config.customGrey : Colors.black),
                  decoration: const InputDecoration(
                    hintText: "KES 1.00",
                    labelText: "Price per unit (KES)",
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  enabled
                      ? TextButton.icon(
                          onPressed: () => updateTariff(context),
                          icon: const Icon(
                            Icons.done_rounded,
                            color: Colors.green,
                          ),
                          label: const Text(
                            "Save",
                            style: TextStyle(color: Colors.green),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () => setState(() {
                            enabled = true;
                          }),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.grey,
                          ),
                          label: const Text(
                            "Edit",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                ],
              )
            ],
          )),
    );
  }
}

class TariffUniformDesignOnline extends StatefulWidget {
  final Tariff tariff;
  final int index;
  final Map<String, dynamic> tariffMap;
  final bool enableEditing;
  const TariffUniformDesignOnline({
    super.key,
    required this.enableEditing,
    required this.tariff,
    required this.tariffMap,
    required this.index,
  });

  @override
  State<TariffUniformDesignOnline> createState() =>
      _TariffUniformDesignOnlineState();
}

class _TariffUniformDesignOnlineState extends State<TariffUniformDesignOnline> {
  TextEditingController priceController = TextEditingController();
  String price = '';
  bool enabled = false;
  bool updating = false;

  @override
  void initState() {
    super.initState();
    price = widget.tariffMap["price"].toString();

    priceController.text = price;
  }

  void updateTariff(BuildContext context) async {
    setState(() {
      updating = true;
    });

    // get tariffs from document in firestore
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("tariffs")
        .doc(widget.tariff.id)
        .get();

    // Get tariffs
    List<dynamic> tariffs = documentSnapshot["tariffs"];

    print(tariffs);

    print(price);

    int indexToUpdate = widget.index;

    double newPrice = int.parse(price.trim()).toDouble(); // New price

    if (indexToUpdate >= 0 && indexToUpdate < tariffs.length) {
      tariffs[indexToUpdate]["price"] = newPrice;
      print("Updated: ${tariffs[indexToUpdate]}");

      await documentSnapshot.reference.update({
        "tariffs": tariffs,
      });
    } else {
      print("Index out of bounds or not found.");
    }

    setState(() {
      enabled = false;
      updating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.tariffMap["name"],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 150.0, minWidth: 80.0),
                child: TextField(
                  controller: priceController,
                  onChanged: (value) {
                    setState(() {
                      price = value;
                    });
                  },
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      color: !enabled ? Config.customGrey : Colors.black),
                  decoration: const InputDecoration(
                    hintText: "KES 1.00",
                    labelText: "Price per unit (KES)",
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              widget.enableEditing
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        enabled
                            ? updating
                                ? const Text("Updating...")
                                : TextButton.icon(
                                    onPressed: () => updateTariff(context),
                                    icon: const Icon(
                                      Icons.done_rounded,
                                      color: Colors.green,
                                    ),
                                    label: const Text(
                                      "Save",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  )
                            : TextButton.icon(
                                onPressed: () => setState(() {
                                  enabled = true;
                                  price = '';
                                }),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.grey,
                                ),
                                label: const Text(
                                  "Edit",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                      ],
                    )
                  : const SizedBox(
                      width: 10.0,
                    )
            ],
          )),
    );
  }
}
