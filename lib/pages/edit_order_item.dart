import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

import '../common_functions/color_functions.dart';
import '../common_functions/custom_toast.dart';
import '../config.dart';
import '../dialog/error_dialog.dart';
import '../models/account.dart';
import '../models/custom_color.dart';
import '../models/uniform.dart';
import '../providers/account_provider.dart';
import '../widgets/adaptive_ui.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class EditOrderItem extends StatefulWidget {
  final template.DoneOrder order;
  final String preferedRole;
  const EditOrderItem(
      {super.key, required this.order, required this.preferedRole});

  @override
  State<EditOrderItem> createState() => _EditOrderItemState();
}

class _EditOrderItemState extends State<EditOrderItem> {
  // final ScrollController _controller = ScrollController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController uniformController = TextEditingController();
  String selectedSize = "";
  String selectedColor = "";
  String typeOfWork = "";
  Uniform? selectedUniform;
  bool loading = false;

  // initState
  @override
  void initState() {
    super.initState();

    setState(() {
      quantityController.text = widget.order.uniform!["quantity"].toString();
      // colorController.text = widget.order.uniform!["color"];
      uniformController.text = widget.order.uniform!["name"];
      selectedSize = widget.order.uniform!["size"];
      selectedColor = widget.order.uniform!["color"];
      typeOfWork = widget.order.typeOfWork!;
      selectedUniform = Uniform.fromMap(widget.order.uniform);
    });
  }

  void updateRecordInFirestore(Account account) async {
    setState(() {
      loading = true;
    });

    try {
      Uniform uniform = Uniform(
        id: selectedUniform!.id,
        name: selectedUniform!.name,
        category: selectedUniform!.category,
        unitPrice: selectedUniform!.unitPrice!.toDouble(),
        imageUrl: selectedUniform!.imageUrl,
        quantity: int.parse(quantityController.text.trim()),
        timestamp: selectedUniform!.timestamp,
        size: selectedSize,
        color: selectedColor,
        measurements: widget.order.uniform!["measurements"],
      );

      // Update done orders in database

      template.DoneOrder doneOrder = template.DoneOrder(
        id: widget.order.id,
        orderId: widget.order.orderId,
        typeOfWork: typeOfWork,
        userRole: widget.order.userRole,
        timestamp: widget.order.timestamp,
        isPaid: widget.order.isPaid,
        type: widget.order.type,
        user: account.toMap(),
        uniform: uniform.toMap(),
      );

      // Upload globally
      await FirebaseFirestore.instance
          .collection("done_orders")
          .doc(doneOrder.id)
          .update(doneOrder.toMap());

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.id)
          .collection("done_orders")
          .doc(doneOrder.id)
          .update(doneOrder.toMap());

      showCustomToast("Updated Successfully");

      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e.toString());

      showErrorDialog(context, e.toString());

      showCustomToast("Error saving data :(");

      setState(() {
        loading = false;
      });
    }
  }

  Future<List<Uniform>> getUniforms(String filter) async {
    List<Uniform> uniforms = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("uniforms")
        .where("name", isGreaterThanOrEqualTo: filter)
        .get();

    if (filter.isNotEmpty) {
      var filteredResults = querySnapshot.docs
          .where((element) => element["name"] == filter.toCapitalized())
          .toList();

      for (var filteredResult in filteredResults) {
        Uniform uniform = Uniform.fromDocument(filteredResult);

        uniforms.add(uniform);
      }
    } else {
      for (var res in querySnapshot.docs) {
        Uniform uniform = Uniform.fromDocument(res);

        uniforms.add(uniform);
      }
    }

    return uniforms;
  }

  Widget _customPopupItemBuilder(
    BuildContext context,
    Uniform? uniform,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(uniform?.name ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<AccountProvider>().account;

    return EcommAdaptiveUI(
      appbarTitle: "Edit Item",
      onBackPressed: () => Navigator.pop(context),
      body: loading
          ? circularProgress()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    "Fields marked * are Required",
                    style: TextStyle(fontSize: 12.0, color: Config.customGrey),
                  ),
                  DropdownSearch<Uniform>(
                    asyncItems: (String? filter) => getUniforms(filter!),
                    compareFn: (item1, item2) => item1.id == item2.id,
                    clearButtonProps: const ClearButtonProps(isVisible: true),
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                      itemBuilder: _customPopupItemBuilder,
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        controller: uniformController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              uniformController.clear();
                            },
                          ),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedUniform = value!;
                      });
                    },
                    itemAsString: (item) => item.name!,
                    selectedItem: selectedUniform,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Choose Item *',
                        filled: true,
                        fillColor: Theme.of(context)
                            .inputDecorationTheme
                            .fillColor, //gsutil cors set cors.json gs://kindahclothing
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: quantityController,
                    hintText: "1, 2, 3...",
                    title: "Quantity *",
                    inputType: TextInputType.number,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSelectedItems: true,
                      ),
                      compareFn: (item1, item2) => item1 == item2,
                      items: uniformSizes,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select Item Size *",
                          hintText: "S, M, L, XL",
                        ),
                      ),
                      onChanged: (str) {
                        setState(() {
                          selectedSize = str!;
                        });
                      },
                      selectedItem: selectedSize,
                      itemAsString: sizeMatcher,
                    ),
                  ),
                  widget.preferedRole == "special_machine_handler"
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSelectedItems: true,
                            ),
                            compareFn: (item1, item2) => item1 == item2,
                            selectedItem: typeOfWork,
                            items: const ["Name Labelling", "Logo"],
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Type of work *",
                                hintText: "Embroidery work",
                              ),
                            ),
                            onChanged: (str) {
                              setState(() {
                                typeOfWork = str!;
                              });
                            },
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: DropdownSearch<CustomColor>(
                      asyncItems: (String? filter) =>
                          getColors(context, filter!),
                      clearButtonProps: const ClearButtonProps(isVisible: true),
                      popupProps: PopupProps.menu(
                        // showSelectedItems: true,
                        itemBuilder: (context, customColor, isSelected) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: ListTile(
                              tileColor: isSelected
                                  ? hexToColor(customColor.hex!)
                                  : Colors.transparent,
                              leading: Container(
                                height: 30.0,
                                width: 30.0,
                                color: hexToColor(customColor.hex!),
                              ),
                              title: Text(customColor.name!),
                              subtitle: Text(customColor.hex!),
                            ),
                          );
                        },
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          controller: colorController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Config.customGrey,
                              ),
                              onPressed: () {
                                colorController.clear();
                              },
                            ),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedColor = value!.hex!;
                        });
                      },
                      itemAsString: (item) => item.name!,
                      // selectedItem: CustomColor(name: , hex: selectedColor),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Item Color *',
                          filled: true,
                          fillColor: Theme.of(context)
                              .inputDecorationTheme
                              .fillColor, //gsutil cors set cors.json gs://kindahclothing
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  CustomButton(
                    title: "UPDATE",
                    iconData: Icons.done_rounded,
                    onPressed: () {
                      if (quantityController.text.isNotEmpty &&
                          selectedSize.isNotEmpty &&
                          selectedColor.isNotEmpty &&
                          selectedUniform != null) {
                        if (widget.preferedRole == "special_machine_handler" &&
                            typeOfWork.isNotEmpty) {
                          updateRecordInFirestore(account);
                        } else {
                          showCustomToast("Fill in the Type of work field");
                        }
                      } else {
                        showCustomToast("Fill in the required fields");
                      }
                    },
                  ),
                  const SizedBox(
                    height: 50.0,
                  )
                ],
              ),
            ),
    );
  }
}
