import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/models/user_request.dart';
import 'package:kindah/widgets/progress_widget.dart';

import '../widgets/custom_header.dart';

class AdminNotifications extends StatefulWidget {
  const AdminNotifications({super.key});

  @override
  State<AdminNotifications> createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends State<AdminNotifications> {
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
            stream: FirebaseFirestore.instance
                .collection("admins")
                .doc("0001")
                .collection("requests")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<UserRequest> userRequests = [];

                snapshot.data!.docs.forEach((element) {
                  UserRequest request = UserRequest.fromDocument(element);

                  userRequests.add(request);
                });

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(userRequests.length, (index) {
                    UserRequest request = userRequests[index];

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              const AssetImage("assets/images/profile.png"),
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          radius: 20.0,
                          foregroundImage: request.user!["photoUrl"] == ""
                              ? null
                              : NetworkImage(request.user!["photoUrl"]),
                        ),
                        title: Text(request.user!["username"]),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat("dd MMM, HH:mm a").format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    request.timestamp!))),
                            Text(request.request!)
                          ],
                        ),
                      ),
                    );
                  }),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
