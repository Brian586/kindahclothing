import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/admin/widgets/custom_header.dart';
import 'package:kindah/common_functions/uploader.dart';
import 'package:kindah/models/admin.dart';
import 'package:kindah/models/product.dart';
import 'package:kindah/providers/admin_provider.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../common_functions/custom_file_picker.dart';
import '../../config.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_wrapper.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({super.key});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "";
  List<dynamic> categories = [];
  List<PlatformFile> images = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  void getCategories() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("categories")
        .doc("categories")
        .get();

    setState(() {
      categories = documentSnapshot["cat"];
    });
  }

  void pickPhotos() async {
    List<PlatformFile> files =
        await CustomFilePicker.pickImages(isMultiple: true);

    if (files.isNotEmpty) {
      for (PlatformFile file in files) {
        images.add(file);
      }
      setState(() {});
    }
  }

  void saveProductToFirestore(Admin admin) async {
    setState(() {
      loading = true;
    });

    try {
      List<String> downloadUrls = [];
      String postID = Uuid().v4();

      for (PlatformFile image in images) {
        String downloadUrl = await Uploader.uploadImage(
            destination: "Products", id: postID, platformFile: image);

        downloadUrls.add(downloadUrl);
      }

      Product product = Product(
          id: postID,
          title: titleController.text.trim(),
          currency: "KES",
          price: int.parse(priceController.text.trim()).toDouble(),
          description: descriptionController.text,
          category: selectedCategory,
          images: downloadUrls,
          publisher: admin.id,
          quantity: 1,
          searchKeys:
              titleController.text.trim().toLowerCase().split(" ").toList(),
          rating: {"rate": 0.0, "count": 0},
          timestamp: DateTime.now().millisecondsSinceEpoch);

      await FirebaseFirestore.instance
          .collection("products")
          .doc(product.id)
          .set(product.toMap());

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("admins")
          .doc(admin.id)
          .get();

      Admin updatedAdmin = Admin.fromDocument(doc);

      await FirebaseFirestore.instance
          .collection("admins")
          .doc(admin.id)
          .update({
        "products": updatedAdmin.products! + 1,
      });

      Fluttertoast.showToast(msg: "Product Uploaded Successfully!");

      setState(() {
        titleController.clear();
        priceController.clear();
        descriptionController.clear();
        selectedCategory = "";
        images.clear();
        loading = false;
      });
    } catch (e) {
      print(e.toString());

      Fluttertoast.showToast(msg: "Error uploading product :(");

      setState(() {
        loading = false;
      });
    }
  }

  Widget displayImages() {
    return images.isEmpty
        ? Container()
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(images.length, (index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Stack(
                    children: [
                      Image.memory(
                        images[index].bytes!,
                        height: 200.0,
                        width: 200.0,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 5.0,
                        right: 5.0,
                        child: CircleAvatar(
                          backgroundColor: Colors.black26,
                          radius: 20.0,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  images.remove(images[index]);
                                });
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    Admin admin = context.watch<AdminProvider>().admin;

    return loading
        ? circularProgress()
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomHeader(
                  action: [
                    CustomButton(
                      onPressed: () => pickPhotos(),
                      height: 30.0,
                      title: "Pick Photos",
                      iconData: Icons.add_a_photo_rounded,
                    )
                  ],
                ),
                displayImages(),
                Align(
                  alignment: Alignment.topLeft,
                  child: CustomWrapper(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Text(
                            "Fields marked * are Required",
                            style: TextStyle(
                                fontSize: 12.0, color: Config.customGrey),
                          ),
                          CustomTextField(
                            controller: titleController,
                            hintText: "Title",
                            title: "Product Title *",
                            inputType: TextInputType.name,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: DropdownSearch<dynamic>(
                              popupProps: PopupProps.menu(
                                showSelectedItems: false,
                                disabledItemFn: (dynamic s) =>
                                    s.startsWith('A'),
                              ),
                              items: categories,
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Category",
                                  hintText: "Category",
                                ),
                              ),
                              onChanged: (str) {
                                setState(() {
                                  selectedCategory = str;
                                });
                              },
                              // selectedItem: ,
                            ),
                          ),
                          CustomTextField(
                            controller: priceController,
                            hintText: "Price",
                            title: "Price (KES) *",
                            inputType: TextInputType.number,
                          ),
                          CustomTextField(
                            controller: descriptionController,
                            hintText: "Description",
                            title: "Description *",
                            inputType: TextInputType.text,
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          CustomButton(
                            title: "SAVE",
                            iconData: Icons.done_rounded,
                            onPressed: () {
                              if (titleController.text.isNotEmpty &&
                                  priceController.text.isNotEmpty &&
                                  selectedCategory != "" &&
                                  images.isNotEmpty &&
                                  descriptionController.text.isNotEmpty) {
                                saveProductToFirestore(admin);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Fill in the required fields");
                              }
                            },
                          ),
                          const SizedBox(
                            height: 50.0,
                          )
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
