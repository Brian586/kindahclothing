import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_scrollbar.dart';
import '../../widgets/custom_wrapper.dart';
import '../widgets/custom_header.dart';
import '../widgets/user_list_item.dart';

class UsersListing extends StatefulWidget {
  final bool isAdmin;
  const UsersListing({
    super.key,
    required this.isAdmin,
  });

  @override
  State<UsersListing> createState() => _UsersListingState();
}

class _UsersListingState extends State<UsersListing> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
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
                      CustomButton(
                        title: "Add Users",
                        iconData: Icons.add,
                        height: 30.0,
                        onPressed: () {
                          context
                              .read<AdminProvider>()
                              .changeDrawerItem("add_users");

                          context.go("/admin/0001/add_users");
                        },
                      )
                    ],
                  )
                : const UserCustomHeader(
                    action: [],
                  ),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("users").snapshots(),
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
                                editing: false,
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
      ),
    );
  }
}
