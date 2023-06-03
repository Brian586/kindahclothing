import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:provider/provider.dart';

import '../../config.dart';
import '../../models/school.dart';
import '../../models/uniform.dart';
import '../../providers/uniform_provider.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/progress_widget.dart';
import '../../widgets/uniform_data_layout.dart';

class EditOrderDesign extends StatefulWidget {
  final template.Order order;
  const EditOrderDesign({super.key, required this.order});

  @override
  State<EditOrderDesign> createState() => _EditOrderDesignState();
}

class _EditOrderDesignState extends State<EditOrderDesign> {
  TextEditingController schoolController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController classController = TextEditingController();
  List<Uniform> selectedUniforms = [];
  School? selectedSchool;
  bool isMale = true;
  bool loading = false;

  void setTemplateInfo() async {
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.order.id)
        .collection("uniforms")
        .get();

    List<Uniform> uniforms =
        querySnapshot.docs.map((e) => Uniform.fromDocument(e)).toList();

    for (Uniform uniform in uniforms) {
      //Provider.of<UniformProvider>(context, listen: false).addUniform(uniform);
      selectedUniforms.add(uniform);
    }

    setState(() {
      nameController.text = widget.order.clientName!.split(" ").first;
      secondNameController.text = widget.order.clientName!.split(" ")[1];
      surnameController.text = widget.order.clientName!.split(" ")[2];
      classController.text = widget.order.clientClass.toString();
      selectedSchool = School.fromJson(widget.order.school);
      isMale = widget.order.gender == "Male";
      loading = false;
    });
  }

  Future<List<School>> getSchools(String filter) async {
    List<School> schools = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("schools")
        .where("name", isGreaterThanOrEqualTo: filter)
        .get();

    if (filter.isNotEmpty) {
      var filteredResults = querySnapshot.docs
          .where((element) => element["name"] == filter.toCapitalized())
          .toList();

      for (var filteredResult in filteredResults) {
        School school = School.fromDocument(filteredResult);

        schools.add(school);
      }
    } else {
      for (var res in querySnapshot.docs) {
        School school = School.fromDocument(res);

        schools.add(school);
      }
    }

    return schools;
  }

  void updateOrderInfo(
    BuildContext context,
    List<Uniform> chosenUniforms,
    double totalAmount,
  ) async {
    try {
      setState(() {
        loading = true;
      });

      template.Order oldOrder = widget.order;

      template.Order order = template.Order(
          id: oldOrder.id,
          clientName:
              "${nameController.text.trim()} ${secondNameController.text.trim()} ${surnameController.text}"
                ..trim(),
          clientClass: int.parse(classController.text.trim()),
          gender: isMale ? "Male" : "Female",
          school: selectedSchool!.toMap(),
          timestamp: oldOrder.timestamp,
          status: oldOrder.status,
          paymentInfo: oldOrder.paymentInfo,
          totalAmount: totalAmount,
          publisher: oldOrder.publisher,
          processedStatus: oldOrder.processedStatus,
          assignedStatus: oldOrder.assignedStatus,
          shopAttendant: oldOrder.shopAttendant,
          fabricCutter: oldOrder.fabricCutter,
          tailor: oldOrder.tailor,
          finisher: oldOrder.finisher ?? {});

      await FirebaseFirestore.instance
          .collection("orders")
          .doc(order.id)
          .update(order.toMap());

      Fluttertoast.showToast(msg: "Template Updated Successfully!");

      Provider.of<UniformProvider>(context, listen: false).clearChosenList();

      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e.toString());

      Fluttertoast.showToast(msg: "An ERROR Occured :(");
    }
  }

  Widget _customPopupItemBuilder(
    BuildContext context,
    School? school,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(school?.name ?? ''),
        subtitle: Text("${school!.city!}, ${school.country!}"),
        leading: Image.network(
          school.imageUrl!,
          height: 100.0,
          width: 100.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget customTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .apply(color: Config.customBlue),
      ),
    );
  }

  void promptOrderDeletion() async {
    String res = await showDialog(
        context: context,
        builder: (_) {
          return CustomPopup(
            title: "Delete Order",
            onAccepted: () => Navigator.pop(context, "proceed"),
            onCancel: () => Navigator.pop(context, "cancelled"),
            acceptTitle: "DELETE",
            body: const Text("Do you wish to delete this order permanently?"),
          );
        });

    if (res == "proceed") {
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.order.id)
          .get()
          .then((value) async {
        if (value.exists) {
          await value.reference.delete();

          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
              .collection("order_count")
              .doc("order_count")
              .get();

          int count = documentSnapshot["count"];

          await FirebaseFirestore.instance
              .collection("order_count")
              .doc("order_count")
              .update({
            "count": count - 1,
          });
        }
      });

      Fluttertoast.showToast(msg: "Template Uploaded Successfully!");
    }
  }

  double computeTotalAmount() {
    double totalAmount = 0.0;

    for (Uniform uniform in selectedUniforms) {
      totalAmount = totalAmount + (uniform.unitPrice! * uniform.quantity!);
    }

    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Card(
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.all(10.0),
        onExpansionChanged: (value) {
          if (value) {
            setTemplateInfo();
          } else {
            context.read<UniformProvider>().clearChosenList();
          }
        },
        leading: Image.network(
          widget.order.school!["imageUrl"],
          height: 50.0,
          width: 50.0,
          fit: BoxFit.cover,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.order.clientName!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                    color: Config.customGrey, fontWeight: FontWeight.w400),
              ),
            ),
            Text(
              widget.order.id!,
              style: const TextStyle(color: Config.customBlue),
            ),
          ],
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.order.school!["name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              DateFormat("dd MMM, HH:mm a").format(
                  DateTime.fromMillisecondsSinceEpoch(widget.order.timestamp!)),
              style: const TextStyle(fontSize: 12.0),
            ),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("orders")
                  .doc(widget.order.id)
                  .collection("uniforms")
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text(
                    "Loading...",
                    style: TextStyle(color: Colors.black12),
                  );
                } else {
                  List<Uniform> uniforms = [];

                  snapshot.data!.docs.forEach((element) {
                    Uniform uniform = Uniform.fromDocument(element);

                    uniforms.add(uniform);
                  });

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(uniforms.length, (index) {
                        Uniform uniform = uniforms[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2.0, vertical: 5.0),
                          child: Text(
                            "${uniform.name!}s: ${uniform.quantity}",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      }),
                    ),
                  );
                }
              },
            ),
            Container(
              height: 0.5,
              width: size.width,
              color: Config.customGrey.withOpacity(0.4),
            )
          ],
        ),
        children: loading
            ? [circularProgress()]
            : [
                customTitle("Client Information"),
                CustomTextField(
                  controller: nameController,
                  hintText: "Name",
                  title: "Client's First Name",
                  inputType: TextInputType.name,
                ),
                CustomTextField(
                  controller: secondNameController,
                  hintText: "Second Name",
                  title: "Second Name",
                  inputType: TextInputType.name,
                ),
                CustomTextField(
                  controller: surnameController,
                  hintText: "Surname",
                  title: "Surname",
                  inputType: TextInputType.name,
                ),
                CustomTextField(
                  controller: classController,
                  hintText: "Class",
                  title: "Class of Student",
                  inputType: TextInputType.number,
                ),
                DropdownSearch<School>(
                  asyncItems: (String? filter) => getSchools(filter!),
                  clearButtonProps: const ClearButtonProps(isVisible: true),
                  popupProps: PopupProps.menu(
                    showSelectedItems: true,
                    itemBuilder: _customPopupItemBuilder,
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      controller: schoolController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            schoolController.clear();
                          },
                        ),
                      ),
                    ),
                  ),
                  selectedItem: selectedSchool,
                  onChanged: (value) {
                    setState(() {
                      selectedSchool = value!;
                    });
                  },
                  itemAsString: (item) => item.name!,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Choose School *',
                      filled: true,
                      fillColor:
                          Theme.of(context).inputDecorationTheme.fillColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                customTitle("Select Gender"),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Male'),
                  value: isMale,
                  onChanged: (bool? value) {
                    setState(() {
                      isMale = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Female'),
                  value: !isMale,
                  onChanged: (bool? value) {
                    setState(() {
                      isMale = !value!;
                    });
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                customTitle("Uniforms"),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(selectedUniforms.length, (index) {
                    Uniform uniform = selectedUniforms[index];

                    return UniformDataLayout(
                      uniform: uniform,
                      index: index,
                    );
                  }),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Total Amount: \nKsh ${computeTotalAmount()}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.pink, fontWeight: FontWeight.w800),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => updateOrderInfo(
                          context, selectedUniforms, computeTotalAmount()),
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.green,
                      ),
                      label: const Text(
                        "UPDATE",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    TextButton.icon(
                      onPressed: () => promptOrderDeletion(),
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: Colors.red,
                      ),
                      label: const Text(
                        "DELETE",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                )
              ],
      ),
    );
  }
}
