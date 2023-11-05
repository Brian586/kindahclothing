import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/POS/models/pos_user.dart';

import '../../dialog/error_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/ecomm_appbar.dart';
import '../../widgets/progress_widget.dart';
import '../responsive.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/pos_custom_header.dart';

class POSSettings extends StatefulWidget {
  final String userID;
  const POSSettings({super.key, required this.userID});

  @override
  State<POSSettings> createState() => _POSSettingsState();
}

class _POSSettingsState extends State<POSSettings> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController storeIDController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();
  // TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isObscure = true;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    setUserInfo();
  }

  void setUserInfo() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("POS_users")
        .doc(widget.userID)
        .get();

    POSUser user = POSUser.fromDocument(documentSnapshot);

    setState(() {
      loading = false;
      usernameController.text = user.username!;
      storeIDController.text = user.storeID!;
      phoneController.text = user.phone!;
    });
  }

  void updateUserInfo() async {
    setState(() {
      loading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("POS_users")
          .doc(widget.userID)
          .update({
        "username": usernameController.text.trim(),
        "storeID": storeIDController.text.trim(),
        "phone": phoneController.text.trim(),
      });

      Fluttertoast.showToast(msg: "Account Info Updated Successfully!");

      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e.toString());

      showErrorDialog(context, e.toString());

      Fluttertoast.showToast(msg: "An ERROR Occurred :(");

      setState(() {
        loading = false;
      });
    }
  }

  Widget buildBody(BuildContext context, Size size) {
    return loading
        ? circularProgress()
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                POSCustomHeader(
                  title: "Account Settings",
                  action: [
                    CustomButton(
                      title: "Logout",
                      iconData: Icons.logout_outlined,
                      height: 30.0,
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        context.go("/home");
                      },
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// username or Gmail
                        TextFormField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outlined),
                            hintText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          controller: usernameController,

                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter username';
                            } else if (value.length < 4) {
                              return 'at least enter 4 characters';
                            } else if (value.length > 13) {
                              return 'maximum character is 13';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        /// Phone Number
                        TextFormField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone_android_outlined),
                            hintText: 'Phone (2547xxxxxxxx)',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          controller: phoneController,

                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone';
                            } else if (value.length < 10) {
                              return 'invalid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        /// StoreID
                        TextFormField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.store_outlined),
                            hintText: 'StoreID',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          controller: storeIDController,

                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Store ID';
                            } else if (value.length < 4) {
                              return 'at least enter 4 characters';
                            } else if (value.length > 13) {
                              return 'maximum character is 13';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        /// Login Button
                        CustomButton(
                            title: "Update Account",
                            iconData: Icons.done_rounded,
                            onPressed: () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                updateUserInfo();
                              }
                            }),
                        SizedBox(
                          height: size.height * 0.03,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget buildDesktop(BuildContext context, Size size) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CustomNavBar(
            currentPage: "settings",
            userID: widget.userID,
          ),
        ),
        Expanded(
          flex: 9,
          child: Align(
              alignment: Alignment.topLeft, child: buildBody(context, size)),
        ),
        Expanded(
          flex: 4,
          child: Container(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(size.width, kToolbarHeight),
          child: EcommGeneralAppbar(
            onBackPressed: () => context.go("/POS/${widget.userID}/home"),
            title: "General Settings",
          ),
        ),
        body: Responsive.isMobile(context)
            ? buildBody(context, size)
            : buildDesktop(context, size));
  }
}
