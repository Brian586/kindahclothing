import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kindah/common_functions/color_functions.dart';
import 'package:kindah/common_functions/user_role_solver.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/models/uniform.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:kindah/models/order.dart' as template;

import '../config.dart';
import '../providers/account_provider.dart';
import 'custom_tag.dart';

class DoneOrderDataSource extends DataGridSource {
  List<DataGridRow> _orders = [];
  DoneOrderDataSource(
      {required List<template.DoneOrder> doneOrders,
      required List<dynamic> tariffs}) {
    _orders = doneOrders
        .map<DataGridRow>((order) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'timestamp',
                  value: DateFormat("dd, MMM yyyy").format(
                      DateTime.fromMillisecondsSinceEpoch(order.timestamp!))),
              DataGridCell<String>(
                  columnName: 'item', value: order.uniform!["name"]),
              DataGridCell<int>(
                  columnName: 'quantity', value: order.uniform!["quantity"]),
              DataGridCell<String>(
                  columnName: 'size',
                  value: sizeMatcher(order.uniform!["size"])),
              DataGridCell<String>(
                  columnName: 'color', value: order.uniform!["color"]),
              DataGridCell<bool>(columnName: 'status', value: order.isPaid),
              DataGridCell<double>(
                  columnName: 'total',
                  value: calculateTotalAmount(order, tariffs)),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _orders;

  Widget buildChild(DataGridCell<dynamic> dataGridCell) {
    switch (dataGridCell.columnName) {
      case "color":
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 20.0,
              width: 20.0,
              color: hexToColor(dataGridCell.value.toString()),
            ),
            const SizedBox(width: 10.0),
            Text(
              findColorName(dataGridCell.value.toString()),
              overflow: TextOverflow.ellipsis,
            )
          ],
        );
      case "status":
        if (dataGridCell.value == true) {
          return const Text(
            "Paid",
            style: TextStyle(color: Colors.green),
          );
        } else {
          return const Text(
            "Pending",
            style: TextStyle(color: Colors.red),
          );
        }
      case "total":
        return Text(
          "${dataGridCell.value} /=",
          style: const TextStyle(fontWeight: FontWeight.w800),
        );
      default:
        return Text(dataGridCell.value.toString());
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: (dataGridCell.columnName == 'timestamp' ||
                dataGridCell.columnName == 'total')
            ? Alignment.centerRight
            : Alignment.centerLeft,
        padding: const EdgeInsets.all(16.0),
        child: buildChild(dataGridCell),
      );
    }).toList());
  }
}

double calculateTotalAmount(template.DoneOrder order, List<dynamic> tariffs) {
  Map<String, dynamic> tariffMap = tariffs.firstWhere(
    (element) => element["name"] == order.uniform!["name"],
    orElse: () => null,
  );

  if (tariffMap != null) {
    return (tariffMap["price"].toDouble() * order.uniform!["quantity"])
        .toDouble();
  } else {
    return 0.0;
  }
}

class UserDataGrid extends StatefulWidget {
  final Account account;
  final String preferedRole;
  const UserDataGrid(
      {super.key, required this.account, required this.preferedRole});

  @override
  State<UserDataGrid> createState() => _UserDataGridState();
}

class _UserDataGridState extends State<UserDataGrid> {
  Widget footer(List<template.DoneOrder> doneOrders, List<dynamic> tariffs) {
    double pendingAmount = 0.0;
    double paidAmount = 0.0;

    for (template.DoneOrder order in doneOrders) {
      if (order.isPaid!) {
        paidAmount += calculateTotalAmount(order, tariffs);
      } else {
        pendingAmount += calculateTotalAmount(order, tariffs);
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(widget.account.id)
          .collection("done_orders")
          .where("userRole", isEqualTo: widget.preferedRole)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<template.DoneOrder> doneOrders = [];

          snapshot.data!.docs.forEach((element) {
            template.DoneOrder order = template.DoneOrder.fromDocument(element);

            doneOrders.add(order);
          });

          String userCategory = toHumanReadable(widget.preferedRole);

          print(userCategory);

          if (doneOrders.isEmpty) {
            return Container();
          }

          return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("tariffs")
                  .where("userCategory", isEqualTo: userCategory)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return circularProgress();
                } else {
                  List<dynamic> tariffs = [];

                  if (snap.data!.docs.isNotEmpty) {
                    tariffs = Tariff.fromDocument(snap.data!.docs[0]).tariffs!;

                    DoneOrderDataSource doneOrderDataSource =
                        DoneOrderDataSource(
                      doneOrders: doneOrders,
                      tariffs: tariffs,
                    );

                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          elevation: 3.0,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minWidth: 200.0, maxWidth: 850.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Completed Orders",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      InkWell(
                                          onTap: () {
                                            context
                                                .read<AccountProvider>()
                                                .changeDrawerItem("add_record");

                                            context.go(
                                                "/users/${widget.preferedRole}s/${widget.account.id}/add_record");
                                          },
                                          child: const CustomTag(
                                            title: "Add Record",
                                            color: Config.customBlue,
                                          ))
                                    ],
                                  ),
                                  const Divider(
                                    height: 20.0,
                                    thickness: 1.0,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    height: 105.0 + (doneOrders.length * 50.0),
                                    child: SfDataGridTheme(
                                      data: SfDataGridThemeData(
                                          headerHoverColor:
                                              Colors.white.withOpacity(0.3),
                                          headerColor: Config.customBlue),
                                      child: SfDataGrid(
                                        source: doneOrderDataSource,
                                        gridLinesVisibility:
                                            GridLinesVisibility.both,
                                        columns: <GridColumn>[
                                          GridColumn(
                                              width: 120.0,
                                              columnName: 'timestamp',
                                              label: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: const Text(
                                                    'DATE',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ))),
                                          GridColumn(
                                              width: 150.0,
                                              columnName: 'item',
                                              label: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: const Text(
                                                    'ITEM',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ))),
                                          GridColumn(
                                              columnName: 'quantity',
                                              // width: 120,
                                              label: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: const Text(
                                                    'PCS',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ))),
                                          GridColumn(
                                              width: 100.0,
                                              columnName: 'size',
                                              label: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: const Text(
                                                    'SIZE',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ))),
                                          GridColumn(
                                              columnName: 'color',
                                              label: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: const Text(
                                                    'COLOR',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ))),
                                          GridColumn(
                                              width: 150.0,
                                              columnName: 'status',
                                              label: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: const Text(
                                                    'PAYMENT STATUS',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ))),
                                          GridColumn(
                                              width: 120.0,
                                              columnName: 'total',
                                              label: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: const Text(
                                                    'TOTAL (KSH)',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ))),
                                        ],
                                        footer: footer(doneOrders, tariffs),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }
              });
        }
      },
    );
  }
}
