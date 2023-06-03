import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindah/admin/pages/access_rights_page.dart';
import 'package:kindah/common_functions/update_admin_info.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/widgets/custom_tag.dart';
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
  String userRole = "Shop Attendant";

  @override
  void initState() {
    super.initState();
    setState(() {
      nameController.text = widget.user.username!;
      emailController.text = widget.user.email!;
      phoneController.text = widget.user.phone!;
      idController.text = widget.user.idNumber!;
      userRole = widget.user.userRole!.split("_").join(" ").toTitleCase();
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
        setState(() {
          file = null;
        });
        Fluttertoast.showToast(msg: "Cancelled");
      }
    }
  }

  void updateUserInfo() async {
    // Navigator.pop(context);

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
          "userRole": userRole.toLowerCase().split(" ").join("_")
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

      await UpdateAdminInfo().updateUserCount(widget.user, false);

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
            showSelectedItems: true,
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
              userRole = str!;
            });
          },
          selectedItem: userRole,
        ),
      ),
      const SizedBox(
        height: 30.0,
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccessRightsPage(
                            account: widget.user,
                          ))),
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.purple,
              ),
              label: const Text(
                "ACCESS RIGHTS",
                style: TextStyle(color: Colors.purple),
              ),
            ),
            const SizedBox(
              width: 5.0,
            ),
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
        ),
      )
    ];
  }

  List<Widget> userPaymentsAndContacts() {
    return [
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

  Color tagColor() {
    switch (widget.user.userRole) {
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
        return "User";
    }
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
            CustomTag(
              title: displayUserRole(),
              color: tagColor(),
            )
          ],
        ),
        children: widget.editing ? userInfo() : userPaymentsAndContacts(),
      ),
    );
  }
}
