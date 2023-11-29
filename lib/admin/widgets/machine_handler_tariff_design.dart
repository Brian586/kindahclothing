import 'package:flutter/material.dart';

import '../../config.dart';

class MachineHandlerTariffDesign extends StatefulWidget {
  final Map<String, dynamic> tariff;
  final void Function(String, double) onValueUpdated;
  const MachineHandlerTariffDesign(
      {super.key, required this.tariff, required this.onValueUpdated});

  @override
  State<MachineHandlerTariffDesign> createState() =>
      _MachineHandlerTariffDesignState();
}

class _MachineHandlerTariffDesignState
    extends State<MachineHandlerTariffDesign> {
  TextEditingController priceController = TextEditingController();
  bool enabled = false;

  @override
  Widget build(BuildContext context) {
    priceController.text = widget.tariff["price"].toString();

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
                  widget.tariff["name"],
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
                          onPressed: () {
                            widget.onValueUpdated(
                                widget.tariff["name"],
                                int.parse(priceController.text.trim())
                                    .toDouble());

                            setState(() {
                              enabled = false;
                            });
                          },
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
