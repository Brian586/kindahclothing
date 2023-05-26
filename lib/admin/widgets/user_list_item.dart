import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/models/advance_payment.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/models/user_payment.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_functions/custom_file_picker.dart';
import '../../common_functions/uploader.dart';
import '../../config.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/custom_textfield.dart';

class UserListItem extends StatefulWidget {
  final Account user;
  final bool editing;
  const UserListItem({super.key, required this.user, required this.editing});

  @override
  State<UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController advanceController = TextEditingController();
  bool giveAdvance = false;
  bool clearAdvance = false;
  bool paying = false;
  PlatformFile? file;
  String userRole = "shop_attendant";

  @override
  void initState() {
    super.initState();
    setState(() {
      nameController.text = widget.user.username!;
      emailController.text = widget.user.email!;
      phoneController.text = widget.user.phone!;
      idController.text = widget.user.idNumber!;
      userRole = widget.user.userRole!;
    });
  }

  void pickPhoto() async {
    List<PlatformFile> files =
        await CustomFilePicker.pickImages(isMultiple: false);

    if (files.isNotEmpty) {
      setState(() {
        file = files[0];
      });

      String res = await showDialog(
          context: context,
          builder: (_) {
            return CustomPopup(
              title: "Update Photo",
              onAccepted: () => Navigator.pop(context, "proceed"),
              onCancel: () => Navigator.pop(context, "cancelled"),
              acceptTitle: "Proceed",
              body: Text("Do you wish to update this user's profile photo?"),
            );
          });

      if (res == "proceed") {
        try {
          String downloadUrl = await Uploader.uploadImage(
            destination: "Users",
            id: widget.user.idNumber!,
            platformFile: file,
          );

          await FirebaseFirestore.instance
              .collection("users")
              .doc(widget.user.id!)
              .update({"photoUrl": downloadUrl});

          Fluttertoast.showToast(msg: "Updated Photo");

          setState(() {});
        } catch (e) {
          print(e.toString());

          Fluttertoast.showToast(msg: "An Error Occurred");
        }
      } else {
        Fluttertoast.showToast(msg: "Cancelled");
      }
    }
  }

  void payUser(double amount, List<String> orderIDs) async {
    if (amount > 0.0) {
      String res = await showDialog(
          context: context,
          builder: (_) {
            return CustomPopup(
              title: "Pay User",
              onAccepted: () => Navigator.pop(context, "proceed"),
              onCancel: () => Navigator.pop(context, "cancelled"),
              acceptTitle: "PAY",
              body: Text(
                  "Do you wish to pay Ksh $amount to ${widget.user.username}?"),
            );
          });

      if (res == "proceed") {
        setState(() {
          paying = true;
        });

        int timestamp = DateTime.now().millisecondsSinceEpoch;

        UserPayment payment = UserPayment(
          id: timestamp.toString(),
          amount: amount,
          timestamp: timestamp,
          paymentType: "order",
          orders: orderIDs,
        );

        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.user.id)
            .collection("payments")
            .doc(payment.id)
            .set(payment.toMap());

        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.user.id)
            .collection("advancePayments")
            .where("status", isEqualTo: "unpaid")
            .get()
            .then((querySnapshot) async {
          if (querySnapshot.docs.isNotEmpty) {
            querySnapshot.docs.forEach((element) async {
              await element.reference.update({"status": "paid"});
            });
          }
        });

        Fluttertoast.showToast(msg: "Payment Successful!");

        setState(() {
          paying = false;
        });
      } else {
        Fluttertoast.showToast(msg: "Payment Cancelled");
      }
    } else {
      Fluttertoast.showToast(msg: "Payment Error!");
    }
  }

  void updateUserInfo() async {
    Navigator.pop(context);

    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        idController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.user.id)
            .update({
          "email": emailController.text.trim(),
          "username": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "idNumber": idController.text.trim(),
        });

        Fluttertoast.showToast(msg: "Updated Successfully!");

        setState(() {});
      } catch (e) {
        print(e.toString());
        Fluttertoast.showToast(msg: "An ERROR Occurred!");
      }
    } else {
      Fluttertoast.showToast(msg: "An ERROR Occurred!");
    }
  }

  // void displayUserInfo() {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) {
  //       return CustomPopup(
  //         title: "Update User Info",
  //         onAccepted: () => updateUserInfo(),
  //         acceptTitle: "UPDATE",
  //         onCancel: () {
  //           Navigator.pop(context);
  //         },
  //         body: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CustomTextField(
  //               controller: nameController,
  //               hintText: "Name",
  //               title: "Full Name",
  //               inputType: TextInputType.name,
  //             ),
  //             CustomTextField(
  //               controller: emailController,
  //               hintText: "Email",
  //               title: "Email Address",
  //               inputType: TextInputType.emailAddress,
  //             ),
  //             CustomTextField(
  //               controller: phoneController,
  //               hintText: "2547XXXX",
  //               title: "Phone Number",
  //               inputType: TextInputType.phone,
  //             ),
  //             CustomTextField(
  //               controller: idController,
  //               hintText: "ID Number",
  //               title: "ID Number",
  //               inputType: TextInputType.number,
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void promptUserDeletion() async {
    String res = await showDialog(
        context: context,
        builder: (_) {
          return CustomPopup(
            title: "Delete User",
            onAccepted: () => Navigator.pop(context, "proceed"),
            onCancel: () => Navigator.pop(context, "cancelled"),
            acceptTitle: "DELETE",
            body: Text(
                "Do you wish to delete this user permanently, ${widget.user.username}?"),
          );
        });

    if (res == "proceed") {
      // Delete user

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.id)
          .get();

      await doc.reference.delete();

      Fluttertoast.showToast(msg: "Deleted Successfully!");
    } else {
      // Do Nothing...
    }
  }

  String queryID() {
    switch (widget.user.userRole) {
      case "shop_attendant":
        return "shopAttendant";
      case "fabric_cutter":
        return "fabricCutter";
      case "tailor":
        return "tailor";
      case "finisher":
        return "finisher";
      default:
        return widget.user.userRole!;
    }
  }

  void giveAdvancePayment() async {
    String result = await showDialog(
      context: context,
      builder: (ctx) {
        return CustomPopup(
          title: "Advance Payment",
          onAccepted: () {
            if (advanceController.text.isNotEmpty) {
              Navigator.pop(context, "proceed");
            } else {
              Fluttertoast.showToast(msg: "Input Empty");
            }
          },
          acceptTitle: "Proceed",
          onCancel: () => Navigator.pop(context, "cancelled"),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: advanceController,
                hintText: "Ksh 0.00",
                title: "Advance Amount (Ksh)",
                inputType: TextInputType.number,
              ),
            ],
          ),
        );
      },
    );

    if (result == "proceed") {
      setState(() {
        giveAdvance = true;
      });

      int timestamp = DateTime.now().millisecondsSinceEpoch;

      AdvancePayment advancePayment = AdvancePayment(
        id: timestamp.toString(),
        timestamp: timestamp,
        amount: int.parse(advanceController.text.trim()).toDouble(),
        status: "unpaid",
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.id)
          .collection("advancePayments")
          .doc(advancePayment.id)
          .set(advancePayment.toMap());

      Fluttertoast.showToast(msg: "Successful!");

      setState(() {
        giveAdvance = false;
      });
    } else {
      Fluttertoast.showToast(msg: "Cancelled!");
    }
  }

  void clearAdvancePayments() async {
    String res = await showDialog(
        context: context,
        builder: (_) {
          return CustomPopup(
            title: "Clear Advance",
            onAccepted: () => Navigator.pop(context, "proceed"),
            onCancel: () => Navigator.pop(context, "cancelled"),
            acceptTitle: "Proceed",
            body: Text(
                "Do you wish to clear advance payments for ${widget.user.username}?"),
          );
        });

    if (res == "proceed") {
      setState(() {
        clearAdvance = true;
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.id)
          .collection("advancePayments")
          .where("status", isEqualTo: "unpaid")
          .get()
          .then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((element) async {
            await element.reference.update({"status": "paid"});
          });
        }
      });

      Fluttertoast.showToast(msg: "Advance Payments cleared successfully!");

      setState(() {
        clearAdvance = false;
      });
    } else {
      Fluttertoast.showToast(msg: "Cancelled");
    }
  }

  Widget displayAdvancePayments(List<AdvancePayment> payments) {
    double advanceTotal = 0.0;
    payments.forEach(
      (element) {
        advanceTotal = advanceTotal + element.amount!;
      },
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0.0,
      color: Colors.deepOrange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Advance Payments",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              "Ksh $advanceTotal",
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                  color: Config.customGrey, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(
              height: 10.0,
            ),
            giveAdvance
                ? const Text("Loading...")
                : InkWell(
                    onTap: () => giveAdvancePayment(),
                    child: Card(
                      elevation: 0.0,
                      color: Colors.deepOrange.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Text(
                          "Give Advance",
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 10.0,
            ),
            clearAdvance
                ? const Text("Loading...")
                : InkWell(
                    onTap: () => clearAdvancePayments(),
                    child: Card(
                      elevation: 0.0,
                      color: Colors.deepOrange.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Text(
                          "Clear Advance Payments",
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 30.0,
            ),
          ],
        ),
      ),
    );
  }

  String getUserRole() {
    switch (widget.user.userRole) {
      case "shop_attendant":
        return "Shop Attendant";
      case "fabric_cutter":
        return "Fabric Cutter";
      case "tailor":
        return "Tailor";
      case "finisher":
        return "Finisher";
      default:
        return widget.user.userRole!.toCapitalized();
    }
  }

  Widget displayOrdersDone(List<AdvancePayment> payments, int filterTime) {
    double advanceTotal = 0.0;
    payments.forEach(
      (element) {
        advanceTotal = advanceTotal + element.amount!;
      },
    );

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("orders")
          .where("${queryID()}.id", isEqualTo: widget.user.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<String> orderIDs = [];
          int orderCount = snapshot.data!.docs.length;

          int unpaidOrderCount = snapshot.data!.docs
              .where((element) => element["timestamp"] >= filterTime)
              .toList()
              .length;

          snapshot.data!.docs.forEach(
            (element) {
              orderIDs.add(element.id);
            },
          );

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("tariffs")
                .where("users", arrayContains: getUserRole())
                // .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                Tariff tariff = Tariff.fromDocument(snapshot.data!.docs.last);

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  elevation: 0.0,
                  color: Config.customBlue.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Orders Done",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    orderCount.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .apply(
                                            color: Config.customGrey,
                                            overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Unpaid Orders",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    unpaidOrderCount.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .apply(
                                            color: Config.customGrey,
                                            overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Card(
                          elevation: 0.0,
                          color: Config.customBlue.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Text(
                              "Tariff: Ksh ${tariff.value}",
                              style: const TextStyle(
                                  color: Config.customBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        const Text(
                          "Amount Earned",
                          style: TextStyle(color: Config.customGrey),
                        ),
                        Text(
                          "Ksh ${unpaidOrderCount * tariff.value!}",
                          style: Theme.of(context).textTheme.titleMedium!.apply(
                              color: Config.customBlue,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        const Text(
                          "Payable Amount (Income - Advance)",
                          style: TextStyle(color: Config.customGrey),
                        ),
                        Text(
                          "Ksh ${(unpaidOrderCount * tariff.value!) - advanceTotal}",
                          style: Theme.of(context).textTheme.titleMedium!.apply(
                              color: Config.customBlue,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        paying
                            ? const Text("Loading...")
                            : InkWell(
                                onTap: () => payUser(
                                    (unpaidOrderCount * tariff.value!) -
                                        advanceTotal,
                                    orderIDs),
                                child: Card(
                                  elevation: 0.0,
                                  color: Colors.green.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: Text(
                                      "Pay Ksh ${(unpaidOrderCount * tariff.value!) - advanceTotal}",
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                        // const SizedBox(
                        //   height: 10.0,
                        // ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  List<Widget> userInfo() {
    return [
      Stack(
        children: [
          CircleAvatar(
            backgroundImage: const AssetImage("assets/images/profile.png"),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            radius: 50.0,
            foregroundImage: file == null ? null : MemoryImage(file!.bytes!),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_a_photo_rounded,
                      color: Config.customGrey,
                    ),
                    onPressed: () => pickPhoto(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      const SizedBox(
        height: 20.0,
      ),
      CustomTextField(
        controller: nameController,
        hintText: "Name",
        title: "Full Name",
        inputType: TextInputType.name,
      ),
      CustomTextField(
        controller: emailController,
        hintText: "Email",
        title: "Email Address",
        inputType: TextInputType.emailAddress,
      ),
      CustomTextField(
        controller: phoneController,
        hintText: "2547XXXX",
        title: "Phone Number",
        inputType: TextInputType.phone,
      ),
      CustomTextField(
        controller: idController,
        hintText: "ID Number",
        title: "ID Number",
        inputType: TextInputType.number,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: DropdownSearch<String>(
          popupProps: const PopupProps.menu(
            showSelectedItems: false,
          ),
          items: const [
            "Shop Attendant",
            "Fabric Cutter",
            "Tailor",
            "Finisher"
          ],
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: "User Role",
              hintText: "User Role",
            ),
          ),
          onChanged: (str) {
            setState(() {
              userRole = str!.toLowerCase().split(" ").join("_");
            });

            print(userRole);
          },
          // selectedItem: ,
        ),
      ),
      const SizedBox(
        height: 30.0,
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => updateUserInfo(),
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
            onPressed: () => promptUserDeletion(),
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
    ];
  }

  List<Widget> userPaymentsAndContacts() {
    return [
      StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(widget.user.id)
            .collection("advancePayments")
            .where("status", isEqualTo: "unpaid")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          } else {
            List<AdvancePayment> advancePayments = [];

            snapshot.data!.docs.forEach((element) {
              AdvancePayment advancePayment =
                  AdvancePayment.fromDocument(element);

              advancePayments.add(advancePayment);
            });

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.user.id)
                  .collection("payments")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                } else {
                  int filterTime = 0;

                  if (snapshot.data!.docs.isNotEmpty) {
                    filterTime = snapshot.data!.docs.last["timestamp"];
                  }

                  return ResponsiveBuilder(
                    builder: (context, sizingInformation) {
                      bool isMobile = sizingInformation.isMobile ||
                          sizingInformation.isTablet;

                      return isMobile
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                displayOrdersDone(advancePayments, filterTime),
                                displayAdvancePayments(advancePayments)
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: displayOrdersDone(
                                      advancePayments, filterTime),
                                ),
                                Expanded(
                                  flex: 1,
                                  child:
                                      displayAdvancePayments(advancePayments),
                                )
                              ],
                            );
                    },
                  );
                }
              },
            );
          }
        },
      ),
      Wrap(
        alignment: WrapAlignment.end,
        spacing: 2.5,
        runSpacing: 5.0,
        children: [
          TextButton.icon(
            onPressed: () => launch("mailto:${widget.user.email!}"),
            icon: const Icon(
              Icons.mail_outline,
              color: Colors.green,
            ),
            label: const Text(
              "EMAIL",
              style: TextStyle(color: Colors.green),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          TextButton.icon(
            onPressed: () => launch("tel:+${widget.user.phone!}"),
            icon: const Icon(
              Icons.call_outlined,
              color: Colors.green,
            ),
            label: const Text(
              "CALL",
              style: TextStyle(color: Colors.green),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
        ],
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: const AssetImage("assets/images/profile.png"),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          radius: 20.0,
          foregroundImage: widget.user.photoUrl! == ""
              ? null
              : NetworkImage(widget.user.photoUrl!),
        ),
        title: Text(widget.user.username!),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.email!,
              style: const TextStyle(color: Config.customGrey),
            ),
            Text(
              "+${widget.user.phone!}",
              style: const TextStyle(color: Config.customGrey),
            ),
          ],
        ),
        children: widget.editing ? userInfo() : userPaymentsAndContacts(),
      ),
    );
  }
}
