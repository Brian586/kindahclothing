import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/admin/widgets/order_progress_indicator.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:kindah/models/school.dart';

import '../../config.dart';
import '../../models/uniform.dart';
import '../../widgets/progress_widget.dart';
import '../../widgets/uniform_data_layout.dart';

class AdminOrderDesign extends StatefulWidget {
  final template.Order order;
  const AdminOrderDesign({super.key, required this.order});

  @override
  State<AdminOrderDesign> createState() => _AdminOrderDesignState();
}

class _AdminOrderDesignState extends State<AdminOrderDesign> {
  Widget schoolDetails(Size size, School school) {
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
              errorBuilder: (context, error, stackTrace) => const Icon(
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
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.school_outlined,
                  color: Config.customGrey,
                ),
              ),
              title: Text(school.name!),
              subtitle: Text("${school.city}, ${school.country}"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Card(
      child: ExpansionTile(
        leading: Image.network(
          widget.order.school!["imageUrl"],
          height: 50.0,
          width: 50.0,
          fit: BoxFit.cover,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.order.clientName!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                    color: Config.customGrey, fontWeight: FontWeight.w400),
              ),
            ),
            Text(
              widget.order.id!,
              style: const TextStyle(color: Config.customBlue),
            ),
          ],
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.order.school!["name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              DateFormat("dd MMM, HH:mm a").format(
                  DateTime.fromMillisecondsSinceEpoch(widget.order.timestamp!)),
              style: const TextStyle(fontSize: 12.0),
            ),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("orders")
                  .doc(widget.order.id)
                  .collection("uniforms")
                  // .limit(2)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text(
                    "Loading...",
                    style: TextStyle(color: Colors.black12),
                  );
                } else {
                  List<Uniform> uniforms = [];

                  snapshot.data!.docs.forEach((element) {
                    Uniform uniform = Uniform.fromDocument(element);

                    uniforms.add(uniform);
                  });

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(uniforms.length, (index) {
                        Uniform uniform = uniforms[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2.0, vertical: 5.0),
                          child: Text(
                            "${uniform.name!}s: ${uniform.quantity}",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      }),
                    ),
                  );
                }
              },
            ),
            Container(
              height: 0.5,
              width: size.width,
              color: Config.customGrey.withOpacity(0.4),
            )
          ],
        ),
        children: [
          const Text(
            "School Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          schoolDetails(size, School.fromJson(widget.order.school)),
          const Text(
            "Order Progress",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          OrderProgressIndicator(order: widget.order),
          const Text(
            "Ordered Items",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("orders")
                .doc(widget.order.id)
                .collection("uniforms")
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<Uniform> uniforms = [];

                snapshot.data!.docs.forEach((element) {
                  Uniform uniform = Uniform.fromDocument(element);

                  uniforms.add(uniform);
                });

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(uniforms.length, (index) {
                      Uniform uniform = uniforms[index];

                      return UniformDataLayout(
                        uniform: uniform,
                        index: index,
                      );
                    }),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
