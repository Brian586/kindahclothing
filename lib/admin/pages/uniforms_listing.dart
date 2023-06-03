import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/models/uniform.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';

class UniformsListing extends StatefulWidget {
  final bool isAdmin;
  const UniformsListing({super.key, required this.isAdmin});

  @override
  State<UniformsListing> createState() => _UniformsListingState();
}

class _UniformsListingState extends State<UniformsListing> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.isAdmin
              ? CustomHeader(
                  action: [
                    CustomButton(
                      title: "Add Uniforms",
                      iconData: Icons.add,
                      height: 30.0,
                      onPressed: () {
                        context
                            .read<AdminProvider>()
                            .changeDrawerItem("add_uniforms");

                        context.go("/admin/0001/add_uniforms");
                      },
                    )
                  ],
                )
              : const UserCustomHeader(
                  action: [],
                ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("uniforms")
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<Uniform> uniforms = [];

                snapshot.data!.docs.forEach((element) {
                  Uniform uniform = Uniform.fromDocument(element);

                  uniforms.add(uniform);
                });

                if (uniforms.isEmpty) {
                  return const Center(
                    child: Text("No Uniforms Available"),
                  );
                } else {
                  return CustomWrapper(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(uniforms.length, (index) {
                        Uniform uniform = uniforms[index];

                        return Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(
                                uniform.imageUrl!,
                                height: 200.0,
                                width: size.width,
                                fit: BoxFit.contain,
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(uniform.name!),
                                subtitle: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      uniform.measurements!.length, (index) {
                                    UniformMeasurement measurement =
                                        UniformMeasurement.fromJson(
                                            uniform.measurements![index]);

                                    return ListTile(
                                      leading: Text(measurement.symbol!),
                                      title: Text(measurement.name!),
                                      subtitle:
                                          Text("Units: ${measurement.units}"),
                                    );
                                  }),
                                ),
                              ),
                            ],
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
    );
  }
}
