import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../config.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/ecomm_appbar.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/pos_custom_header.dart';

class POSCategoryPage extends StatefulWidget {
  final String userID;
  const POSCategoryPage({super.key, required this.userID});

  @override
  State<POSCategoryPage> createState() => _POSCategoryPageState();
}

class _POSCategoryPageState extends State<POSCategoryPage> {
  TextEditingController categoryController = TextEditingController();

  void removeCategory(List<dynamic> categories, int index) async {
    categories.remove(categories[index]);

    await FirebaseFirestore.instance
        .collection("POS_users")
        .doc(widget.userID)
        .collection("categories")
        .doc("categories")
        .update({
      "cat": categories,
    });

    setState(() {});
  }

  void addCategory(List<dynamic> categories) async {
    categories.add(categoryController.text.trim());

    await FirebaseFirestore.instance
        .collection("POS_users")
        .doc(widget.userID)
        .collection("categories")
        .doc("categories")
        .update({"cat": categories});

    setState(() {});
  }

  void promptAddCategory(BuildContext context, List<dynamic> categories) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            "Add Category",
            style: TextStyle(
                color: Config.customGrey, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: categoryController,
                hintText: "Name",
                title: "Category Name",
                inputType: TextInputType.name,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  categoryController.clear();
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
                if (categoryController.text.isNotEmpty) {
                  Navigator.pop(context);

                  addCategory(categories);
                } else {
                  Fluttertoast.showToast(msg: "Please fill the form");
                }
              },
              title: "SAVE",
              iconData: Icons.done_rounded,
              height: 30.0,
            )
          ],
        );
      },
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
          title: "My Categories",
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("POS_users")
            .doc(widget.userID)
            .collection("categories")
            .doc("categories")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          } else {
            List<dynamic> categories = snapshot.data!["cat"];

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  POSCustomHeader(
                    title: "Categories",
                    action: [
                      CustomButton(
                        onPressed: () => promptAddCategory(context, categories),
                        title: "Add Category",
                        iconData: Icons.add,
                        height: 30.0,
                      )
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: CustomWrapper(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(categories.length, (index) {
                          bool isAll = categories[index] == "All";
                          return ListTile(
                            leading: Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Config.customGrey),
                            ),
                            title: Text(categories[index]),
                            subtitle: Container(
                              width: size.width,
                              height: 1.0,
                              color: Colors.black12,
                            ),
                            trailing: isAll
                                ? null
                                : TextButton.icon(
                                    onPressed: () =>
                                        removeCategory(categories, index),
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "Remove",
                                      style: TextStyle(color: Colors.red),
                                    )),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
