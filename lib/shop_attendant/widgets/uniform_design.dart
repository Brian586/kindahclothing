import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/uniform.dart';
import 'package:kindah/providers/uniform_provider.dart';
import 'package:provider/provider.dart';

class UniformDesign extends StatefulWidget {
  final Uniform? uniform;
  final List<Uniform> selectedUniforms;
  const UniformDesign({
    super.key,
    this.uniform,
    required this.selectedUniforms,
  });

  @override
  State<UniformDesign> createState() => _UniformDesignState();
}

class _UniformDesignState extends State<UniformDesign> {
  bool isSelected = false;
  bool isSaved = false;
  List<TextEditingController> editingControllers = [];
  TextEditingController quantityController = TextEditingController();
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();

    isSelected = widget.selectedUniforms.contains(widget.uniform);

    quantityController.text = "1";

    totalAmount = widget.uniform!.unitPrice!;

    for (var element in widget.uniform!.measurements!) {
      editingControllers
          .add(TextEditingController(text: element["measurement"].toString()));
    }
  }

  void updateInfo(BuildContext context, List<Uniform> chosenUniforms) {
    List<UniformMeasurement> measurements =
        List.generate(editingControllers.length, (index) {
      return UniformMeasurement(
        symbol: widget.uniform!.measurements![index]["symbol"],
        name: widget.uniform!.measurements![index]["name"],
        units: widget.uniform!.measurements![index]["units"],
        measurement:
            int.parse(editingControllers[index].text.trim()).toDouble(),
      );
    });

    Uniform uniform = Uniform(
      id: widget.uniform!.id,
      name: widget.uniform!.name,
      category: widget.uniform!.category,
      unitPrice: widget.uniform!.unitPrice,
      imageUrl: widget.uniform!.imageUrl,
      quantity: int.parse(quantityController.text.trim()),
      timestamp: widget.uniform!.timestamp,
      measurements: measurements.map((msmt) => msmt.toMap()).toList(),
    );

    if (!chosenUniforms.contains(uniform)) {
      setState(() {
        context.read<UniformProvider>().addUniform(uniform);
        totalAmount = uniform.quantity! * uniform.unitPrice!;
        isSaved = true;
      });

      print(chosenUniforms.length);

      Fluttertoast.showToast(msg: "Saved Successfully!");
    } else {
      Fluttertoast.showToast(msg: "Already Saved!");
    }
  }

  void editInfo(BuildContext context, List<Uniform> chosenUniforms) {
    print(chosenUniforms[0].measurements);

    Uniform uniform = chosenUniforms
        .where((element) => element.id == widget.uniform!.id)
        .toList()[0];

    context.read<UniformProvider>().removeUniform(uniform);

    setState(() {
      isSaved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Uniform> chosenUniforms =
        context.watch<UniformProvider>().chosenUniforms;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
                color: isSelected
                    ? Config.customBlue
                    : Config.customGrey.withOpacity(0.3))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text(
                widget.uniform!.name!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text("Unit Price: KSH ${widget.uniform!.unitPrice}"),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  isSelected = value!;
                  if (isSelected) {
                    widget.selectedUniforms.add(widget.uniform!);
                  } else {
                    widget.selectedUniforms.remove(widget.uniform!);
                  }
                });
              },
            ),
            if (isSelected)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    widget.uniform!.imageUrl!,
                    height: 200.0,
                    width: 200.0,
                    fit: BoxFit.contain,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        widget.uniform!.measurements!.length, (index) {
                      UniformMeasurement uniformMeasurement =
                          UniformMeasurement.fromJson(
                              widget.uniform!.measurements![index]);

                      return ListTile(
                        leading: Text(
                          uniformMeasurement.symbol!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: TextField(
                                  controller: editingControllers[index],
                                  enabled: !isSaved,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      color: isSaved
                                          ? Config.customGrey
                                          : Colors.black),
                                  decoration: InputDecoration(
                                    hintText: uniformMeasurement.name,
                                    labelText: uniformMeasurement.name,
                                  ),
                                ),
                              ),
                            ),
                            Text(uniformMeasurement.units!)
                          ],
                        ),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: quantityController,
                      enabled: !isSaved,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                          color: isSaved ? Config.customGrey : Colors.black),
                      decoration: const InputDecoration(
                        hintText: "Quantity",
                        labelText: "Quantity",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Cost: Ksh ${totalAmount.toString()}",
                    style: const TextStyle(
                        color: Colors.pink, fontWeight: FontWeight.w400),
                  ),
                  isSaved
                      ? TextButton.icon(
                          onPressed: () => editInfo(context, chosenUniforms),
                          icon: const Icon(
                            Icons.edit,
                            size: 16.0,
                            color: Config.customBlue,
                          ),
                          label: const Text(
                            "Edit",
                            style: TextStyle(
                                color: Config.customBlue,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () => updateInfo(context, chosenUniforms),
                          icon: const Icon(
                            Icons.done_rounded,
                            color: Config.customBlue,
                          ),
                          label: const Text(
                            "Save",
                            style: TextStyle(
                                color: Config.customBlue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                  const SizedBox(
                    height: 10.0,
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
