import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/custom_textfield.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../common_functions/phone_validator.dart';
import '../common_functions/user_role_solver.dart';
import '../widgets/custom_popup.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController idController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool loading = false;
  String phoneNumber = "";

  Future<String> setUserRole(Account account) async {
    // Prompt user to pick a role //

    if (account.userRole!.length > 1) {
      return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return OptionsPopup(
            title: "Choose Role",
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Pick a role and proceed to the dashboard"),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(account.userRole!.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Config.customGrey)),
                        child: ListTile(
                          onTap: () =>
                              Navigator.pop(context, account.userRole![index]),
                          title:
                              Text(toHumanReadable(account.userRole![index])),
                        ),
                      ),
                    );
                  }),
                )
              ],
            ),
          );
        },
      );
    } else {
      return account.userRole!.first;
    }
  }

  void controlUserSignIn() async {
    setState(() {
      loading = true;
    });

    try {
      QuerySnapshot userResults = await FirebaseFirestore.instance
          .collection("users")
          .where("phone", isEqualTo: phoneNumber.split("+").last.trim())
          .where("idNumber", isEqualTo: idController.text.trim())
          .get();

      if (userResults.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(userResults.docs[0].id)
            .get();

        Account account = Account.fromDocument(documentSnapshot);

        if (account.verified!) {
          String preferedRole = await setUserRole(account);

          GoRouter.of(context)
              .go("/users/${preferedRole}s/${account.id}/dashboard");

          setState(() {
            loading = false;
          });
        } else {
          // Bypass user phone verification

          await documentSnapshot.reference.update({
            "verified": true,
          });

          String preferedRole = await setUserRole(account);

          GoRouter.of(context)
              .go("/users/${preferedRole}s/${account.id}/dashboard");

          setState(() {
            loading = false;
          });

          // ==============================
          // await FirebaseAuth.instance.verifyPhoneNumber(
          //   phoneNumber: "+${account.phone}",
          //   verificationCompleted: (PhoneAuthCredential credential) async {
          //     // ANDROID ONLY!

          //     // Sign the user in (or link) with the auto-generated credential
          //     await FirebaseAuth.instance.signInWithCredential(credential);

          //     await documentSnapshot.reference.update({
          //       "verified": true,
          //     });

          //     String preferedRole = await setUserRole(account);

          //     GoRouter.of(context)
          //         .go("/users/${preferedRole}s/${account.id}/dashboard");

          //     setState(() {
          //       loading = false;
          //     });
          //   },
          //   verificationFailed: (FirebaseAuthException e) {
          //     if (e.code == 'invalid-phone-number') {
          //       print('The provided phone number is not valid.');
          //     }

          //     print("========FirebaseAuthException===========");

          //     print(e.toString());

          //     print("========FirebaseAuthException===========");

          //     Fluttertoast.showToast(msg: "Verification Failed :(");

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
          //                   phoneNumber: "+${account.phone}",
          //                 )));

          //     if (smsCode != "error" || smsCode != "cancelled") {
          //       // Create a PhoneAuthCredential with the code
          //       PhoneAuthCredential credential = PhoneAuthProvider.credential(
          //           verificationId: verificationId, smsCode: smsCode);

          //       // Sign the user in (or link) with the credential
          //       await FirebaseAuth.instance.signInWithCredential(credential);

          //       await documentSnapshot.reference.update({
          //         "verified": true,
          //       });

          //       String preferedRole = await setUserRole(account);

          //       GoRouter.of(context)
          //           .go("/users/${preferedRole}s/${account.id}/dashboard");

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
        }
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
                          "assets/images/verify.png",
                          width: 200.0,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          "Staff Sign In",
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
                            if (phoneNumber.isNotEmpty &&
                                idController.text.isNotEmpty) {
                              bool isPhoneValid =
                                  PhoneValidator.validatePhoneNumber(
                                      phoneNumber);
                              if (isPhoneValid) {
                                controlUserSignIn();
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
                              Fluttertoast.showToast(msg: "Fill in the form");
                            }
                          },
                        ),
                        SizedBox(
                          height: size.height * 0.1,
                        ),
                        const Text(
                          "By signing in, you agree to our terms and conditions.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12.0, color: Config.customGrey),
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
