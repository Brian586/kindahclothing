import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/account.dart';
import '../../models/admin.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';
import '../widgets/user_list_item.dart';

class EditUsers extends StatefulWidget {
  const EditUsers({super.key});

  @override
  State<EditUsers> createState() => _EditUsersState();
}

class _EditUsersState extends State<EditUsers> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomHeader(
            action: [],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("users").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<Account> users = [];

                snapshot.data!.docs.forEach((element) {
                  Account account = Account.fromDocument(element);

                  users.add(account);
                });

                if (users.isEmpty) {
                  return const Text("No Data Available");
                } else {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: CustomWrapper(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(users.length, (index) {
                            Account user = users[index];

                            return UserListItem(
                              user: user,
                              editing: true,
                            );
                          }),
                        ),
                      ),
                    ),
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
