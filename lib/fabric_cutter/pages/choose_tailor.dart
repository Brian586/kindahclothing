import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/widgets/adaptive_ui.dart';
import 'package:kindah/widgets/custom_popup.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../../config.dart';

class ChooseTailor extends StatefulWidget {
  final String? templateID;
  const ChooseTailor({super.key, this.templateID});

  @override
  State<ChooseTailor> createState() => _ChooseTailorState();
}

class _ChooseTailorState extends State<ChooseTailor> {
  void showPrompt(BuildContext context, Account tailor) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return CustomPopup(
            title: "Assign Template",
            body: Text(
                "Would you like to assign template ${widget.templateID} to ${tailor.username}?"),
            onAccepted: () {
              Navigator.pop(context);

              Navigator.pop(context, tailor.id);
            },
            acceptTitle: "ACCEPT",
            onCancel: () => Navigator.pop(context),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return AdaptiveUI(
      appbarLeading: IconButton(
        onPressed: () => Navigator.pop(context, "error"),
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
      ),
      appbarTitle: "Choose Tailor",
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              children: <TextSpan>[
                const TextSpan(
                    text: "Assign template ",
                    style: TextStyle(
                      color: Config.customGrey,
                      fontWeight: FontWeight.w600,
                    )),
                TextSpan(
                    text: widget.templateID,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Config.customGrey)),
                const TextSpan(
                    text: " to a tailor",
                    style: TextStyle(
                      color: Config.customGrey,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("userRole", arrayContains: "tailor")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<Account> tailors = [];

                snapshot.data!.docs.forEach((element) {
                  Account account = Account.fromDocument(element);

                  tailors.add(account);
                });

                if (tailors.isEmpty) {
                  return const Text("No tailors available :(");
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(tailors.length, (index) {
                      Account tailor = tailors[index];

                      return ListTile(
                        onTap: () => showPrompt(context, tailor),
                        leading: CircleAvatar(
                          backgroundImage:
                              const AssetImage("assets/images/profile.png"),
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          radius: 15.0,
                          foregroundImage: tailor.photoUrl! == ""
                              ? null
                              : NetworkImage(tailor.photoUrl!),
                        ),
                        title: Text(tailor.username!),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Available",
                              style: TextStyle(color: Colors.green),
                            ),
                            Container(
                              height: 0.5,
                              width: size.width,
                              color: Colors.black12,
                            )
                          ],
                        ),
                      );
                    }),
                  );
                }
              }
            },
          )
        ],
      ),
    );
  }
}
