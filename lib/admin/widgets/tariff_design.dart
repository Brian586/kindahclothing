import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/tariff_uniform_design.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/widgets/custom_button.dart';

import '../../common_functions/custom_toast.dart';
import '../../dialog/error_dialog.dart';
import '../../dialog/loading_dialog.dart';
import '../../widgets/custom_popup.dart';

class TariffDesign extends StatefulWidget {
  final Tariff tariff;
  const TariffDesign({super.key, required this.tariff});

  @override
  State<TariffDesign> createState() => _TariffDesignState();
}

class _TariffDesignState extends State<TariffDesign> {
  bool enableEditing = false;
  bool loading = false;

  void toggleEnableEditing(BuildContext context, bool value) {
    setState(() {
      enableEditing = value;
    });
  }

  void saveChangesToDatabase(
    BuildContext context,
  ) async {
    // set enableEditing to false
    setState(() {
      enableEditing = false;
      // loading = false;
    });
  }

  void deleteTariff() async {
    String result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => CustomPopup(
              title: "Delete Tariff",
              body: const Text("Do you wish to delete this tariff? "),
              acceptTitle: "Proceed",
              onAccepted: () => Navigator.pop(context, "proceed"),
              onCancel: () => Navigator.pop(context, "cancel"),
            ));

    if (result == "proceed") {
      try {
        showLoadingDialog(context, "Deleting, Please wait...");

        // Delete tariff
        await FirebaseFirestore.instance
            .collection("tariffs")
            .doc(widget.tariff.id)
            .delete();

        showCustomToast("Deleted Successfully!");

        Navigator.pop(context);
      } catch (e) {
        print(e.toString());

        showErrorDialog(context, e.toString());

        showCustomToast("An ERROR Occured :(");
      }
    }
  }

  Widget customTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "${widget.tariff.userCategory!}s",
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .apply(color: Config.customBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Config.customGrey.withOpacity(0.2),
              width: 1,
            )),
        child: ExpansionTile(
          title: customTitle(),
          subtitle: Text(
              "This tariff is based on the items processed by ${widget.tariff.userCategory}s, e.g Shirts, trousers etc"),
          childrenPadding: const EdgeInsets.all(10.0),
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.tariff.tariffs!.length, (index) {
                Map<String, dynamic> tariffMap = widget.tariff.tariffs![index];

                return TariffUniformDesignOnline(
                  enableEditing: enableEditing,
                  tariff: widget.tariff,
                  tariffMap: tariffMap,
                  index: index,
                );
              }),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: enableEditing
                  ? loading
                      ? const Text("Uploading...")
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  toggleEnableEditing(context, false),
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: Colors.grey,
                              ),
                              label: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 10),
                            CustomButton(
                              onPressed: () => saveChangesToDatabase(context),
                              title: "Save Changes",
                              iconData: Icons.done_rounded,
                            )
                          ],
                        )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () => toggleEnableEditing(context, true),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.grey,
                          ),
                          label: const Text(
                            "Edit",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => deleteTariff(),
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          label: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}
