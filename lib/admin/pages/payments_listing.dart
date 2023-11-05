import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kindah/admin/widgets/admin_dods.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/user_panel/widgets/user_custom_header.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:kindah/widgets/no_data.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../config.dart';
import '../../widgets/progress_widget.dart';
import '../widgets/custom_header.dart';

class PaymentsListing extends StatefulWidget {
  final bool isAdmin;
  const PaymentsListing({super.key, required this.isAdmin});

  @override
  State<PaymentsListing> createState() => _PaymentsListingState();
}

class _PaymentsListingState extends State<PaymentsListing> {
  Widget footer(List<template.DoneOrder> doneOrders, List<Tariff> tariffs) {
    double pendingAmount = 0.0;
    double paidAmount = 0.0;

    for (template.DoneOrder order in doneOrders) {
      if (order.isPaid!) {
        paidAmount += adminCalculateTotalAmount(order, tariffs);
      } else {
        pendingAmount += adminCalculateTotalAmount(order, tariffs);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "TOTAL",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Paid: ",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                "Ksh $paidAmount /=",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 18.0),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                "Pending: ",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                "Ksh $pendingAmount /=",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 18.0),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        widget.isAdmin
            ? const CustomHeader(
                action: [],
              )
            : const UserCustomHeader(
                action: [],
              ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("done_orders")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<template.DoneOrder> doneOrders = [];

                snapshot.data!.docs.forEach((element) {
                  template.DoneOrder order =
                      template.DoneOrder.fromDocument(element);

                  doneOrders.add(order);
                });

                if (doneOrders.isEmpty) {
                  return const NoData(
                    title: "No order has been done.",
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("tariffs")
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return circularProgress();
                      } else {
                        List<Tariff> tariffs = [];

                        snap.data!.docs.forEach((element) {
                          Tariff tariff = Tariff.fromDocument(element);

                          tariffs.add(tariff);
                        });

                        AdminDODS doneOrderDataSource = AdminDODS(
                          context: context,
                          doneOrders: doneOrders,
                          tariffs: tariffs,
                        );

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: SfDataGridTheme(
                              data: SfDataGridThemeData(
                                  headerHoverColor:
                                      Colors.white.withOpacity(0.3),
                                  headerColor: Config.customBlue),
                              child: SfDataGrid(
                                source: doneOrderDataSource,
                                allowSorting: true,
                                isScrollbarAlwaysShown: true,
                                rowHeight: 65.0,
                                gridLinesVisibility: GridLinesVisibility.both,
                                columns: <GridColumn>[
                                  GridColumn(
                                      width: 180.0,
                                      autoFitPadding: EdgeInsets.zero,
                                      columnName: 'users',
                                      label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerRight,
                                          child: const Text(
                                            'WORKERS',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                          ))),
                                  GridColumn(
                                      width: 120.0,
                                      columnName: 'userRole',
                                      label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerRight,
                                          child: const Text(
                                            'ROLE',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                          ))),
                                  GridColumn(
                                      width: 120.0,
                                      allowSorting: true,
                                      columnName: 'timestamp',
                                      label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerRight,
                                          child: const Text(
                                            'DATE',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                          ))),
                                  GridColumn(
                                      width: 150.0,
                                      columnName: 'item',
                                      label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerLeft,
                                          child: const Text(
                                            'ITEM',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                          ))),
                                  GridColumn(
                                      columnName: 'quantity',
                                      // width: 120,
                                      label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerLeft,
                                          child: const Text(
                                            'PCS',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                          ))),
                                  GridColumn(
                                      width: 100.0,
                                      columnName: 'size',
                                      label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerRight,
                                          child: const Text(
                                            'SIZE',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                          ))),
                                  GridColumn(
                                      columnName: 'color',
                                      width: 120.0,
                                      label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerRight,
                                          child: const Text(
                                            'COLOR',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                          ))),
                                  GridColumn(
                                      width: 150.0,
                                      columnName: 'status',
                                      label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerRight,
                                          child: const Text(
                                            'PAYMENT STATUS',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                          ))),
                                  GridColumn(
                                      width: 150.0,
                                      columnName: 'total',
                                      label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerRight,
                                          child: const Text(
                                            'TOTAL (KSH)',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                          ))),
                                  GridColumn(
                                      width: 120.0,
                                      columnName: 'pay',
                                      label: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          alignment: Alignment.centerRight,
                                          child: const Text(
                                            'PAY',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                          ))),
                                ],
                                footer: footer(doneOrders, tariffs),
                              ),
                            ),
                          ),
                        );
                      }
                    });
              }
            },
          ),
        )
      ],
    );
  }
}
