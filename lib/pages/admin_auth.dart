import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../config.dart';
import '../models/admin.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_wrapper.dart';
import '../widgets/progress_widget.dart';

class AdminAuth extends StatefulWidget {
  const AdminAuth({super.key});

  @override
  State<AdminAuth> createState() => _AdminAuthState();
}

class _AdminAuthState extends State<AdminAuth> {
  TextEditingController adminUsernameController = TextEditingController();
  TextEditingController adminPasswordController = TextEditingController();
  bool loading = false;

  void adminSignIn(BuildContext context) async {
    setState(() {
      loading = true;
    });

    QuerySnapshot adminResults = await FirebaseFirestore.instance
        .collection("admins")
        .where("username", isEqualTo: adminUsernameController.text.trim())
        .where("password", isEqualTo: adminPasswordController.text.trim())
        .get();

    if (adminResults.docs.isNotEmpty) {
      // Proceed to Admin Panel

      Admin admin = Admin.fromDocument(adminResults.docs[0]);

      //context.read<AdminProvider>().changeAdmin(admin);

      Fluttertoast.showToast(msg: "Welcome ${adminUsernameController.text}");

      // setState(() {
      //   loading = false;
      // });

      GoRouter.of(context).go("/admin/${admin.id}/dashboard");
    } else {
      // Cancel authentication

      Fluttertoast.showToast(msg: "Admin does NOT EXIST");

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => GoRouter.of(context).go("/"),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Config.customGrey,
          ),
        ),
      ),
      body: loading
          ? circularProgress()
          : Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: CustomWrapper(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/admin_login.png",
                          width: 200.0,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          "Admin Sign In",
                          style: TextStyle(
                              fontSize: 22.0,
                              color: Config.customGrey,
                              fontWeight: FontWeight.w700),
                        ),
                        const Text(
                          "Welcome! Please sign in to continue.",
                          style: TextStyle(
                            color: Config.customGrey,
                          ),
                        ),
                        // TextField
                        CustomTextField(
                          controller: adminUsernameController,
                          hintText: "Username",
                          title: "Username",
                          inputType: TextInputType.name,
                        ),
                        CustomTextField(
                          controller: adminPasswordController,
                          hintText: "Password",
                          title: "Password",
                          inputType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        CustomButton(
                          title: "Sign In",
                          iconData: Icons.done_rounded,
                          onPressed: () {
                            if (adminPasswordController.text.isNotEmpty &&
                                adminUsernameController.text.isNotEmpty) {
                              adminSignIn(context);
                            } else {
                              Fluttertoast.showToast(msg: "Fill in the form");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
