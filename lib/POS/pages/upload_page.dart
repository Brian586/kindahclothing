import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/POS/models/pos_user.dart';
import 'package:kindah/POS/responsive.dart';
import 'package:kindah/config.dart';
import 'package:uuid/uuid.dart';

import '../../common_functions/custom_file_picker.dart';
import '../../common_functions/uploader.dart';
import '../../dialog/error_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/ecomm_appbar.dart';
import '../../widgets/progress_widget.dart';
import '../models/pos_product.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/pos_custom_header.dart';

class POSUploadPage extends StatefulWidget {
  final String userID;
  const POSUploadPage({super.key, required this.userID});

  @override
  State<POSUploadPage> createState() => _POSUploadPageState();
}

class _POSUploadPageState extends State<POSUploadPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  String selectedCategory = "";
  List<dynamic> categories = [];
  PlatformFile? image;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  void getCategories() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("POS_users")
        .doc(widget.userID)
        .collection("categories")
        .doc("categories")
        .get();

    setState(() {
      categories = documentSnapshot["cat"];
    });
  }

  void pickPhoto() async {
    List<PlatformFile> files =
        await CustomFilePicker.pickImages(isMultiple: false);

    print(files.length);

    if (files.isNotEmpty) {
      setState(() {
        image = files.first;
      });
    }
  }

  void saveProductToFirestore() async {
    setState(() {
      loading = true;
    });

    try {
      String postID = Uuid().v4();

      String downloadUrl = await Uploader.uploadImage(
          destination: "POS Products", id: postID, platformFile: image);

      POSProduct product = POSProduct(
          id: postID,
          name: titleController.text.trim(),
          sellingPrice: int.parse(priceController.text.trim()).toDouble(),
          price: int.parse(priceController.text.trim()).toDouble(),
          description: descriptionController.text,
          category: selectedCategory,
          image: downloadUrl,
          stockAmount: int.parse(stockController.text.trim()),
          publisher: widget.userID,
          quantity: 1,
          timestamp: DateTime.now().millisecondsSinceEpoch);

      await FirebaseFirestore.instance
          .collection("POS_products")
          .doc(product.id)
          .set(product.toJson());

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("POS_users")
          .doc(widget.userID)
          .get();

      POSUser updatedUser = POSUser.fromDocument(doc);

      await FirebaseFirestore.instance
          .collection("POS_users")
          .doc(widget.userID)
          .update({
        "products": updatedUser.products! + 1,
      });

      Fluttertoast.showToast(msg: "Product Uploaded Successfully!");

      setState(() {
        titleController.clear();
        priceController.clear();
        descriptionController.clear();
        stockController.clear();
        selectedCategory = "";
        image = null;
        loading = false;
      });
    } catch (e) {
      print(e.toString());

      showErrorDialog(context, e.toString());

      Fluttertoast.showToast(msg: "Error uploading product :(");

      setState(() {
        loading = false;
      });
    }
  }

  Widget displayImage() {
    if (image == null) {
      return Container(
        height: 200.0,
        width: 200.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Config.customGrey.withOpacity(0.4))),
        child: Center(
          child: IconButton(
            icon: Icon(
              Icons.add_photo_alternate_rounded,
              color: Config.customGrey.withOpacity(0.4),
            ),
            onPressed: () => pickPhoto(),
          ),
        ),
      );
    } else {
      return Stack(
        children: [
          Image.memory(
            image!.bytes!,
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
                      image = null;
                    });
                  },
                ),
              ),
            ),
          )
        ],
      );
    }
  }

  Widget buildBody(BuildContext context) {
    return loading
        ? circularProgress()
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                POSCustomHeader(
                  title: "New Product",
                  action: [
                    CustomButton(
                      onPressed: () => pickPhoto(),
                      height: 30.0,
                      title: "Pick Photo",
                      iconData: Icons.add_a_photo_rounded,
                    )
                  ],
                ),
                displayImage(),
                Align(
                  alignment: Alignment.topLeft,
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
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: DropdownSearch<dynamic>(
                            popupProps: PopupProps.menu(
                              showSelectedItems: false,
                              disabledItemFn: (dynamic s) => s.startsWith('A'),
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
                          controller: stockController,
                          hintText: "Amount",
                          title: "Stock Amount *",
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
                                stockController.text.isNotEmpty &&
                                image != null &&
                                descriptionController.text.isNotEmpty) {
                              saveProductToFirestore();
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
                )
              ],
            ),
          );
  }

  Widget buildDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CustomNavBar(
            currentPage: "upload",
            userID: widget.userID,
          ),
        ),
        Expanded(
          flex: 9,
          child: Align(alignment: Alignment.topLeft, child: buildBody(context)),
        ),
        Expanded(
          flex: 4,
          child: Container(),
        ),
      ],
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
            title: "Upload Products",
          ),
        ),
        body: Responsive.isMobile(context)
            ? buildBody(context)
            : buildDesktop(context));
  }
}
