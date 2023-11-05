import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/tariff_uniform_design.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/widgets/custom_button.dart';

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
                  : TextButton.icon(
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
            )
          ],
        ),
      ),
    );
  }
}
