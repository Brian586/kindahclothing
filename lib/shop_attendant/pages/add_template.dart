import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/common_functions/update_done_orders.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:kindah/models/school.dart';
import 'package:kindah/models/uniform.dart';
import 'package:kindah/providers/uniform_provider.dart';
import 'package:kindah/widgets/custom_button.dart';
import 'package:kindah/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../dialog/error_dialog.dart';
import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../../widgets/user_appbar.dart';
import '../widgets/uniform_design.dart';

class AddTemplate extends StatefulWidget {
  final String? userID;
  const AddTemplate({super.key, this.userID});

  @override
  State<AddTemplate> createState() => _AddTemplateState();
}

class _AddTemplateState extends State<AddTemplate> {
  TextEditingController schoolController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController classController = TextEditingController();
  List<Uniform> selectedUniforms = [];
  School? selectedSchool;
  bool isMale = true;
  bool loading = false;

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

  void authorizePayment(BuildContext context, List<Uniform> chosenUniforms,
      double totalAmount, Account account, String preferedRole) async {
    try {
      // String data = Uniform.encode(chosenUniforms);
      // Display payment screen

      String result = "proceed";

      // String result = await Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => PaymentScreen(
      //               totalAmount: totalAmount,
      //               data: data,
      //               page: "uniform",
      //             )));

      if (result != "cancelled") {
        setState(() {
          loading = true;
        });

        // Map<String, dynamic> paymentInfo = json.decode(result);
        // Bypass Payment method: assume payment by cash
        Map<String, dynamic> paymentInfo = {
          "payment_method": "Cash",
          "status": "paid",
          "contact": "254700000000"
        };

        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("order_count")
            .doc("order_count")
            .get();

        int count = documentSnapshot["count"];

        template.Order order = template.Order(
            id: "ID_${(count + 1).toString().padLeft(6, "0")}",
            clientName:
                "${nameController.text.trim()} ${secondNameController.text.trim()} ${surnameController.text}"
                  ..trim(),
            clientClass: int.parse(classController.text.trim()),
            gender: isMale ? "Male" : "Female",
            school: selectedSchool!.toMap(),
            timestamp: DateTime.now().millisecondsSinceEpoch,
            status: "paid",
            paymentInfo: paymentInfo,
            totalAmount: totalAmount,
            publisher: account.id,
            processedStatus: "not processed",
            assignedStatus: "not assigned",
            shopAttendant: account.toMap(),
            fabricCutter: {},
            tailor: {},
            finisher: {});

        await FirebaseFirestore.instance
            .collection("orders")
            .doc(order.id)
            .set(order.toMap());

        for (Uniform uniform in chosenUniforms) {
          await FirebaseFirestore.instance
              .collection("orders")
              .doc(order.id)
              .collection("uniforms")
              .doc(uniform.id)
              .set(uniform.toMap());
        }

        await FirebaseFirestore.instance
            .collection("order_count")
            .doc("order_count")
            .update({
          "count": count + 1,
        });

        // UPDATE DONE ORDER=========================================
        // await UpdateDoneOrders.updatePendingOrders(account, order.id!);
        await UpdateDoneOrders.updateDoneOrders(
            chosenUniforms: chosenUniforms,
            orderId: order.id!,
            userRole: "shop_attendant",
            isAdmin: false,
            userMap: account.toMap(),
            userID: widget.userID);

        Fluttertoast.showToast(msg: "Template Uploaded Successfully!");

        // await Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => const PaymentSuccessful(
        //               text: "Payment Successful!",
        //             )));

        GoRouter.of(context).go("/users/${preferedRole}s/${account.id}/home");

        Provider.of<UniformProvider>(context, listen: false).clearChosenList();

        setState(() {
          loading = false;
          schoolController.clear();
          nameController.clear();
          secondNameController.clear();
          surnameController.clear();
          classController.clear();
          selectedUniforms.clear();
          selectedSchool = null;
        });
      } else {
        Fluttertoast.showToast(msg: "Payment has been cancelled :(");

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print(e.toString());

      showErrorDialog(context, e.toString());

      Fluttertoast.showToast(msg: "An ERROR Occured :(");

      setState(() {
        loading = false;
      });
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

  Widget buildBody(Account account, double totalAmount,
      List<Uniform> chosenUniforms, String preferedRole) {
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
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("uniforms")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return circularProgress();
                  } else {
                    List<Uniform> uniforms = [];

                    snapshot.data!.docs.forEach((element) {
                      Uniform uniform = Uniform.fromDocument(element);

                      uniforms.add(uniform);
                    });

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(uniforms.length, (index) {
                        Uniform uniform = uniforms[index];

                        return UniformDesign(
                          uniform: uniform,
                          selectedUniforms: selectedUniforms,
                        );
                      }),
                    );
                  }
                },
              ),
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
                    // Proceed to pay
                    authorizePayment(context, chosenUniforms, totalAmount,
                        account, preferedRole);
                  } else {
                    Fluttertoast.showToast(msg: "Fill the required fields");
                  }
                },
                title: "Upload Template",
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

  Widget buildDesktop(Account account, double totalAmount,
      List<Uniform> chosenUniforms, String preferedRole) {
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
              child: buildBody(
                  account, totalAmount, chosenUniforms, preferedRole)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Account account = context.watch<AccountProvider>().account;
    String preferedRole = context.watch<AccountProvider>().preferedRole;
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

                        context
                            .go("/users/${preferedRole}s/${account.id}/home");
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text(
                      "New Template",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                body: isMobile
                    ? buildBody(
                        account, totalAmount, chosenUniforms, preferedRole)
                    : buildDesktop(
                        account, totalAmount, chosenUniforms, preferedRole),
              );
            },
          );
  }
}
