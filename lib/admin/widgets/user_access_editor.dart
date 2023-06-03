import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/config.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../../models/account.dart';

class UserAccessEditor extends StatefulWidget {
  final Account? account;
  const UserAccessEditor({super.key, this.account});

  @override
  State<UserAccessEditor> createState() => _UserAccessEditorState();
}

class _UserAccessEditorState extends State<UserAccessEditor> {
  List<dynamic> selectedDrawerItems = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    getUserRights();
  }

  Future<void> getUserRights() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.account!.id)
        .collection("access_rights")
        .doc("access_rights")
        .get();

    setState(() {
      loading = false;
      if (documentSnapshot.exists) {
        selectedDrawerItems = documentSnapshot["items"];
      }
    });
  }

  Future<void> saveAccessRights() async {
    if (selectedDrawerItems.isNotEmpty) {
      setState(() {
        loading = true;
      });

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.account!.id)
          .collection("access_rights")
          .doc("access_rights")
          .get();

      if (doc.exists) {
        // Update Doc

        await doc.reference.update({"items": selectedDrawerItems});

        Fluttertoast.showToast(msg: "Updated Successfully!");

        setState(() {
          loading = false;
        });
      } else {
        // Create Doc

        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.account!.id)
            .collection("access_rights")
            .doc("access_rights")
            .set({"items": selectedDrawerItems});

        Fluttertoast.showToast(msg: "Updated Successfully!");

        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget groupedAccessItems(String title, int firstIndex, int lastIndex) {
    List<AccessItem> groupedItems = accessItems
        .where((item) => item.index! >= firstIndex && item.index! <= lastIndex)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            groupedItems[0].title!.split(" ").first,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(groupedItems.length, (index) {
              return CheckboxListTile(
                title: Text(groupedItems[index].title!),
                controlAffinity: ListTileControlAffinity.leading,
                value: selectedDrawerItems.contains(firstIndex + index),
                onChanged: (value) {
                  if (value!) {
                    setState(() {
                      selectedDrawerItems.add(firstIndex + index);
                    });
                  } else {
                    setState(() {
                      selectedDrawerItems.remove(firstIndex + index);
                    });
                  }
                },
              );
            }),
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Divider(
          color: Config.customGrey,
          height: 10.0,
          thickness: .5,
        ),
      ],
    );
  }

  Widget organiseChoice(int index) {
    if (index == 19 || index == 20) {
      return CheckboxListTile(
        title: Text(accessItems[index].title!),
        controlAffinity: ListTileControlAffinity.leading,
        value: selectedDrawerItems.contains(index),
        onChanged: (value) {
          if (value!) {
            setState(() {
              selectedDrawerItems.add(index);
            });
          } else {
            setState(() {
              selectedDrawerItems.remove(index);
            });
          }
        },
      );
    } else if (index == 0) {
      return groupedAccessItems("Orders", 0, 3);
    } else if (index == 4) {
      return groupedAccessItems("Schools", 4, 6);
    } else if (index == 7) {
      return groupedAccessItems("Uniforms", 7, 9);
    } else if (index == 10) {
      return groupedAccessItems("Users", 10, 12);
    } else if (index == 13) {
      return groupedAccessItems("Payments", 13, 14);
    } else if (index == 15) {
      return groupedAccessItems("Ecommerce Products", 15, 18);
    } else {
      return Container();
    }
  }

  Widget accessChoices() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(accessItems.length, (index) {
        return organiseChoice(index);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomWrapper(
      child: loading
          ? circularProgress()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Config.customGrey, width: 1.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          "Access Rights: ${widget.account!.username}, ${widget.account!.userRole!.split("_").join(" ")}",
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                            "Select what ${widget.account!.username} is allowed to access from the User Panel"),
                      ),
                      const Divider(
                        color: Config.customGrey,
                        height: 10.0,
                        thickness: .5,
                      ),
                      accessChoices()
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                CustomButton(
                  onPressed: () => saveAccessRights(),
                  title: "Save",
                  iconData: Icons.done_rounded,
                )
              ],
            ),
    );
  }
}

class AccessItem {
  final String? title;
  final int? index;

  AccessItem({this.title, this.index});
}

List<AccessItem> accessItems = [
  AccessItem(
    title: "Orders Listing",
    index: 0,
  ),
  AccessItem(
    title: "Order Status",
    index: 1,
  ),
  AccessItem(
    title: "Add Orders",
    index: 2,
  ),
  AccessItem(
    title: "Edit Orders",
    index: 3,
  ),
  AccessItem(
    title: "Schools Listing",
    index: 4,
  ),
  AccessItem(
    title: "Add Schools",
    index: 5,
  ),
  AccessItem(
    title: "Edit Schools",
    index: 6,
  ),
  AccessItem(
    title: "Uniforms Listing",
    index: 7,
  ),
  AccessItem(
    title: "Add Uniforms",
    index: 8,
  ),
  AccessItem(
    title: "Edit Uniforms",
    index: 9,
  ),
  AccessItem(
    title: "Users Listing",
    index: 10,
  ),
  AccessItem(
    title: "Add Users",
    index: 11,
  ),
  AccessItem(
    title: "Edit Users",
    index: 12,
  ),
  AccessItem(
    title: "Payments Listing",
    index: 13,
  ),
  AccessItem(
    title: "Advance Payments",
    index: 14,
  ),
  AccessItem(
    title: "Products Listing",
    index: 15,
  ),
  AccessItem(
    title: "Add Products",
    index: 16,
  ),
  AccessItem(
    title: "Edit Products",
    index: 17,
  ),
  AccessItem(
    title: "Add Product Categories",
    index: 18,
  ),
  AccessItem(
    title: "Add Tarrifs",
    index: 19,
  ),
  AccessItem(
    title: "Inventory",
    index: 20,
  ),
];
