import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/POS/models/pos_user.dart';
import 'package:kindah/widgets/custom_button.dart';
import '../../../widgets/progress_widget.dart';

import '../../../pages/otp_screen.dart';
import '../../responsive.dart';
import '../../../config.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController storeIDController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isObscure = true;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameController.dispose();
    storeIDController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<String> createUser(UserCredential userCredential) async {
    // Create POS_User

    POSUser posUser = POSUser(
        userID: userCredential.user!.uid,
        username: usernameController.text.trim(),
        storeID: storeIDController.text.trim(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        phone: phoneController.text.trim(),
        isNew: true,
        orderCount: 0,
        products: 0);

    // Then upload to firestore
    await FirebaseFirestore.instance
        .collection("POS_users")
        .doc(posUser.userID)
        .set(posUser.toMap());

    // Add default category
    await FirebaseFirestore.instance
        .collection("POS_users")
        .doc(posUser.userID)
        .collection("categories")
        .doc("categories")
        .set({
      "cat": [
        "All",
      ]
    });

    return 'success';
  }

  void performSignUp() async {
    setState(() {
      loading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+${phoneController.text.trim()}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        // ANDROID ONLY!

        // Sign the user in (or link) with the auto-generated credential
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        String res = await createUser(userCredential);

        if (res == 'success') {
          GoRouter.of(context).go("/POS/${userCredential.user!.uid}/home");

          setState(() {
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
          });
        }
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
                      phoneNumber: "+${phoneController.text.trim()}",
                    )));

        if (smsCode != "error" || smsCode != "cancelled") {
          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the auto-generated credential
          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);

          String res = await createUser(userCredential);

          if (res == 'success') {
            GoRouter.of(context).go("/POS/${userCredential.user!.uid}/home");

            setState(() {
              loading = false;
            });
          } else {
            setState(() {
              loading = false;
            });
          }
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
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Responsive(
        desktop: _buildLargeScreen(size),
        mobile: _buildSmallScreen(size),
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
    return _buildMainBody(
      size,
    );
  }

  /// Main Body
  Widget _buildMainBody(
    Size size,
  ) {
    return loading
        ? circularProgress()
        : SingleChildScrollView(
            child: Column(
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
                    'Lets create an account',
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
                            } else if (value.length > 13) {
                              return 'maximum character is 13';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        /// password
                        TextFormField(
                          controller: confirmPasswordController,
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
                            hintText: 'Confirm Password',
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value != passwordController.text) {
                              return 'The password must be same';
                            }
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            } else if (value.length < 7) {
                              return 'at least enter 6 characters';
                            } else if (value.length > 13) {
                              return 'maximum character is 13';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        /// Login Button
                        CustomButton(
                            title: "Create Account",
                            iconData: Icons.done_rounded,
                            onPressed: () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                performSignUp();
                              }
                            }),
                        SizedBox(
                          height: size.height * 0.03,
                        ),

                        /// Navigate To Login Screen
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              usernameController.clear();
                              passwordController.clear();
                              phoneController.clear();
                              confirmPasswordController.clear();
                              storeIDController.clear();
                              _formKey.currentState?.reset();
                              isObscure = true;
                            });
                            GoRouter.of(context).go("/POS/login");
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account?',
                              style: TextStyle(color: Config.customGrey),
                              children: [
                                TextSpan(
                                    text: " Log in",
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
