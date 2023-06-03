import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/common_functions/custom_file_picker.dart';
import 'package:kindah/common_functions/update_admin_info.dart';
import 'package:kindah/common_functions/uploader.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/models/admin.dart';
import 'package:kindah/providers/admin_provider.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/custom_textfield.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../widgets/custom_header.dart';

class AddUsers extends StatefulWidget {
  final bool isAdmin;
  const AddUsers({
    super.key,
    required this.isAdmin,
  });

  @override
  State<AddUsers> createState() => _AddUsersState();
}

class _AddUsersState extends State<AddUsers> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController idController = TextEditingController();
  bool loading = false;
  PlatformFile? file;
  String userRole = "shop_attendant";

  void pickPhoto() async {
    List<PlatformFile> files =
        await CustomFilePicker.pickImages(isMultiple: false);

    if (files.isNotEmpty) {
      setState(() {
        file = files[0];
      });
    }
  }

  void saveUserToFirestore() async {
    setState(() {
      loading = true;
    });

    try {
      String downloadUrl = "";

      if (file != null) {
        downloadUrl = await Uploader.uploadImage(
          destination: "Users",
          id: idController.text.trim(),
          platformFile: file,
        );
      }

      Account account = Account(
          id: idController.text.trim(),
          username: nameController.text.trim(),
          idNumber: idController.text.trim(),
          photoUrl: downloadUrl,
          email: emailController.text.trim(),
          userRole: userRole,
          phone: phoneController.text.trim(),
          isNew: true,
          timestamp: DateTime.now().millisecondsSinceEpoch);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.id)
          .set(account.toMap());

      await UpdateAdminInfo().updateUserCount(account, true);

      Fluttertoast.showToast(
          msg:
              "${nameController.text.trim()} added to the database successfully!");

      setState(() {
        file = null;
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        idController.clear();
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

  @override
  Widget build(BuildContext context) {
    return loading
        ? circularProgress()
        : SingleChildScrollView(
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
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage: const AssetImage(
                                    "assets/images/profile.png"),
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                radius: 50.0,
                                foregroundImage: file == null
                                    ? null
                                    : MemoryImage(file!.bytes!),
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
                            hintText: "Name",
                            title: "Name*",
                            inputType: TextInputType.name,
                          ),
                          CustomTextField(
                            controller: emailController,
                            hintText: "Email Address (Optional)",
                            title: "Email (Optional)",
                            inputType: TextInputType.emailAddress,
                          ),
                          CustomTextField(
                            controller: phoneController,
                            hintText: "Phone (2547XXXXX)",
                            title: "Phone Number*",
                            inputType: TextInputType.number,
                          ),
                          CustomTextField(
                            controller: idController,
                            hintText: "ID Number",
                            title: "ID Number*",
                            inputType: TextInputType.number,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: DropdownSearch<String>(
                              popupProps: const PopupProps.menu(
                                showSelectedItems: false,
                              ),
                              items: const [
                                "Shop Attendant",
                                "Fabric Cutter",
                                "Tailor",
                                "Finisher"
                              ],
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "User Role",
                                  hintText: "User Role",
                                ),
                              ),
                              onChanged: (str) {
                                setState(() {
                                  userRole =
                                      str!.toLowerCase().split(" ").join("_");
                                });

                                print(userRole);
                              },
                              // selectedItem: ,
                            ),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          CustomButton(
                            title: "SAVE",
                            iconData: Icons.done_rounded,
                            onPressed: () {
                              if (nameController.text.isNotEmpty &&
                                  phoneController.text.isNotEmpty &&
                                  idController.text.isNotEmpty) {
                                saveUserToFirestore();
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
