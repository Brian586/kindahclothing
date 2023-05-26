import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/uniform.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';
import '../widgets/uniform_list_item.dart';

class EditUniforms extends StatefulWidget {
  const EditUniforms({super.key});

  @override
  State<EditUniforms> createState() => _EditUniformsState();
}

class _EditUniformsState extends State<EditUniforms> {
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

                        return UniformListItem(
                          uniform: uniform,
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
