import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/models/uniform.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:kindah/models/order.dart' as template;

import '../../common_functions/user_role_solver.dart';
import '../../config.dart';
import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../widgets/card_button.dart';
import '../../widgets/custom_tag.dart';
import '../../widgets/custom_wrapper.dart';
import '../../widgets/done_order_data_source.dart';
import '../../widgets/progress_widget.dart';

class MachineHandlerDODS extends DataGridSource {
  List<DataGridRow> _orders = [];
  MachineHandlerDODS(
      {required BuildContext context,
      required List<template.DoneOrder> doneOrders,
      required String preferedRole,
      required List<Tariff> tariffs}) {
    _orders = doneOrders
        .map<DataGridRow>((order) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'timestamp',
                  value: DateFormat("dd, MMM yyyy").format(
                      DateTime.fromMillisecondsSinceEpoch(order.timestamp!))),
              DataGridCell<String>(
                  columnName: 'item', value: order.uniform!["name"]),
              DataGridCell<String>(
                  columnName: 'type_of_work', value: order.typeOfWork),
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
                  value: calculateTotalAmount(order, preferedRole, tariffs)),
              DataGridCell<Widget>(
                  columnName: "edit",
                  value: editOrderButton(context, preferedRole, order)),
              DataGridCell<Widget>(
                  columnName: "delete",
                  value: deleteOrderButton(context, order))
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _orders;

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
        child: buildGridChild(dataGridCell),
      );
    }).toList());
  }
}

class MachineHandlerDataGrid extends StatefulWidget {
  final Account account;
  final String preferedRole;
  const MachineHandlerDataGrid(
      {super.key, required this.account, required this.preferedRole});

  @override
  State<MachineHandlerDataGrid> createState() => _MachineHandlerDataGridState();
}

class _MachineHandlerDataGridState extends State<MachineHandlerDataGrid> {
  Widget footer(List<template.DoneOrder> doneOrders, String preferedRole,
      List<Tariff> tariffs) {
    double pendingAmount = 0.0;
    double paidAmount = 0.0;

    for (template.DoneOrder order in doneOrders) {
      if (order.isPaid!) {
        paidAmount += calculateTotalAmount(order, preferedRole, tariffs);
      } else {
        pendingAmount += calculateTotalAmount(order, preferedRole, tariffs);
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
    String preferedRole = context.watch<AccountProvider>().preferedRole;

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
            return const Align(
              alignment: Alignment.topLeft,
              child: CustomWrapper(
                child: CardButton(
                    destinationUrl: "add_record", title: "Add New Record"),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("tariffs").snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return circularProgress();
                } else {
                  List<Tariff> tariffs = [];

                  snap.data!.docs.forEach((element) {
                    Tariff tariff = Tariff.fromDocument(element);

                    tariffs.add(tariff);
                  });

                  MachineHandlerDODS doneOrderDataSource = MachineHandlerDODS(
                    context: context,
                    doneOrders: doneOrders,
                    preferedRole: preferedRole,
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
                                      isScrollbarAlwaysShown: true,
                                      gridLinesVisibility:
                                          GridLinesVisibility.both,
                                      columns: <GridColumn>[
                                        GridColumn(
                                            width: 120.0,
                                            columnName: 'timestamp',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(16.0),
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
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                alignment: Alignment.centerLeft,
                                                child: const Text(
                                                  'ITEM',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ))),
                                        GridColumn(
                                            width: 150.0,
                                            columnName: 'type_of_work',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                alignment: Alignment.centerLeft,
                                                child: const Text(
                                                  'DESCRIPTION',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ))),
                                        GridColumn(
                                            columnName: 'quantity',
                                            // width: 120,
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                alignment: Alignment.centerLeft,
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
                                                padding:
                                                    const EdgeInsets.all(16.0),
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
                                            width: 180.0,
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(16.0),
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
                                                padding:
                                                    const EdgeInsets.all(16.0),
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
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: const Text(
                                                  'TOTAL (KSH)',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ))),
                                        GridColumn(
                                            width: 130.0,
                                            columnName: 'edit',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: const Text(
                                                  'EDIT',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ))),
                                        GridColumn(
                                            width: 130.0,
                                            columnName: 'delete',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: const Text(
                                                  'DELETE',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ))),
                                      ],
                                      footer: footer(
                                          doneOrders, preferedRole, tariffs),
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
                }
              });
        }
      },
    );
  }
}
