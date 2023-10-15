import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_scrollbar.dart';
import '../../widgets/custom_textfield.dart';
import '../widgets/custom_header.dart';

class MyTariffs extends StatefulWidget {
  final bool isAdmin;
  const MyTariffs({super.key, required this.isAdmin});

  @override
  State<MyTariffs> createState() => _MyTariffsState();
}

class _MyTariffsState extends State<MyTariffs> {
  final ScrollController _controller = ScrollController();
  bool addTariff = false;
  bool uploading = false;
  List<String> selectedUserRoles = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController valueController = TextEditingController();

  void uploadTariff() async {
    setState(() {
      uploading = true;
    });

    if (nameController.text.isNotEmpty &&
        valueController.text.isNotEmpty &&
        selectedUserRoles.isNotEmpty) {
      try {
        // Set other tariffs to false
        await FirebaseFirestore.instance
            .collection("tariffs")
            .where("isOn", isEqualTo: true)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            value.docs.forEach((element) {
              element.reference.update({"isOn": false});
            });
          }
        });

        // Then add a new tariff

        int timestamp = DateTime.now().millisecondsSinceEpoch;

        Tariff tariff = Tariff(
          id: timestamp.toString(),
          timestamp: timestamp,
          value: int.parse(valueController.text.trim()).toDouble(),
          users: selectedUserRoles,
          isOn: true,
          title: nameController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection("tariffs")
            .doc(tariff.id)
            .set(tariff.toMap());

        Fluttertoast.showToast(msg: "New Tariff Added Successfully!");

        setState(() {
          nameController.clear();
          valueController.clear();
          selectedUserRoles.clear();
          addTariff = false;
          uploading = false;
        });
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e");
        setState(() {
          uploading = false;
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Fill in the blanks");
      setState(() {
        uploading = false;
      });
    }
  }

  Widget newTariff(Size size) {
    return uploading
        ? circularProgress()
        : CustomWrapper(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Config.customBlue)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add Tariff",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .apply(color: Config.customGrey),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      CustomTextField(
                        controller: nameController,
                        hintText: "Name",
                        title: "Name*",
                        inputType: TextInputType.name,
                      ),
                      CustomTextField(
                        controller: valueController,
                        hintText: "KES 0.0 / order",
                        title: "Value per Order (KES)*",
                        inputType: TextInputType.number,
                      ),
                      DropdownSearch<String>.multiSelection(
                        items: userRoles,
                        popupProps: const PopupPropsMultiSelection.menu(
                          showSelectedItems: true,
                        ),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "This Tariff Applies To: ",
                            hintText: "Users",
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedUserRoles = value;
                          });
                        },
                        selectedItems: selectedUserRoles,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    nameController.clear();
                                    valueController.clear();
                                    selectedUserRoles.clear();
                                    addTariff = false;
                                  });
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Config.customGrey),
                                )),
                            const SizedBox(
                              width: 10.0,
                            ),
                            CustomButton(
                              title: "Save",
                              iconData: Icons.add,
                              height: 30.0,
                              onPressed: () => uploadTariff(),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

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
                        title: "Add Tariff",
                        iconData: Icons.add,
                        height: 30.0,
                        onPressed: () {
                          setState(() {
                            addTariff = true;
                          });
                        },
                      )
                    ],
                  )
                : UserCustomHeader(
                    action: [
                      CustomButton(
                        title: "Add Tariff",
                        iconData: Icons.add,
                        height: 30.0,
                        onPressed: () {
                          setState(() {
                            addTariff = true;
                          });
                        },
                      )
                    ],
                  ),
            addTariff ? newTariff(size) : SizedBox(),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("tariffs")
                  .orderBy("timestamp", descending: true)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                } else {
                  List<Tariff> tariffs = [];
                  snapshot.data!.docs.forEach((element) {
                    Tariff tariff = Tariff.fromDocument(element);

                    tariffs.add(tariff);
                  });

                  return tariffs.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.currency_exchange_outlined,
                            color: Config.customGrey,
                          ),
                        )
                      : CustomWrapper(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(tariffs.length, (index) {
                              Tariff tariff = tariffs[index];
                              bool isActive = tariff.isOn!;

                              return Card(
                                elevation: 0.0,
                                color: isActive
                                    ? Config.customBlue.withOpacity(0.05)
                                    : Colors.transparent,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.currency_exchange_outlined,
                                    color: Config.customGrey,
                                  ),
                                  title: Text(tariff.title!),
                                  subtitle: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Created: ${DateFormat("dd MMM, HH:mm a").format(DateTime.fromMillisecondsSinceEpoch(tariff.timestamp!))}",
                                        style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Config.customGrey),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                        "Rates: Ksh ${tariff.value} per Order",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      const Text("This Tariff applies to:"),
                                      Wrap(
                                        alignment: WrapAlignment.start,
                                        spacing: 2.5,
                                        runSpacing: 5.0,
                                        children: List.generate(
                                            tariff.users!.length, (index) {
                                          return Card(
                                            elevation: 0.0,
                                            color: Config.customBlue
                                                .withOpacity(0.1),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0),
                                              child: Text(
                                                tariff.users![index],
                                                style: const TextStyle(
                                                    color: Config.customBlue,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          );
                                        }),
                                      )
                                    ],
                                  ),
                                  trailing: Text(
                                    isActive ? "Active" : "",
                                    style: const TextStyle(
                                        color: Config.customBlue),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
