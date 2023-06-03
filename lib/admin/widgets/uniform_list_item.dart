import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/models/uniform.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../../common_functions/custom_file_picker.dart';
import '../../common_functions/update_admin_info.dart';
import '../../common_functions/uploader.dart';
import '../../config.dart';
import '../../models/admin.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/custom_textfield.dart';

class UniformListItem extends StatefulWidget {
  final Uniform uniform;
  const UniformListItem({super.key, required this.uniform});

  @override
  State<UniformListItem> createState() => _UniformListItemState();
}

class _UniformListItemState extends State<UniformListItem> {
  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController nameMeasureController = TextEditingController();
  TextEditingController symbolController = TextEditingController();
  List<UniformMeasurement> measurements = [];
  String selectedCategory = "";
  String units = "mm";
  bool loading = false;
  PlatformFile? file;

  @override
  void initState() {
    super.initState();

    setControllers();
  }

  void setControllers() {
    setState(() {
      nameController.text = widget.uniform.name!;
      categoryController.text = widget.uniform.category!;
      priceController.text = widget.uniform.unitPrice!.toString();
      selectedCategory = widget.uniform.category!;
      units = widget.uniform.measurements![0]["units"];
      measurements = List.generate(
          widget.uniform.measurements!.length,
          (index) =>
              UniformMeasurement.fromJson(widget.uniform.measurements![index]));
    });
  }

  void pickPhoto() async {
    List<PlatformFile> files =
        await CustomFilePicker.pickImages(isMultiple: false);

    if (files.isNotEmpty) {
      setState(() {
        file = files[0];
      });

      String res = await showDialog(
          context: context,
          builder: (_) {
            return CustomPopup(
              title: "Update Photo",
              onAccepted: () => Navigator.pop(context, "proceed"),
              onCancel: () => Navigator.pop(context, "cancelled"),
              acceptTitle: "Proceed",
              body: Text("Do you wish to update this photo?"),
            );
          });

      if (res == "proceed") {
        try {
          String downloadUrl = await Uploader.uploadImage(
            destination: "Uniforms",
            id: widget.uniform.id,
            platformFile: file,
          );

          await FirebaseFirestore.instance
              .collection("uniforms")
              .doc(widget.uniform.id)
              .update({"imageUrl": downloadUrl});

          Fluttertoast.showToast(msg: "Photo Uploaded");
        } catch (e) {
          print(e.toString());

          Fluttertoast.showToast(msg: "An Error Occurred");
        }
      } else {
        setState(() {
          file = null;
        });
      }
    }
  }

  Future<List<dynamic>> getCategories(
      BuildContext context, String filter) async {
    List<dynamic> categories = [];

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("categories")
        .doc("categories")
        .get();

    if (filter.isNotEmpty) {
      // filter the list of strings based on the value of the given value
      var filteredResults = snapshot["cat"]
          .where((str) => str == filter.toCapitalized())
          .toList();

      for (var filteredResult in filteredResults) {
        categories.add(filteredResult);
      }
    } else {
      for (var res in snapshot["cat"]) {
        categories.add(res);
      }
    }

    return categories;
  }

  void updateUniformInfo() async {
    setState(() {
      loading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("uniforms")
          .doc(widget.uniform.id)
          .update({
        "name": nameController.text.trim(),
        "category": selectedCategory,
        "unitPrice": int.parse(priceController.text.trim()).toDouble(),
        "measurements": measurements.map((msmt) => msmt.toMap()).toList(),
      });

      Fluttertoast.showToast(msg: "Updated Successfully!");

      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e.toString());

      setState(() {
        loading = false;
      });

      Fluttertoast.showToast(msg: "An Error Occurred");
    }
  }

  void promptUniformDeletion() async {
    String res = await showDialog(
        context: context,
        builder: (_) {
          return CustomPopup(
            title: "Delete Uniform",
            onAccepted: () => Navigator.pop(context, "proceed"),
            onCancel: () => Navigator.pop(context, "cancelled"),
            acceptTitle: "DELETE",
            body: const Text("Do you wish to delete this uniform permanently?"),
          );
        });

    if (res == "proceed") {
      await FirebaseFirestore.instance
          .collection("uniforms")
          .doc(widget.uniform.id)
          .get()
          .then((value) async {
        if (value.exists) {
          await value.reference.delete();
        }
      });

      await UpdateAdminInfo().updateUniformsCount(widget.uniform, false);

      Fluttertoast.showToast(msg: "Uniform Deleted Successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Card(
      child: ExpansionTile(
        leading: Image.network(
          widget.uniform.imageUrl!,
          height: 150.0,
          width: 150.0,
          fit: BoxFit.contain,
        ),
        title: Text(widget.uniform.name!),
        children: loading
            ? [circularProgress()]
            : [
                Stack(
                  children: [
                    Container(
                      height: 300.0,
                      width: size.width,
                      color: Config.customGrey.withOpacity(0.1),
                    ),
                    Positioned.fill(
                      child: Image.network(
                        widget.uniform.imageUrl!,
                        height: 300.0,
                        width: size.width,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned.fill(
                      child: file == null
                          ? const SizedBox()
                          : Image.memory(
                              file!.bytes!,
                              height: 300.0,
                              width: size.width,
                              fit: BoxFit.contain,
                            ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        child: CircleAvatar(
                          radius: 20.0,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_a_photo_rounded,
                                color: Config.customGrey,
                              ),
                              onPressed: () => pickPhoto(),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  "Fields marked * are Required",
                  style: TextStyle(fontSize: 12.0, color: Config.customGrey),
                ),
                CustomTextField(
                  controller: nameController,
                  hintText: "e.g Shirt, Trouser, Hijab",
                  title: "Uniform Name*",
                  inputType: TextInputType.name,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: DropdownSearch<dynamic>(
                    asyncItems: (String? filter) =>
                        getCategories(context, filter!),
                    clearButtonProps: const ClearButtonProps(isVisible: true),
                    popupProps: PopupProps.menu(
                      disabledItemFn: (dynamic s) => s.startsWith('A'),
                      showSelectedItems: true,
                      itemBuilder: (context, category, isSelected) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text(
                            category,
                            style: TextStyle(
                                color: isSelected
                                    ? Config.customBlue
                                    : Colors.black),
                          ),
                        );
                      },
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        controller: categoryController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Config.customGrey,
                            ),
                            onPressed: () {
                              categoryController.clear();
                            },
                          ),
                        ),
                      ),
                    ),
                    selectedItem: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    itemAsString: (item) => item,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Category *',
                        filled: true,
                        fillColor:
                            Theme.of(context).inputDecorationTheme.fillColor,
                      ),
                    ),
                  ),
                ),
                CustomTextField(
                  controller: priceController,
                  hintText: "KSH 0.00",
                  title: "Unit Price*",
                  inputType: TextInputType.number,
                ),
                const Text(
                  "Add Measurements",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Config.customGrey),
                ),
                measurements.isEmpty
                    ? Container()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(measurements.length, (index) {
                          return Card(
                            child: ListTile(
                              leading: Text(
                                measurements[index].symbol!,
                              ),
                              title: Text(measurements[index].name!),
                              subtitle: Text(
                                  "${measurements[index].measurement} ${measurements[index].units}"),
                              trailing: IconButton(
                                onPressed: () {
                                  setState(() {
                                    measurements.remove(measurements[index]);
                                  });
                                },
                                icon: const Icon(
                                  Icons.clear,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                const SizedBox(
                  height: 20.0,
                ),
                CustomTextField(
                  controller: symbolController,
                  hintText: "Symbol",
                  title: "Measurement Symbol (As per image provided above)",
                  inputType: TextInputType.name,
                ),
                CustomTextField(
                  controller: nameMeasureController,
                  hintText: "e.g Chest, Arm, Waist",
                  title: "Measurement Name",
                  inputType: TextInputType.name,
                ),
                DropdownSearch<String>(
                  items: const ["mm", "cm", "m", "inch"],
                  popupProps: const PopupProps.menu(),
                  onChanged: (value) {
                    setState(() {
                      units = value!;
                    });
                  },
                  selectedItem: units,
                ),
                TextButton.icon(
                  icon: const Icon(
                    Icons.add,
                    color: Config.customBlue,
                  ),
                  label: const Text(
                    "Add Measurement",
                    style: TextStyle(color: Config.customBlue),
                  ),
                  onPressed: () {
                    if (symbolController.text.isNotEmpty &&
                        nameMeasureController.text.isNotEmpty) {
                      UniformMeasurement uniformMeasurement =
                          UniformMeasurement(
                        symbol: symbolController.text.trim(),
                        name: nameMeasureController.text.trim(),
                        measurement: 0.0,
                        units: units,
                      );

                      measurements.add(uniformMeasurement);

                      setState(() {
                        symbolController.clear();
                        nameMeasureController.clear();
                      });
                    } else {
                      Fluttertoast.showToast(msg: "Fill Measurement Form");
                    }
                  },
                ),
                Container(
                  height: 1.0,
                  width: size.width,
                  color: Config.customBlue,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => updateUniformInfo(),
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.green,
                      ),
                      label: const Text(
                        "UPDATE",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    TextButton.icon(
                      onPressed: () => promptUniformDeletion(),
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: Colors.red,
                      ),
                      label: const Text(
                        "DELETE",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                )
              ],
      ),
    );
  }
}
