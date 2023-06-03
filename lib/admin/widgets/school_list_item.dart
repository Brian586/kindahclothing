import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/common_functions/update_admin_info.dart';
import 'package:kindah/models/school.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../../common_functions/custom_file_picker.dart';
import '../../common_functions/load_json.dart';
import '../../common_functions/uploader.dart';
import '../../config.dart';
import '../../models/custom_location.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/custom_textfield.dart';

class SchoolListItem extends StatefulWidget {
  final School school;
  const SchoolListItem({super.key, required this.school});

  @override
  State<SchoolListItem> createState() => _SchoolListItemState();
}

class _SchoolListItemState extends State<SchoolListItem> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  String city = "";
  bool loading = false;
  PlatformFile? uniformFile;
  PlatformFile? logoFile;
  String category = "School";

  @override
  void initState() {
    super.initState();

    updateControllers();
  }

  void updateControllers() {
    setState(() {
      nameController.text = widget.school.name!;
      cityController.text = widget.school.city!;
      countryController.text = widget.school.country!;
      city = widget.school.city!;
      category = widget.school.category!;
    });
  }

  void pickPhoto(String photoType) async {
    List<PlatformFile> files =
        await CustomFilePicker.pickImages(isMultiple: false);

    if (files.isNotEmpty) {
      if (photoType == "uniform") {
        setState(() {
          uniformFile = files[0];
        });

        String res = await showDialog(
            context: context,
            builder: (_) {
              return CustomPopup(
                title: "Update Photo",
                onAccepted: () => Navigator.pop(context, "proceed"),
                onCancel: () => Navigator.pop(context, "cancelled"),
                acceptTitle: "Proceed",
                body:
                    Text("Do you wish to update this school's uniform photo?"),
              );
            });

        if (res == "proceed") {
          try {
            String uniformUrl = await Uploader.uploadImage(
              destination: "Schools",
              id: widget.school.id,
              platformFile: uniformFile,
            );

            await FirebaseFirestore.instance
                .collection("schools")
                .doc(widget.school.id)
                .update({
              "imageUrl": uniformUrl,
            });

            Fluttertoast.showToast(msg: "Photo Updated");

            setState(() {});
          } catch (e) {
            print(e.toString());

            Fluttertoast.showToast(msg: "An Error Occurred!");
          }
        } else {
          setState(() {
            uniformFile = null;
          });
        }
      } else if (photoType == "logo") {
        setState(() {
          logoFile = files[0];
        });

        String res = await showDialog(
            context: context,
            builder: (_) {
              return CustomPopup(
                title: "Update Logo",
                onAccepted: () => Navigator.pop(context, "proceed"),
                onCancel: () => Navigator.pop(context, "cancelled"),
                acceptTitle: "Proceed",
                body: Text("Do you wish to update the school logo?"),
              );
            });

        if (res == "proceed") {
          try {
            String logoUrl = await Uploader.uploadImage(
              destination: "Schools",
              id: widget.school.id,
              platformFile: logoFile,
            );

            await FirebaseFirestore.instance
                .collection("schools")
                .doc(widget.school.id)
                .update({
              "logo": logoUrl,
            });

            Fluttertoast.showToast(msg: "Logo Updated");

            setState(() {});
          } catch (e) {
            print(e.toString());

            Fluttertoast.showToast(msg: "An Error Occurred!");
          }
        } else {
          setState(() {
            logoFile = null;
          });
        }
      }
    }
  }

  void promptSchoolDeletion(School school) async {
    String res = await showDialog(
        context: context,
        builder: (_) {
          return CustomPopup(
            title: "Delete School",
            onAccepted: () => Navigator.pop(context, "proceed"),
            onCancel: () => Navigator.pop(context, "cancelled"),
            acceptTitle: "DELETE",
            body: Text(
                "Do you wish to delete this school permanently, ${school.name}?"),
          );
        });

    if (res == "proceed") {
      // Delete user

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("schools")
          .doc(school.id)
          .get();

      await doc.reference.delete();

      await UpdateAdminInfo().updateSchoolCount(school, false);

      Fluttertoast.showToast(msg: "Deleted Successfully!");
    } else {
      // Do Nothing...
    }
  }

  void updateSchoolInfo() async {
    setState(() {
      loading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("schools")
          .doc(widget.school.id)
          .update({
        "name": nameController.text.trim(),
        "city": city,
        "category": category,
        "country": countryController.text.trim()
      });

      Fluttertoast.showToast(msg: "Updated");

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

  Future<List<CustomLocation>> getLocations(
      BuildContext context, String filter) async {
    List<CustomLocation> locations = [];
    var result = await LoadJsonData.getJsonData(
        context: context, library: "assets/json/ke.json");

    if (filter.isNotEmpty) {
      // filter the list of maps based on the value of the given value
      var filteredResults = result
          .where((map) => map['value'] == filter.toCapitalized())
          .toList();

      for (var filteredResult in filteredResults) {
        CustomLocation customLocation = CustomLocation.fromJson(filteredResult);

        locations.add(customLocation);
      }
    } else {
      for (var res in result) {
        CustomLocation customLocation = CustomLocation.fromJson(res);

        locations.add(customLocation);
      }
    }

    return locations;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Image.network(
                  widget.school.imageUrl!,
                  height: 250.0,
                  width: size.width,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.school_outlined,
                    color: Config.customGrey,
                  ),
                ),
                Positioned.fill(
                  child: uniformFile == null
                      ? const SizedBox()
                      : Image.memory(
                          uniformFile!.bytes!,
                          height: 200.0,
                          width: 200.0,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  bottom: 10.0,
                  right: 10.0,
                  child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      elevation: 0.0,
                      color: Colors.black45,
                      child: TextButton.icon(
                          onPressed: () => pickPhoto("uniform"),
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Change",
                            style: TextStyle(color: Colors.white),
                          ))),
                )
              ],
            ),
            ExpansionTile(
              leading: InkWell(
                onTap: () => pickPhoto("logo"),
                child: Image.network(
                  widget.school.logo!,
                  height: 100.0,
                  width: 100.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.school_outlined,
                    color: Config.customGrey,
                  ),
                ),
              ),
              title: Text(widget.school.name!),
              subtitle: Text("${widget.school.city}, ${widget.school.country}"),
              children: loading
                  ? [circularProgress()]
                  : [
                      CustomTextField(
                        controller: nameController,
                        hintText: "Name",
                        title: "School Name*",
                        inputType: TextInputType.name,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: DropdownSearch<String>(
                          popupProps: const PopupProps.menu(
                            showSelectedItems: true,
                          ),
                          items: const ["School", "Madrassa"],
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Category",
                              hintText: "Category",
                            ),
                          ),
                          onChanged: (str) {
                            setState(() {
                              category = str!;
                            });
                          },
                          selectedItem: category,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: DropdownSearch<CustomLocation>(
                          asyncItems: (String? filter) =>
                              getLocations(context, filter!),
                          clearButtonProps:
                              const ClearButtonProps(isVisible: true),
                          popupProps: PopupProps.menu(
                            itemBuilder: (context, customLocation, isSelected) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                child: Text(
                                  customLocation.city!,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Config.customBlue
                                          : Colors.black),
                                ),
                              );
                            },
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              controller: cityController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Config.customGrey,
                                  ),
                                  onPressed: () {
                                    cityController.clear();
                                  },
                                ),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              city = value!.city!;
                            });
                          },
                          itemAsString: (item) => item.city!,
                          // compareFn: (item, selectedItem) =>
                          //     item.id == selectedItem.id,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'City *',
                              filled: true,
                              fillColor: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor,
                            ),
                          ),
                        ),
                      ),
                      CustomTextField(
                        controller: countryController,
                        hintText: "Country",
                        title: "Country*",
                        inputType: TextInputType.name,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => updateSchoolInfo(),
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
                            onPressed: () =>
                                promptSchoolDeletion(widget.school),
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
          ],
        ),
      ),
    );
  }
}
