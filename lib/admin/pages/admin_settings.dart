import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

import '../../config.dart';
import '../../models/admin.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_scrollbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_wrapper.dart';
import '../widgets/custom_header.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  final ScrollController _controller = ScrollController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool loading = false;
  String phoneNumber = "";

  void updateAdminInfo(Admin admin) async {
    setState(() {
      loading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("admins")
          .doc(admin.id)
          .update({
        "username": nameController.text.trim(),
        "phone": phoneNumber.split("+").last.trim(),
        "email": emailController.text.trim()
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

      Fluttertoast.showToast(msg: "An ERROR Occurred!");
    }
  }

  @override
  Widget build(BuildContext context) {
    Admin admin = context.watch<AdminProvider>().admin;
    nameController.text = admin.username!;
    emailController.text = admin.email!;
    phoneNumber = "+${admin.phone!}";
    phoneController.text = admin.phone!.substring(3);

    return CustomScrollBar(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomHeader(
              action: [
                CustomButton(
                  title: "Logout",
                  iconData: Icons.logout_outlined,
                  height: 30.0,
                  onPressed: () {
                    context.go("/");
                  },
                )
              ],
            ),
            loading
                ? circularProgress()
                : Align(
                    alignment: Alignment.topLeft,
                    child: CustomWrapper(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Fields marked * are Required",
                              style: TextStyle(
                                  fontSize: 12.0, color: Config.customGrey),
                            ),
                            CustomTextField(
                              controller: nameController,
                              hintText: "Username",
                              title: "Username *",
                              inputType: TextInputType.name,
                            ),
                            CustomTextField(
                              controller: emailController,
                              hintText: "example@domain.com",
                              title: "Email *",
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
                            const SizedBox(
                              height: 30.0,
                            ),
                            CustomButton(
                              title: "Update",
                              iconData: Icons.done_rounded,
                              onPressed: () {
                                if (nameController.text.isNotEmpty &&
                                    phoneNumber.isNotEmpty) {
                                  updateAdminInfo(admin);
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
      ),
    );
  }
}
