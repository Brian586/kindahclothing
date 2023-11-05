import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/models/product.dart';

import '../../common_functions/update_admin_info.dart';
import '../../config.dart';
import '../../dialog/error_dialog.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/custom_textfield.dart';

class ProductListingItem extends StatefulWidget {
  final Product product;
  final bool editing;
  const ProductListingItem(
      {super.key, required this.product, required this.editing});

  @override
  State<ProductListingItem> createState() => _ProductListingItemState();
}

class _ProductListingItemState extends State<ProductListingItem> {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "";
  List<dynamic> categories = [];

  Future<List<dynamic>> getCategories() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("categories")
        .doc("categories")
        .get();

    return documentSnapshot["cat"];
  }

  void updateProductInfo() async {
    Navigator.pop(context);

    try {
      await FirebaseFirestore.instance
          .collection("products")
          .doc(widget.product.id)
          .update({
        "title": titleController.text.trim(),
        "price": int.parse(priceController.text.trim()).toDouble(),
        "description": descriptionController.text,
        "category": selectedCategory,
      });

      showCustomToast("Updated Successfully!");
    } catch (e) {
      print(e.toString());

      showErrorDialog(context, e.toString());

      showCustomToast("An ERROR Occurred!");
    }
  }

  void displayProductInfo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return CustomPopup(
          title: "Edit Product Info",
          onAccepted: () => updateProductInfo(),
          acceptTitle: "UPDATE",
          onCancel: () {
            Navigator.pop(context);
          },
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  dropdownDecoratorProps: const DropDownDecoratorProps(
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
            ],
          ),
        );
      },
    );
  }

  void promptProductDeletion() async {
    String res = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CustomPopup(
            title: "Delete Product",
            onAccepted: () => Navigator.pop(context, "proceed"),
            onCancel: () => Navigator.pop(context, "cancelled"),
            acceptTitle: "DELETE",
            body: Text(
                "Do you wish to delete this product permanently, ${widget.product.title}?"),
          );
        });

    if (res == "proceed") {
      // Delete user

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("products")
          .doc(widget.product.id)
          .get();

      await doc.reference.delete();

      await UpdateAdminInfo().updateProductsCount(widget.product, false);

      showCustomToast("Deleted Successfully!");
    } else {
      // Do Nothing...
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      childrenPadding: const EdgeInsets.all(10.0),
      leading: Image.network(
        widget.product.images![0],
        height: 50.0,
        width: 50.0,
        fit: BoxFit.cover,
      ),
      title: Text(
        widget.product.title!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat("dd MMM, HH:mm a").format(
                DateTime.fromMillisecondsSinceEpoch(widget.product.timestamp!)),
            style: const TextStyle(fontSize: 12.0),
          ),
          Text("Price (Ksh): ${widget.product.price}")
        ],
      ),
      children: [
        Text(widget.product.description!),
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () async {
                  categories = await getCategories();

                  setState(() {
                    titleController.text = widget.product.title!;
                    priceController.text = widget.product.price.toString();
                    descriptionController.text = widget.product.description!;
                    selectedCategory = widget.product.category!;
                  });

                  displayProductInfo();
                },
                icon: const Icon(
                  Icons.edit_rounded,
                  color: Config.customGrey,
                  size: 16.0,
                ),
                label: const Text(
                  "Edit",
                  style: TextStyle(color: Config.customGrey),
                ),
              ),
              TextButton.icon(
                onPressed: () => promptProductDeletion(),
                icon: const Icon(
                  Icons.clear_rounded,
                  color: Colors.red,
                  size: 16.0,
                ),
                label: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
