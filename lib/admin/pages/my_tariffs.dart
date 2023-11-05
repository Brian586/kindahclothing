import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/tariff_design.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/providers/uniform_provider.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

import '../../dialog/error_dialog.dart';
import '../../models/uniform.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_scrollbar.dart';
import '../widgets/custom_header.dart';
import '../widgets/tariff_uniform_design.dart';

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
  String selectedUserCategory = "";
  String basedOn = "items";

  void uploadTariff(List<Map<String, dynamic>> tariffUniforms) async {
    setState(() {
      uploading = true;
    });

    if (tariffUniforms.isNotEmpty && selectedUserCategory.isNotEmpty) {
      try {
        // Add a new tariff

        int timestamp = DateTime.now().millisecondsSinceEpoch;

        Tariff tariff = Tariff(
            id: timestamp.toString(),
            timestamp: timestamp,
            userCategory: selectedUserCategory,
            basedOn: basedOn,
            pricePerUnit: 0.00,
            tariffs: tariffUniforms);

        await FirebaseFirestore.instance
            .collection("tariffs")
            .doc(tariff.id)
            .set(tariff.toMap());

        showCustomToast("New Tariff Added Successfully!");

        setState(() {
          Provider.of<UniformProvider>(context, listen: false)
              .clearTariffUniformsList();
          addTariff = false;
          uploading = false;
        });
      } catch (e) {
        showCustomToast("Error: $e");

        showErrorDialog(context, e.toString());

        setState(() {
          uploading = false;
        });
      }
    } else {
      showCustomToast("Fill in the blanks");
      setState(() {
        uploading = false;
      });
    }
  }

  Widget newTariff(Size size, List<Map<String, dynamic>> tariffUniforms) {
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
                        "Add New Tariff",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .apply(color: Config.customGrey),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                          "Tariffs are the rates you wish to pay workers for every order they work on."),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                          "Select the category of workers that this tariff will apply."),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: DropdownSearch<String>(
                          popupProps: const PopupProps.menu(
                              // showSelectedItems: true,
                              ),
                          items: userRoles,
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "This Tariff Applies To: ",
                              hintText: "e.g Tailors",
                            ),
                          ),
                          onChanged: (str) {
                            setState(() {
                              selectedUserCategory = str!;
                            });
                          },
                          // selectedItem: selectedSize,
                          // itemAsString: sizeMatcher,
                        ),
                      ),
                      const Text(
                          "This tariff is based on the items processed by workers, e.g Shirts, trousers etc"),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                          "Set rates for each item that you wish to pay workers."),
                      const SizedBox(
                        height: 10.0,
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("uniforms")
                              .snapshots(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                              return circularProgress();
                            } else {
                              List<Uniform> uniformList = [];
                              snapshot.data!.docs.forEach((doc) {
                                Uniform newUniform = Uniform.fromDocument(doc);
                                // create tariff json data
                                Map<String, dynamic> newTariff = {
                                  'name': newUniform.name,
                                  'price': 50.0
                                };
                                // Save to uniform provider in tariffUniforms list Using Provider
                                Provider.of<UniformProvider>(context,
                                        listen: false)
                                    .addTariffUniform(newTariff);

                                uniformList.add(newUniform);
                              });

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    List.generate(uniformList.length, (index) {
                                  return TariffUniformDesign(
                                    uniformName: uniformList[index].name!,
                                  );
                                }),
                              );
                            }
                          }),
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
                                    Provider.of<UniformProvider>(context,
                                            listen: false)
                                        .clearTariffUniformsList();
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
                              onPressed: () => uploadTariff(tariffUniforms),
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

  // dispose
  @override
  void dispose() {
    Provider.of<UniformProvider>(context, listen: false)
        .clearTariffUniformsList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> tariffUniforms =
        context.watch<UniformProvider>().tariffUniforms;
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
                      tariffUniforms.isEmpty
                          ? CustomButton(
                              title: "Add Tariff",
                              iconData: Icons.add,
                              height: 30.0,
                              onPressed: () {
                                setState(() {
                                  addTariff = true;
                                });
                              },
                            )
                          : const SizedBox()
                    ],
                  )
                : UserCustomHeader(
                    action: [
                      tariffUniforms.isEmpty
                          ? CustomButton(
                              title: "Add Tariff",
                              iconData: Icons.add,
                              height: 30.0,
                              onPressed: () {
                                setState(() {
                                  addTariff = true;
                                });
                              },
                            )
                          : const SizedBox()
                    ],
                  ),
            addTariff ? newTariff(size, tariffUniforms) : const SizedBox(),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("tariffs").snapshots(),
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
                      : Align(
                          alignment: Alignment.topLeft,
                          child: CustomWrapper(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    List.generate(tariffs.length, (index) {
                                  Tariff tariff = tariffs[index];

                                  return TariffDesign(tariff: tariff);
                                }),
                              ),
                            ),
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
