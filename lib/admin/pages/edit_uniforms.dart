import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';

import '../../models/uniform.dart';
import '../../widgets/custom_scrollbar.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';
import '../widgets/uniform_list_item.dart';

class EditUniforms extends StatefulWidget {
  final bool isAdmin;
  const EditUniforms({super.key, required this.isAdmin});

  @override
  State<EditUniforms> createState() => _EditUniformsState();
}

class _EditUniformsState extends State<EditUniforms> {
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
                ? const CustomHeader(
                    action: [],
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
      ),
    );
  }
}
