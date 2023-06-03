import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/pages/otp_screen.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/custom_textfield.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/admin.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController idController = TextEditingController();
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

  void promptAdminLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            "Admin Sign In",
            style: TextStyle(
                color: Config.customGrey, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  adminPasswordController.clear();
                  adminUsernameController.clear();
                });

                this.setState(() {});

                Navigator.pop(context);
              },
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Config.customBlue),
              ),
            ),
            CustomButton(
              onPressed: () async {
                if (adminPasswordController.text.isNotEmpty &&
                    adminUsernameController.text.isNotEmpty) {
                  Navigator.pop(context);

                  adminSignIn(context);
                } else {
                  Fluttertoast.showToast(msg: "Please fill the form");
                }
              },
              title: "PROCEED",
              iconData: Icons.done_rounded,
              height: 30.0,
            )
          ],
        );
      },
    );
  }

  void controlUserSignIn() async {
    setState(() {
      loading = true;
    });

    try {
      QuerySnapshot userResults = await FirebaseFirestore.instance
          .collection("users")
          .where("phone", isEqualTo: phoneController.text.trim())
          .where("idNumber", isEqualTo: idController.text.trim())
          .get();

      if (userResults.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(userResults.docs[0].id)
            .get();

        Account account = Account.fromDocument(documentSnapshot);

        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: "+${account.phone}",
          verificationCompleted: (PhoneAuthCredential credential) async {
            // ANDROID ONLY!

            // Sign the user in (or link) with the auto-generated credential
            await FirebaseAuth.instance.signInWithCredential(credential);

            GoRouter.of(context)
                .go("/users/${account.userRole}s/${account.id}/dashboard");

            setState(() {
              loading = false;
            });
          },
          verificationFailed: (FirebaseAuthException e) {
            if (e.code == 'invalid-phone-number') {
              print('The provided phone number is not valid.');
            }

            Fluttertoast.showToast(msg: "An ERROR occured :(");

            setState(() {
              loading = false;
            });
          },
          codeSent: (String verificationId, int? resendToken) async {
            // Update the UI - wait for the user to enter the SMS code
            String smsCode = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OTPScreen(
                          phoneNumber: "+${account.phone}",
                        )));

            if (smsCode != "error" || smsCode != "cancelled") {
              // Create a PhoneAuthCredential with the code
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: verificationId, smsCode: smsCode);

              // Sign the user in (or link) with the credential
              await FirebaseAuth.instance.signInWithCredential(credential);

              GoRouter.of(context)
                  .go("/users/${account.userRole}s/${account.id}/dashboard");

              setState(() {
                loading = false;
              });
            } else {
              setState(() {
                loading = false;
              });
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() {
              loading = false;
            });
          },
        );
      } else {
        Fluttertoast.showToast(msg: "User does NOT Exist :(");

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print(e.toString());

      Fluttertoast.showToast(msg: "An ERROR occured :(");

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => GoRouter.of(context).go("/dashboard"),
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
                          "assets/images/verify.png",
                          width: 200.0,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          "Sign In",
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
                          controller: phoneController,
                          hintText: "Phone (2547XXXX)",
                          title: "Phone Number",
                          inputType: TextInputType.phone,
                        ),
                        CustomTextField(
                          controller: idController,
                          hintText: "ID Number",
                          title: "ID Number",
                          inputType: TextInputType.number,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        CustomButton(
                          title: "Sign In",
                          iconData: Icons.done_rounded,
                          onPressed: () {
                            if (phoneController.text.isNotEmpty &&
                                idController.text.isNotEmpty) {
                              controlUserSignIn();
                            } else {
                              Fluttertoast.showToast(msg: "Fill in the form");
                            }
                          },
                        ),
                        SizedBox(
                          height: size.height * 0.1,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "By signing in, you agree to our terms and conditions.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.0, color: Config.customGrey),
                            ),
                            TextButton(
                              onPressed: () => promptAdminLogin(context),
                              child: const Text(
                                "Admin",
                                style: TextStyle(color: Config.customBlue),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
