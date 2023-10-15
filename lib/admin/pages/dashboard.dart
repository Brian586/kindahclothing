import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/dash_card.dart';
import 'package:kindah/admin/widgets/order_data_card.dart';
import 'package:kindah/admin/widgets/user_data_card.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/models/admin.dart';
import 'package:kindah/providers/admin_provider.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_scrollbar.dart';
import '../widgets/custom_header.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ScrollController _controller = ScrollController();
  int orderCount = 0;

  @override
  void initState() {
    super.initState();

    getOrderCount();
  }

  Future<void> getOrderCount() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("order_count")
        .doc("order_count")
        .get();

    setState(() {
      orderCount = documentSnapshot["count"];
    });
  }

  @override
  Widget build(BuildContext context) {
    Admin admin = context.watch<AdminProvider>().admin;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("admins")
          .doc(admin.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          Admin updatedAdmin = Admin.fromDocument(snapshot.data!);

          return CustomScrollBar(
            controller: _controller,
            child: SingleChildScrollView(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomHeader(
                    action: [],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 20.0,
                          ),
                          DashCard(
                            backgroundColor: Colors.orange.shade800,
                            imageUrl: "assets/images/tailor.png",
                            pathTo: "tailors",
                            count: updatedAdmin.tailors,
                            title: "Total Tailors",
                          ),
                          DashCard(
                            backgroundColor: Colors.teal.shade700,
                            imageUrl: "assets/images/fabric_cutter.png",
                            pathTo: "fabric_cutters",
                            count: updatedAdmin.fabricCutters,
                            title: "Fabric Cutters",
                          ),
                          DashCard(
                            backgroundColor: Colors.cyan.shade600,
                            imageUrl: "assets/images/store.png",
                            pathTo: "shop_attendants",
                            count: updatedAdmin.shopAttendants,
                            title: "Shop \nAttendants",
                          )
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return circularProgress();
                      } else {
                        List<Account> users = [];

                        snapshot.data!.docs.forEach((element) {
                          Account user = Account.fromDocument(element);

                          users.add(user);
                        });

                        users.sort(
                          (a, b) => a.timestamp!.compareTo(b.timestamp!),
                        );

                        return Align(
                          alignment: Alignment.topLeft,
                          child: CustomWrapper(
                            child: UserDataCard(
                              accounts: users,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 20.0,
                          ),
                          DashCard(
                            backgroundColor: Colors.pink.shade800,
                            imageUrl: "assets/images/order.png",
                            pathTo: "orders",
                            count: orderCount,
                            title: "Total Orders",
                          ),
                          DashCard(
                            backgroundColor: Colors.blue.shade700,
                            imageUrl: "assets/images/uniform.png",
                            pathTo: "uniforms",
                            count: updatedAdmin.uniforms,
                            title: "Uniforms",
                          ),
                          DashCard(
                            backgroundColor: Colors.purple.shade600,
                            imageUrl: "assets/images/school.png",
                            pathTo: "schools",
                            count: updatedAdmin.schools,
                            title: "Schools",
                          )
                        ],
                      ),
                    ),
                  ),
                  const Align(
                      alignment: Alignment.topLeft,
                      child: CustomWrapper(child: OrderDataCard()))
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
