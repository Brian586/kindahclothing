import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/config.dart';
import 'package:kindah/models/school.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:kindah/widgets/custom_scrollbar.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';

class SchoolsListing extends StatefulWidget {
  final bool isAdmin;
  const SchoolsListing({super.key, required this.isAdmin});

  @override
  State<SchoolsListing> createState() => _SchoolsListingState();
}

class _SchoolsListingState extends State<SchoolsListing> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

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
                  //.where("publisher", isEqualTo: admin.id)
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

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(
                                    school.imageUrl!,
                                    height: 250.0,
                                    width: size.width,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.school_outlined,
                                      color: Config.customGrey,
                                    ),
                                  ),
                                  ListTile(
                                    leading: Image.network(
                                      school.logo!,
                                      height: 100.0,
                                      width: 100.0,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.school_outlined,
                                        color: Config.customGrey,
                                      ),
                                    ),
                                    title: Text(school.name!),
                                    subtitle: Text(
                                        "${school.city}, ${school.country}"),
                                  ),
                                ],
                              ),
                            ),
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
      ),
    );
  }
}
