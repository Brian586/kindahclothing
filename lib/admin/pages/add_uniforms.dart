import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/models/uniform.dart';
import 'package:provider/provider.dart';

import '../../common_functions/custom_file_picker.dart';
import '../../common_functions/uploader.dart';
import '../../config.dart';
import '../../models/admin.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';

class AddUniforms extends StatefulWidget {
  const AddUniforms({super.key});

  @override
  State<AddUniforms> createState() => _AddUniformsState();
}

class _AddUniformsState extends State<AddUniforms> {
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

  void pickPhoto() async {
    List<PlatformFile> files =
        await CustomFilePicker.pickImages(isMultiple: false);

    if (files.isNotEmpty) {
      setState(() {
        file = files[0];
      });
    }
  }

  Future<void> updateAdminCount(Admin admin, Map<String, dynamic> map) async {
    await FirebaseFirestore.instance
        .collection("admins")
        .doc(admin.id)
        .update(map);
  }

  void saveUniformToFirestore(Admin admin) async {
    setState(() {
      loading = true;
    });

    try {
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      String downloadUrl = await Uploader.uploadImage(
        destination: "Uniforms",
        id: timestamp.toString(),
        platformFile: file,
      );

      Uniform uniform = Uniform(
        id: timestamp.toString(),
        name: nameController.text.trim(),
        category: selectedCategory,
        unitPrice: int.parse(priceController.text.trim()).toDouble(),
        imageUrl: downloadUrl,
        quantity: 0,
        timestamp: timestamp,
        measurements: measurements.map((msmt) => msmt.toMap()).toList(),
      );

      await FirebaseFirestore.instance
          .collection("uniforms")
          .doc(uniform.id)
          .set(uniform.toMap());

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("admins")
          .doc(admin.id)
          .get();

      Admin updatedAdmin = Admin.fromDocument(documentSnapshot);

      await updateAdminCount(admin, {
        "uniforms": updatedAdmin.uniforms! + 1,
      });

      Fluttertoast.showToast(
          msg:
              "${nameController.text.trim()} added to the database successfully!");

      setState(() {
        file = null;
        nameController.clear();
        selectedCategory = "";
        priceController.clear();
        categoryController.clear();
        measurements.clear();
        loading = false;
      });
    } catch (e) {
      print(e.toString());

      Fluttertoast.showToast(msg: "Error saving data :(");

      setState(() {
        loading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    Admin admin = context.watch<AdminProvider>().admin;
    Size size = MediaQuery.of(context).size;

    return loading
        ? circularProgress()
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomHeader(
                  action: [],
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: CustomWrapper(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              file == null
                                  ? const Icon(
                                      Icons.image_outlined,
                                      color: Colors.black12,
                                      size: 100.0,
                                    )
                                  : Image.memory(
                                      file!.bytes!,
                                      height: 200.0,
                                      width: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                              Positioned(
                                bottom: 0.0,
                                right: 0.0,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  child: CircleAvatar(
                                    radius: 20.0,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
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
                          file != null
                              ? TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      file = null;
                                    });
                                  },
                                  label: const Text(
                                    "Remove Photo",
                                    style: TextStyle(color: Config.customBlue),
                                  ),
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: Config.customBlue,
                                  ))
                              : Container(),
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Text(
                            "Fields marked * are Required",
                            style: TextStyle(
                                fontSize: 12.0, color: Config.customGrey),
                          ),
                          CustomTextField(
                            controller: nameController,
                            hintText: "e.g Shirt, Trouser, Hijab",
                            title: "Uniform Name*",
                            inputType: TextInputType.name,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: DropdownSearch<dynamic>(
                              asyncItems: (String? filter) =>
                                  getCategories(context, filter!),
                              clearButtonProps:
                                  const ClearButtonProps(isVisible: true),
                              popupProps: PopupProps.menu(
                                disabledItemFn: (dynamic s) =>
                                    s.startsWith('A'),
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
                                  fillColor: Theme.of(context)
                                      .inputDecorationTheme
                                      .fillColor,
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
                                fontWeight: FontWeight.bold,
                                color: Config.customGrey),
                          ),
                          measurements.isEmpty
                              ? Container()
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(measurements.length,
                                      (index) {
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
                                              measurements
                                                  .remove(measurements[index]);
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
                            title:
                                "Measurement Symbol (As per image provided above)",
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
                                Fluttertoast.showToast(
                                    msg: "Fill Measurement Form");
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
                          CustomButton(
                            title: "SAVE",
                            iconData: Icons.done_rounded,
                            onPressed: () {
                              if (nameController.text.isNotEmpty &&
                                  selectedCategory.isNotEmpty &&
                                  file != null &&
                                  measurements.isNotEmpty &&
                                  priceController.text.isNotEmpty) {
                                saveUniformToFirestore(admin);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Fill in the required fields");
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
          );
  }
}
