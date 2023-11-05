import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kindah/common_functions/custom_file_picker.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/common_functions/phone_validator.dart';
import 'package:kindah/common_functions/update_admin_info.dart';
import 'package:kindah/common_functions/uploader.dart';
import 'package:kindah/common_functions/user_role_solver.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/custom_popup.dart';
import 'package:kindah/widgets/custom_textfield.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../../dialog/error_dialog.dart';
import '../../widgets/custom_scrollbar.dart';
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
  TextEditingController idController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final ScrollController _controller = ScrollController();
  bool loading = false;
  PlatformFile? file;
  List<String> selectedUserRoles = [];
  String phoneNumber = "";

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
          userRole: selectedUserRoles.map((e) => toCoded(e)).toList(),
          phone: phoneNumber.split("+").last.trim().split(" ").join(""),
          isNew: true,
          verified: false,
          devices: [],
          timestamp: DateTime.now().millisecondsSinceEpoch);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.id)
          .set(account.toMap());

      await UpdateAdminInfo().updateUserCount(account, true);

      showCustomToast(
          "${nameController.text.trim()} added to the database successfully!");

      setState(() {
        file = null;
        nameController.clear();
        emailController.clear();
        phoneNumber = "";
        phoneController.clear();
        idController.clear();
        selectedUserRoles.clear();
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
                              title: "Name*",
                              inputType: TextInputType.name,
                            ),
                            CustomTextField(
                              controller: emailController,
                              hintText: "Email Address (Optional)",
                              title: "Email (Optional)",
                              inputType: TextInputType.emailAddress,
                            ),
                            CustomPhoneField(
                              controller: phoneController,
                              onChanged: (phone) {
                                setState(() {
                                  phoneNumber = phone.completeNumber;
                                });
                              },
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
                              child: DropdownSearch<String>.multiSelection(
                                items: userRoles,
                                popupProps: const PopupPropsMultiSelection.menu(
                                  showSelectedItems: true,
                                ),
                                dropdownDecoratorProps:
                                    const DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "User Roles",
                                    hintText: "User Roles",
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    selectedUserRoles = value;
                                  });
                                },
                                selectedItems: selectedUserRoles,
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
                                    phoneNumber.isNotEmpty &&
                                    selectedUserRoles.isNotEmpty &&
                                    idController.text.isNotEmpty) {
                                  bool isPhoneValid =
                                      PhoneValidator.validatePhoneNumber(
                                          phoneNumber);
                                  if (isPhoneValid) {
                                    saveUserToFirestore();
                                  } else {
                                    String initialNumber =
                                        PhoneValidator.initialPhoneNumber(
                                            phoneNumber);

                                    String correctNumber =
                                        PhoneValidator.correctPhoneNumber(
                                            phoneNumber);

                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return ErrorPopup(
                                            title: "ERROR",
                                            body: Text(
                                                "Wrong phone number. Start with '7' while typing phone number, \ni.e 7xx-xxx-xxx, 712345678 and NOT 07xx-xxx-xxx. \n\nYour input is '$initialNumber', maybe try '$correctNumber'"),
                                          );
                                        });
                                  }
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
