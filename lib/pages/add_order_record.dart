import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/models/uniform.dart';
import 'package:provider/provider.dart';
import 'package:kindah/models/order.dart' as template;

import '../common_functions/color_functions.dart';
import '../config.dart';
import '../dialog/error_dialog.dart';
import '../models/account.dart';
import '../models/custom_color.dart';
import '../providers/account_provider.dart';
import '../user_panel/widgets/user_custom_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_scrollbar.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_wrapper.dart';
import '../widgets/progress_widget.dart';

class AddOrderRecord extends StatefulWidget {
  final String preferedRole;
  const AddOrderRecord({super.key, required this.preferedRole});

  @override
  State<AddOrderRecord> createState() => _AddOrderRecordState();
}

class _AddOrderRecordState extends State<AddOrderRecord> {
  final ScrollController _controller = ScrollController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController uniformController = TextEditingController();
  String selectedSize = "";
  String selectedColor = "";
  Uniform? selectedUniform;
  bool loading = false;

  void saveRecordToFirestore(Account account) async {
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
        measurements: [],
      );

      // Update done orders in database
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      template.DoneOrder doneOrder = template.DoneOrder(
        id: timestamp.toString(),
        orderId: "",
        userRole: widget.preferedRole,
        timestamp: timestamp,
        isPaid: false,
        type: "custom",
        user: account.toMap(),
        uniform: uniform.toMap(),
      );

      // Upload globally
      await FirebaseFirestore.instance
          .collection("done_orders")
          .doc(doneOrder.id)
          .set(doneOrder.toMap());

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.id)
          .collection("done_orders")
          .doc(doneOrder.id)
          .set(doneOrder.toMap());

      showCustomToast("Uploaded Successfully");

      setState(() {
        loading = false;
        quantityController.clear();
        colorController.clear();
        uniformController.clear();
        selectedSize = "";
        selectedColor = "";
        selectedUniform = null;
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

    return loading
        ? circularProgress()
        : CustomScrollBar(
            controller: _controller,
            child: SingleChildScrollView(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const UserCustomHeader(
                    action: [],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: CustomWrapper(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Text(
                              "Fields marked * are Required",
                              style: TextStyle(
                                  fontSize: 12.0, color: Config.customGrey),
                            ),
                            DropdownSearch<Uniform>(
                              asyncItems: (String? filter) =>
                                  getUniforms(filter!),
                              clearButtonProps:
                                  const ClearButtonProps(isVisible: true),
                              popupProps: PopupProps.menu(
                                //showSelectedItems: true,
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
                              // compareFn: (item, selectedItem) =>
                              //     item.id == selectedItem.id,
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
                                    // showSelectedItems: true,
                                    ),
                                items: uniformSizes,
                                dropdownDecoratorProps:
                                    const DropDownDecoratorProps(
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
                                // selectedItem: selectedSize,
                                itemAsString: sizeMatcher,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: DropdownSearch<CustomColor>(
                                asyncItems: (String? filter) =>
                                    getColors(context, filter!),
                                clearButtonProps:
                                    const ClearButtonProps(isVisible: true),
                                popupProps: PopupProps.menu(
                                  itemBuilder:
                                      (context, customColor, isSelected) {
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
                              title: "SAVE",
                              iconData: Icons.done_rounded,
                              onPressed: () {
                                if (quantityController.text.isNotEmpty &&
                                    selectedSize.isNotEmpty &&
                                    selectedColor.isNotEmpty &&
                                    selectedUniform != null) {
                                  saveRecordToFirestore(account);
                                } else {
                                  showCustomToast(
                                      "Fill in the required fields");
                                }
                              },
                            ),
                            const SizedBox(
                              height: 50.0,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
