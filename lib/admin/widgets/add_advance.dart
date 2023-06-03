import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/models/advance_payment.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../../widgets/custom_tag.dart';
import '../../widgets/custom_textfield.dart';

class AddAdvance extends StatefulWidget {
  const AddAdvance({super.key});

  @override
  State<AddAdvance> createState() => _AddAdvanceState();
}

class _AddAdvanceState extends State<AddAdvance> {
  TextEditingController userController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  Account? selectedUser;
  bool loading = false;

  void addAdvancePayment() async {
    if (selectedUser != null && amountController.text.isNotEmpty) {
      setState(() {
        loading = true;
      });
      // Check if there's any pending payment before uploading

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(selectedUser!.id)
          .collection("advance_payments")
          .where("status", isEqualTo: "pending")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // CASE 1: Pending Advance Exists
        // Update the amount of this pending advance only

        double amount = querySnapshot.docs[0]["amount"].toDouble();

        double newAmount =
            amount + int.parse(amountController.text.trim()).toDouble();

        // Update for User
        await FirebaseFirestore.instance
            .collection("users")
            .doc(selectedUser!.id)
            .collection("advance_payments")
            .doc(querySnapshot.docs[0].id)
            .update({
          "amount": newAmount,
        });

        // Update globally
        await FirebaseFirestore.instance
            .collection("advance_payments")
            .doc(querySnapshot.docs[0].id)
            .update({
          "amount": newAmount,
        });

        setState(() {
          loading = false;
          amountController.clear();
          userController.clear();
          selectedUser = null;
        });
      } else {
        // CASE 2: Advance Payment Does NOT Exist
        // Create new Advance Payment

        int timestamp = DateTime.now().millisecondsSinceEpoch;

        AdvancePayment advancePayment = AdvancePayment(
            id: timestamp.toString(),
            timestamp: timestamp,
            amount: int.parse(amountController.text.trim()).toDouble(),
            status: "pending",
            user: selectedUser!.toMap());

        // Update for User
        await FirebaseFirestore.instance
            .collection("users")
            .doc(selectedUser!.id)
            .collection("advance_payments")
            .doc(advancePayment.id)
            .set(advancePayment.toMap());

        // Update globally
        await FirebaseFirestore.instance
            .collection("advance_payments")
            .doc(advancePayment.id)
            .set(advancePayment.toMap());

        setState(() {
          loading = false;
          amountController.clear();
          userController.clear();
          selectedUser = null;
        });
      }
    }
  }

  Future<List<Account>> getUsers(String filter) async {
    List<Account> users = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: filter)
        .get();

    if (filter.isNotEmpty) {
      var filteredResults = querySnapshot.docs
          .where((element) => element["username"] == filter.toCapitalized())
          .toList();

      for (var filteredResult in filteredResults) {
        Account user = Account.fromDocument(filteredResult);

        users.add(user);
      }
    } else {
      for (var res in querySnapshot.docs) {
        Account user = Account.fromDocument(res);

        users.add(user);
      }
    }

    return users;
  }

  Widget _customPopupItemBuilder(
    BuildContext context,
    Account? account,
    bool isSelected,
  ) {
    return PopupAccountItem(
      user: account,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: CustomWrapper(
          child: Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: loading
                    ? [circularProgress()]
                    : [
                        Text(
                          "Add Advance Payment",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Divider(
                          height: 20.0,
                          thickness: 1.0,
                          color: Colors.grey,
                        ),
                        DropdownSearch<Account>(
                          asyncItems: (String? filter) => getUsers(filter!),
                          clearButtonProps:
                              const ClearButtonProps(isVisible: true),
                          popupProps: PopupProps.menu(
                            //showSelectedItems: true,
                            itemBuilder: _customPopupItemBuilder,
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              controller: userController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    userController.clear();
                                  },
                                ),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedUser = value!;
                            });
                          },
                          itemAsString: (item) => item.username!,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Choose User *',
                              hintText: "Choose User",
                              filled: true,
                              fillColor: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        CustomTextField(
                          controller: amountController,
                          hintText: "Ksh 0.00",
                          title: "Amount (Ksh) *",
                          inputType: TextInputType.number,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextButton.icon(
                            onPressed: () => addAdvancePayment(),
                            icon: const Icon(
                              Icons.add_rounded,
                              color: Colors.green,
                            ),
                            label: const Text(
                              "Add Avance",
                              style: TextStyle(color: Colors.green),
                            ))
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PopupAccountItem extends StatelessWidget {
  final Account? user;
  const PopupAccountItem({super.key, this.user});

  Color tagColor() {
    switch (user!.userRole) {
      case "shop_attendant":
        return Colors.teal;
      case "fabric_cutter":
        return Colors.deepOrange;
      case "tailor":
        return Colors.blue;
      case "finisher":
        return Colors.lime;
      default:
        return Colors.teal;
    }
  }

  String displayUserRole() {
    switch (user!.userRole) {
      case "shop_attendant":
        return "Shop Attendant";
      case "fabric_cutter":
        return "Fabric Cutter";
      case "tailor":
        return "Tailor";
      case "finisher":
        return "Finisher";
      default:
        return "User";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: const AssetImage("assets/images/profile.png"),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        radius: 20.0,
        foregroundImage:
            user!.photoUrl! == "" ? null : NetworkImage(user!.photoUrl!),
      ),
      title: Text(user!.username!),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user!.email!,
            style: const TextStyle(color: Config.customGrey),
          ),
          Text(
            "+${user!.phone!}",
            style: const TextStyle(color: Config.customGrey),
          ),
          CustomTag(
            title: displayUserRole(),
            color: tagColor(),
          )
        ],
      ),
    );
  }
}
