import 'package:flutter/material.dart';

import '../config.dart';
import '../widgets/custom_wrapper.dart';

class UserSelector extends StatefulWidget {
  const UserSelector({super.key});

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  bool isExpanded = false;

  Widget choiceDesign(Size size, UserChoice choice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Config.customBlue)),
        child: ListTile(
          onTap: () => Navigator.pop(context, choice.url),
          leading: Icon(
            choice.iconData,
            color: Config.customGrey,
          ),
          title: Text(
            choice.title!,
            style: const TextStyle(color: Config.customBlue),
          ),
          subtitle: Text(choice.description!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: CustomWrapper(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Hero(
                      tag: "assets/images/logo.png",
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: 200.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text(
                      "Continue As...",
                      style: TextStyle(
                          fontSize: 22.0,
                          color: Config.customGrey,
                          fontWeight: FontWeight.w700),
                    ),
                    // ========== CHOICES ========== //
                    choiceDesign(size, userChoices[0]),
                    ExpansionTile(
                      onExpansionChanged: (value) {
                        setState(() {
                          isExpanded = value;
                        });
                      },
                      collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      collapsedIconColor: Colors.white,
                      leading: Icon(
                        Icons.badge_outlined,
                        color: isExpanded ? Config.customBlue : Colors.white,
                      ),
                      childrenPadding: const EdgeInsets.only(left: 10.0),
                      collapsedBackgroundColor: Config.customBlue,
                      backgroundColor: Config.customBlue.withOpacity(0.1),
                      title: Text(
                        userChoices[1].title!,
                        style: TextStyle(
                            // fontWeight: FontWeight.normal,
                            color: isExpanded
                                ? Config.customBlue
                                : Colors.white70),
                      ),
                      subtitle: Text(
                        userChoices[1].description!,
                        style: TextStyle(
                            color: isExpanded
                                ? Config.customBlue
                                : Colors.white70),
                      ),
                      children: [
                        choiceDesign(size, userChoices[1]),
                        choiceDesign(size, userChoices[2])
                      ],
                    )
                    // TextButton(
                    //     onPressed: () async {
                    //       // FIRST Add verified to the documents in db
                    //       // QuerySnapshot querySnapshot = await FirebaseFirestore
                    //       //     .instance
                    //       //     .collection("users")
                    //       //     .get();

                    //       // querySnapshot.docs.forEach((element) async {
                    //       //   await element.reference.set(
                    //       //       {"verified": false, "devices": []},
                    //       //       SetOptions(merge: true));
                    //       // });

                    //       // print("FINISHED 1st Step");

                    //       // SECOND: Go to Account Model and change String to List

                    //       // THIRD: Go to Add users and make the userrole multiselection

                    //       // FORTH: Check for any userRole queries in the system

                    //       // Also check EDIT USERS section for the user Roles
                    //     },
                    //     child: Text("Update Users"))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserChoice {
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? url;
  final IconData? iconData;

  UserChoice(
      {this.title, this.description, this.imageUrl, this.url, this.iconData});
}

List<UserChoice> userChoices = [
  UserChoice(
      title: "Customer",
      description: "Shop and place orders.",
      url: "/home",
      imageUrl: "",
      iconData: Icons.person_outline_rounded),
  UserChoice(
      title: "Staff",
      description: "Create and process orders for customers.",
      url: "/staff",
      imageUrl: "",
      iconData: Icons.badge_outlined),
  UserChoice(
      title: "ADMIN",
      description: "Manage users and received orders.",
      url: "/admin_login",
      imageUrl: "",
      iconData: Icons.admin_panel_settings_outlined)
];
