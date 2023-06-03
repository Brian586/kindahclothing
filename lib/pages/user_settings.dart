import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/models/user_request.dart';
import 'package:kindah/widgets/adaptive_ui.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../user_panel/widgets/user_custom_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_popup.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_wrapper.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({
    super.key,
  });

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController userRoleController = TextEditingController();
  TextEditingController requestController = TextEditingController();
  bool loading = false;

  void makeRequest(Account account) async {
    String result = await showDialog(
      context: context,
      builder: (ctx) {
        return CustomPopup(
          title: "Make Request",
          onAccepted: () {
            if (requestController.text.isNotEmpty) {
              Navigator.pop(context, "proceed");
            } else {
              Fluttertoast.showToast(msg: "Input Empty");
            }
          },
          acceptTitle: "Proceed",
          onCancel: () => Navigator.pop(context, "cancelled"),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: requestController,
                hintText: "Type something here...",
                title: "Type something",
                inputType: TextInputType.text,
              ),
            ],
          ),
        );
      },
    );

    if (result == "proceed") {
      setState(() {
        loading = true;
      });

      int timestamp = DateTime.now().millisecondsSinceEpoch;

      UserRequest request = UserRequest(
          id: timestamp.toString(),
          request: requestController.text,
          user: account.toMap(),
          timestamp: timestamp,
          status: "unread");

      await FirebaseFirestore.instance
          .collection("admins")
          .doc("0001")
          .collection("requests")
          .doc(request.id)
          .set(request.toMap());

      Fluttertoast.showToast(msg: "Request Sent Successfully!");

      setState(() {
        loading = false;
      });
    } else {
      Fluttertoast.showToast(msg: "Cancelled!");
    }
  }

  String getUserRole(Account account) {
    switch (account.userRole) {
      case "shop_attendant":
        return "Shop Attendant";
      case "fabric_cutter":
        return "Fabric Cutter";
      case "tailor":
        return "Tailor";
      case "finisher":
        return "Finisher";
      default:
        return account.userRole!;
    }
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<AccountProvider>().account;

    nameController.text = account.username!;
    emailController.text = account.email!;
    phoneController.text = account.phone!;
    idController.text = account.idNumber!;
    userRoleController.text = getUserRole(account);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const UserCustomHeader(
            action: [],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: CustomWrapper(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: loading
                    ? circularProgress()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "My Details",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Config.customGrey),
                                ),
                                SizedBox()
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          CircleAvatar(
                            backgroundImage:
                                const AssetImage("assets/images/profile.png"),
                            backgroundColor: Colors.white,
                            radius: 50.0,
                            foregroundImage: account.photoUrl! == ""
                                ? null
                                : NetworkImage(account.photoUrl!),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextField(
                            controller: nameController,
                            enabled: false,
                            keyboardType: TextInputType.name,
                            style: const TextStyle(color: Config.customGrey),
                            decoration: const InputDecoration(
                              hintText: "Name",
                              labelText: "Name",
                            ),
                          ),
                          TextField(
                            controller: emailController,
                            enabled: false,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Config.customGrey),
                            decoration: const InputDecoration(
                              hintText: "Email Address",
                              labelText: "Email Address",
                            ),
                          ),
                          TextField(
                            controller: phoneController,
                            enabled: false,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Config.customGrey),
                            decoration: const InputDecoration(
                              hintText: "Phone (2547XXXXX)",
                              labelText: "Phone Number",
                            ),
                          ),
                          TextField(
                            controller: idController,
                            enabled: false,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Config.customGrey),
                            decoration: const InputDecoration(
                              hintText: "ID Number",
                              labelText: "ID Number",
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Text(
                            "Request Amin to update your details or delete account",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Config.customGrey),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          CustomButton(
                            title: "Make Request",
                            iconData: Icons.chat_outlined,
                            height: 30.0,
                            onPressed: () => makeRequest(account),
                          ),
                          const SizedBox(
                            height: 50.0,
                          ),
                          TextButton.icon(
                            onPressed: () => context.go("/home"),
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "LOGOUT",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(
                            height: 50.0,
                          ),
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
