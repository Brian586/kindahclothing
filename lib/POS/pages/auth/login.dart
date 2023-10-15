import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../../../pages/otp_screen.dart';
import '../../responsive.dart';
import '../../../config.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isObscure = true;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<String> checkForUser() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("POS_users")
        .where("phone", isEqualTo: phoneController.text.trim())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return "";
    }
  }

  void performLogin() async {
    setState(() {
      loading = true;
    });

    String userID = await checkForUser();

    if (userID.isNotEmpty) {
      try {
        // Bypass phone verification

        GoRouter.of(context).go("/POS/$userID/home");

        setState(() {
          loading = false;
        });

        // =========================
        // await FirebaseAuth.instance.verifyPhoneNumber(
        //   phoneNumber: "+${phoneController.text.trim()}",
        //   verificationCompleted: (PhoneAuthCredential credential) async {
        //     // ANDROID ONLY!

        //     // Sign the user in (or link) with the auto-generated credential
        //     final UserCredential userCredential =
        //         await FirebaseAuth.instance.signInWithCredential(credential);

        //     GoRouter.of(context).go("/POS/${userCredential.user!.uid}/home");

        //     setState(() {
        //       loading = false;
        //     });
        //   },
        //   verificationFailed: (FirebaseAuthException e) {
        //     if (e.code == 'invalid-phone-number') {
        //       print('The provided phone number is not valid.');
        //     }

        //     Fluttertoast.showToast(msg: "An ERROR occured :(");

        //     setState(() {
        //       loading = false;
        //     });
        //   },
        //   codeSent: (String verificationId, int? resendToken) async {
        //     // Update the UI - wait for the user to enter the SMS code
        //     String smsCode = await Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => OTPScreen(
        //                   phoneNumber: "+${phoneController.text.trim()}",
        //                 )));

        //     if (smsCode != "error" || smsCode != "cancelled") {
        //       // Create a PhoneAuthCredential with the code
        //       PhoneAuthCredential credential = PhoneAuthProvider.credential(
        //           verificationId: verificationId, smsCode: smsCode);

        //       // Sign the user in (or link) with the auto-generated credential
        //       final UserCredential userCredential =
        //           await FirebaseAuth.instance.signInWithCredential(credential);

        //       GoRouter.of(context).go("/POS/${userCredential.user!.uid}/home");

        //       setState(() {
        //         loading = false;
        //       });
        //     } else {
        //       setState(() {
        //         loading = false;
        //       });
        //     }
        //   },
        //   codeAutoRetrievalTimeout: (String verificationId) {
        //     setState(() {
        //       loading = false;
        //     });
        //   },
        // );
      } catch (e) {
        print(e.toString());
      }
    } else {
      Fluttertoast.showToast(msg: "User does not exist");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Responsive(
            desktop: _buildLargeScreen(size),
            mobile: _buildSmallScreen(size),
          ),
        ),
      ),
    );
  }

  /// For large screens
  Widget _buildLargeScreen(
    Size size,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMainBody(
            size,
          ),
        ),
        Expanded(
          child: Image.asset(
            'assets/pos/side_image.jpg',
            height: size.height * 1,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  /// For Small screens
  Widget _buildSmallScreen(
    Size size,
  ) {
    return Center(
      child: _buildMainBody(
        size,
      ),
    );
  }

  /// Main Body
  Widget _buildMainBody(
    Size size,
  ) {
    return SafeArea(
      child: loading
          ? circularProgress()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: size.width / 2,
                    height: 100.0,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: size.height * 0.030,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
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

                        /// password
                        TextFormField(
                          controller: passwordController,
                          obscureText: isObscure,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isObscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: isObscure
                                  ? () {
                                      setState(() {
                                        isObscure = false;
                                      });
                                    }
                                  : () {
                                      setState(() {
                                        isObscure = true;
                                      });
                                    },
                            ),
                            hintText: 'Password',
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            } else if (value.length < 7) {
                              return 'at least enter 6 characters';
                            } else if (value.length > 17) {
                              return 'maximum character is 17';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        /// Login Button
                        CustomButton(
                          title: "Login",
                          iconData: Icons.done_rounded,
                          onPressed: () async {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              performLogin();
                            }
                          },
                        ),
                        SizedBox(
                          height: size.height * 0.03,
                        ),

                        /// Navigate To Login Screen
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              phoneController.clear();
                              passwordController.clear();
                              _formKey.currentState?.reset();
                              isObscure = true;
                            });
                            GoRouter.of(context).go("/POS/signup");
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'New store owner?',
                              style: TextStyle(color: Config.customGrey),
                              children: [
                                TextSpan(
                                    text: " Create admin account",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
