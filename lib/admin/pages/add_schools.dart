import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/common_functions/load_json.dart';
import 'package:kindah/common_functions/update_admin_info.dart';
import 'package:kindah/models/custom_location.dart';
import 'package:kindah/models/school.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';

import '../../common_functions/custom_file_picker.dart';
import '../../common_functions/uploader.dart';
import '../../config.dart';
import '../../dialog/error_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_scrollbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';

class AddSchools extends StatefulWidget {
  final bool isAdmin;
  const AddSchools({super.key, required this.isAdmin});

  @override
  State<AddSchools> createState() => _AddSchoolsState();
}

class _AddSchoolsState extends State<AddSchools> {
  final ScrollController _controller = ScrollController();
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

    countryController.text = "Kenya";
  }

  void pickPhoto(String photoType) async {
    List<PlatformFile> files =
        await CustomFilePicker.pickImages(isMultiple: false);

    if (files.isNotEmpty) {
      if (photoType == "uniform") {
        setState(() {
          uniformFile = files[0];
        });
      } else if (photoType == "logo") {
        setState(() {
          logoFile = files[0];
        });
      }
    }
  }

  void saveSchoolToFirestore() async {
    setState(() {
      loading = true;
    });

    try {
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      String uniformUrl = await Uploader.uploadImage(
        destination: "Schools",
        id: timestamp.toString(),
        platformFile: uniformFile,
      );

      String logoUrl = await Uploader.uploadImage(
        destination: "Schools",
        id: timestamp.toString(),
        platformFile: logoFile,
      );

      School school = School(
        id: timestamp.toString(),
        timestamp: timestamp,
        name: nameController.text.trim(),
        imageUrl: uniformUrl,
        logo: logoUrl,
        city: city,
        category: category,
        country: countryController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection("schools")
          .doc(school.id)
          .set(school.toMap());

      await UpdateAdminInfo().updateSchoolCount(school, true);

      showCustomToast(
          "${nameController.text.trim()} added to the database successfully!");

      setState(() {
        uniformFile = null;
        logoFile = null;
        nameController.clear();
        city = "";
        cityController.clear();
        countryController.clear();
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
                  widget.isAdmin
                      ? const CustomHeader(
                          action: [],
                        )
                      : const UserCustomHeader(
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
                            Text(
                              "School Logo",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .apply(color: Config.customGrey),
                            ),
                            Stack(
                              children: [
                                logoFile == null
                                    ? const Icon(
                                        Icons.image_outlined,
                                        color: Colors.black12,
                                        size: 100.0,
                                      )
                                    : Image.memory(
                                        logoFile!.bytes!,
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
                                          onPressed: () => pickPhoto("logo"),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            logoFile != null
                                ? TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        logoFile = null;
                                      });
                                    },
                                    label: const Text(
                                      "Remove Logo",
                                      style:
                                          TextStyle(color: Config.customBlue),
                                    ),
                                    icon: const Icon(
                                      Icons.delete_rounded,
                                      color: Config.customBlue,
                                    ))
                                : Container(),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              "School Uniform",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .apply(color: Config.customGrey),
                            ),
                            Stack(
                              children: [
                                uniformFile == null
                                    ? const Icon(
                                        Icons.image_outlined,
                                        color: Colors.black12,
                                        size: 100.0,
                                      )
                                    : Image.memory(
                                        uniformFile!.bytes!,
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
                                          onPressed: () => pickPhoto("uniform"),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            uniformFile != null
                                ? TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        uniformFile = null;
                                      });
                                    },
                                    label: const Text(
                                      "Remove Photo",
                                      style:
                                          TextStyle(color: Config.customBlue),
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
                              hintText: "Name",
                              title: "School Name*",
                              inputType: TextInputType.name,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: DropdownSearch<String>(
                                popupProps: const PopupProps.menu(
                                  showSelectedItems: false,
                                ),
                                items: const ["School", "Madrassa"],
                                dropdownDecoratorProps:
                                    const DropDownDecoratorProps(
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
                                // selectedItem: ,
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: DropdownSearch<CustomLocation>(
                                asyncItems: (String? filter) =>
                                    getLocations(context, filter!),
                                clearButtonProps:
                                    const ClearButtonProps(isVisible: true),
                                popupProps: PopupProps.menu(
                                  itemBuilder:
                                      (context, customLocation, isSelected) {
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
                                        .fillColor, //gsutil cors set cors.json gs://kindahclothing
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
                              height: 30.0,
                            ),
                            CustomButton(
                              title: "SAVE",
                              iconData: Icons.done_rounded,
                              onPressed: () {
                                if (nameController.text.isNotEmpty &&
                                    city.isNotEmpty &&
                                    logoFile != null &&
                                    uniformFile != null &&
                                    countryController.text.isNotEmpty) {
                                  saveSchoolToFirestore();
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
