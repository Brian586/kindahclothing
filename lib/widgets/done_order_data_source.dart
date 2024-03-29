import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kindah/common_functions/color_functions.dart';
import 'package:kindah/common_functions/user_role_solver.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/models/tariff.dart';
import 'package:kindah/models/uniform.dart';
import 'package:kindah/pages/edit_order_item.dart';
import 'package:kindah/widgets/card_button.dart';
import 'package:kindah/widgets/custom_wrapper.dart';
import 'package:kindah/widgets/progress_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:kindah/models/order.dart' as template;

import '../common_functions/custom_toast.dart';
import '../config.dart';
import '../dialog/error_dialog.dart';
import '../dialog/loading_dialog.dart';
import '../providers/account_provider.dart';
import 'custom_popup.dart';
import 'custom_tag.dart';

class DoneOrderDataSource extends DataGridSource {
  List<DataGridRow> _orders = [];
  DoneOrderDataSource(
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

Widget buildGridChild(DataGridCell<dynamic> dataGridCell) {
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
    case 'edit':
      return dataGridCell.value;
    case 'delete':
      return dataGridCell.value;
    default:
      return Text(dataGridCell.value.toString());
  }
}

Widget editOrderButton(
    BuildContext context, String preferedRole, template.DoneOrder order) {
  return TextButton.icon(
    onPressed: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditOrderItem(
                    order: order,
                    preferedRole: preferedRole,
                  )));
    },
    icon: const Icon(
      Icons.edit,
      color: Config.customGrey,
    ),
    label: const Text(
      'Edit',
      style: TextStyle(color: Config.customGrey),
    ),
  );
}

Widget deleteOrderButton(BuildContext context, template.DoneOrder order) {
  return TextButton.icon(
    onPressed: () => deleteOrder(context, order),
    icon: const Icon(
      Icons.delete_forever_outlined,
      color: Colors.red,
    ),
    label: const Text(
      'Delete',
      style: TextStyle(color: Colors.red),
    ),
  );
}

void deleteOrder(BuildContext context, template.DoneOrder order) async {
  String result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomPopup(
            title: "Delete Item",
            body: const Text("Do you wish to delete this item?"),
            acceptTitle: "Proceed",
            onAccepted: () => Navigator.pop(context, "proceed"),
            onCancel: () => Navigator.pop(context, "cancel"),
          ));

  if (result == "proceed") {
    try {
      showLoadingDialog(context, "Deleting, Please wait...");

      // Delete order
      await FirebaseFirestore.instance
          .collection("done_orders")
          .doc(order.id)
          .delete();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(order.user!["id"])
          .collection("done_orders")
          .doc(order.id)
          .delete();

      if (order.isPaid!) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("order_transactions")
            .where("order.id", isEqualTo: order.id)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((element) {
            element.reference.delete();
          });
        }
      }

      showCustomToast("Deleted Successfully!");

      Navigator.pop(context);
    } catch (e) {
      print(e.toString());

      showErrorDialog(context, e.toString());

      showCustomToast("An ERROR Occured :(");
    }
  }
}

double calculateTotalAmount(
    template.DoneOrder order, String preferedRole, List<Tariff> tariffs) {
  List<Tariff> appropriateTariff = tariffs
      .where((element) => toCoded(element.userCategory!) == preferedRole)
      .toList();

  if (appropriateTariff.isNotEmpty) {
    List<dynamic> tariffsForAppropriateTariff =
        appropriateTariff.first.tariffs!;

    Map<String, dynamic>? tariffMap;

    if (preferedRole == toCoded(UserRoles.specialMachineHandler)) {
      tariffMap = tariffsForAppropriateTariff.firstWhere(
        (element) => element["name"] == order.typeOfWork,
        orElse: () => null,
      );
    } else {
      tariffMap = tariffsForAppropriateTariff.firstWhere(
        (element) => element["name"] == order.uniform!["name"],
        orElse: () => null,
      );
    }

    if (tariffMap != null) {
      return (tariffMap["price"].toDouble() * order.uniform!["quantity"])
          .toDouble();
    } else {
      return 0.0;
    }
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

                  DoneOrderDataSource doneOrderDataSource = DoneOrderDataSource(
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
