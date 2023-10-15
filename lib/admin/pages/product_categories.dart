import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/config.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/custom_scrollbar.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../../widgets/custom_textfield.dart';
import '../widgets/custom_header.dart';

class ProductCategories extends StatefulWidget {
  final bool isAdmin;
  const ProductCategories({super.key, required this.isAdmin});

  @override
  State<ProductCategories> createState() => _ProductCategoriesState();
}

class _ProductCategoriesState extends State<ProductCategories> {
  TextEditingController categoryController = TextEditingController();
  final ScrollController _controller = ScrollController();

  void removeCategory(List<dynamic> categories, int index) async {
    categories.remove(categories[index]);

    await FirebaseFirestore.instance
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

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("categories")
          .doc("categories")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<dynamic> categories = snapshot.data!["cat"];

          return CustomScrollBar(
            controller: _controller,
            child: SingleChildScrollView(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.isAdmin
                      ? CustomHeader(
                          action: [
                            CustomButton(
                              onPressed: () =>
                                  promptAddCategory(context, categories),
                              title: "Add Category",
                              iconData: Icons.add,
                              height: 30.0,
                            )
                          ],
                        )
                      : UserCustomHeader(
                          action: [
                            CustomButton(
                              onPressed: () =>
                                  promptAddCategory(context, categories),
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
            ),
          );
        }
      },
    );
  }
}
