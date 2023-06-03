import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:provider/provider.dart';

import '../../models/admin.dart';
import '../../models/school.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';
import '../widgets/school_list_item.dart';

class EditSchools extends StatefulWidget {
  final bool isAdmin;
  const EditSchools({super.key, required this.isAdmin});

  @override
  State<EditSchools> createState() => _EditSchoolsState();
}

class _EditSchoolsState extends State<EditSchools> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.isAdmin
              ? CustomHeader(
                  action: [
                    CustomButton(
                      title: "Add School",
                      iconData: Icons.add,
                      height: 30.0,
                      onPressed: () {
                        context
                            .read<AdminProvider>()
                            .changeDrawerItem("add_schools");

                        context.go("/admin/0001/add_schools");
                      },
                    )
                  ],
                )
              : const UserCustomHeader(
                  action: [],
                ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("schools")
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<School> schools = [];

                snapshot.data!.docs.forEach((element) {
                  School school = School.fromDocument(element);

                  schools.add(school);
                });

                if (schools.isEmpty) {
                  return const Center(
                    child: Text("No Schools Available"),
                  );
                } else {
                  return CustomWrapper(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(schools.length, (index) {
                        School school = schools[index];

                        return SchoolListItem(
                          school: school,
                        );
                      }),
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
