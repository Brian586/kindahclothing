import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/config.dart';
import 'package:kindah/providers/uniform_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:kindah/models/order.dart' as template;

import '../../models/account.dart';
import '../../models/school.dart';
import '../../models/uniform.dart';
import '../../providers/account_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../../widgets/uniform_data_layout.dart';
import '../../widgets/user_appbar.dart';
import '../widgets/uniform_design.dart';

class EditTemplate extends StatefulWidget {
  final String? templateID;
  const EditTemplate({super.key, this.templateID});

  @override
  State<EditTemplate> createState() => _EditTemplateState();
}

class _EditTemplateState extends State<EditTemplate> {
  TextEditingController schoolController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController classController = TextEditingController();
  List<Uniform> selectedUniforms = [];
  School? selectedSchool;
  bool isMale = true;
  bool loading = false;

  @override
  initState() {
    super.initState();

    setTemplateInfo();
  }

  void setTemplateInfo() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.templateID)
        .get();

    template.Order order = template.Order.fromDocument(documentSnapshot);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("orders")
        .doc(order.id)
        .collection("uniforms")
        .get();

    List<Uniform> uniforms =
        querySnapshot.docs.map((e) => Uniform.fromDocument(e)).toList();

    for (Uniform uniform in uniforms) {
      Provider.of<UniformProvider>(context, listen: false).addUniform(uniform);
      selectedUniforms.add(uniform);
    }

    setState(() {
      nameController.text = order.clientName!.split(" ").first;
      secondNameController.text = order.clientName!.split(" ")[1];
      surnameController.text = order.clientName!.split(" ")[2];
      classController.text = order.clientClass.toString();
      selectedSchool = School.fromJson(order.school);
      isMale = order.gender == "Male";
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

  void updateOrderInfo(BuildContext context, List<Uniform> chosenUniforms,
      double totalAmount, Account account) async {
    try {
      setState(() {
        loading = true;
      });

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.templateID)
          .get();

      template.Order oldOrder = template.Order.fromDocument(documentSnapshot);

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
          publisher: account.id,
          processedStatus: oldOrder.processedStatus,
          assignedStatus: oldOrder.assignedStatus,
          shopAttendant: account.toMap(),
          fabricCutter: oldOrder.fabricCutter,
          tailor: oldOrder.tailor,
          finisher: oldOrder.finisher ?? {});

      await FirebaseFirestore.instance
          .collection("orders")
          .doc(order.id)
          .update(order.toMap());

      // for (Uniform uniform in chosenUniforms) {
      //   await FirebaseFirestore.instance
      //       .collection("orders")
      //       .doc(order.id)
      //       .collection("uniforms")
      //       .doc(uniform.id)
      //       .set(uniform.toMap());
      // }

      Fluttertoast.showToast(msg: "Template Updated Successfully!");

      Provider.of<UniformProvider>(context, listen: false).clearChosenList();

      Navigator.pop(context);

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

  Widget buildBody(
      Account account, double totalAmount, List<Uniform> chosenUniforms) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: CustomWrapper(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  //showSelectedItems: true,
                  itemBuilder: _customPopupItemBuilder,
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    controller: schoolController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
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
                // compareFn: (item, selectedItem) =>
                //     item.id == selectedItem.id,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Choose School *',
                    filled: true,
                    fillColor: Theme.of(context)
                        .inputDecorationTheme
                        .fillColor, //gsutil cors set cors.json gs://kindahclothing
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              customTitle("Select Gender"),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                // secondary: const Icon(
                //   Icons.male_rounded,
                //   color: Config.customGrey,
                // ),
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
                // secondary: const Icon(
                //   Icons.female_rounded,
                //   color: Config.customGrey,
                // ),
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
              // StreamBuilder<QuerySnapshot>(
              //   stream: FirebaseFirestore.instance
              //       .collection("uniforms")
              //       .snapshots(),
              //   builder: (context, snapshot) {
              //     if (!snapshot.hasData) {
              //       return circularProgress();
              //     } else {
              //       List<Uniform> uniforms = [];

              //       snapshot.data!.docs.forEach((element) {
              //         Uniform uniform = Uniform.fromDocument(element);

              //         uniforms.add(uniform);
              //       });

              //       return Column(
              //         mainAxisSize: MainAxisSize.min,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: List.generate(uniforms.length, (index) {
              //           Uniform uniform = uniforms[index];
              //           //bool isSelected = selectedUniforms.contains(uniform);

              //           return UniformDesign(
              //             uniform: uniform,
              //             selectedUniforms: selectedUniforms,
              //           );
              //         }),
              //       );
              //     }
              //   },
              // ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Total Amount: \nKsh $totalAmount",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.pink, fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 20.0,
              ),
              CustomButton(
                onPressed: () {
                  if (totalAmount > 0.0 &&
                      nameController.text.isNotEmpty &&
                      secondNameController.text.isNotEmpty &&
                      surnameController.text.isNotEmpty &&
                      classController.text.isNotEmpty &&
                      selectedSchool != null) {
                    updateOrderInfo(
                        context, chosenUniforms, totalAmount, account);
                  } else {
                    Fluttertoast.showToast(msg: "Fill the required fields");
                  }
                },
                title: "Update Template",
                iconData: Icons.done_rounded,
              ),
              const SizedBox(
                height: 30.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDesktop(
      Account account, double totalAmount, List<Uniform> chosenUniforms) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 4,
          child: Align(
              alignment: Alignment.topLeft,
              child: buildBody(account, totalAmount, chosenUniforms)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Account account = context.watch<AccountProvider>().account;
    double totalAmount = context.watch<UniformProvider>().totalAmount;
    List<Uniform> chosenUniforms =
        context.watch<UniformProvider>().chosenUniforms;

    return loading
        ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: circularProgress(),
            ),
          )
        : ResponsiveBuilder(
            builder: (context, sizingInformation) {
              bool isMobile = sizingInformation.isMobile;

              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size(size.width, kToolbarHeight),
                  child: UserAppbar(
                    isMobile: isMobile,
                    leading: IconButton(
                      onPressed: () {
                        context.read<UniformProvider>().clearChosenList();

                        Navigator.pop(context);
                      }, //context
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text(
                      "Edit Template",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                body: isMobile
                    ? buildBody(account, totalAmount, chosenUniforms)
                    : buildDesktop(account, totalAmount, chosenUniforms),
              );
            },
          );
  }
}
