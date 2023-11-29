import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/common_functions/user_role_solver.dart';
import 'package:kindah/config.dart';
import 'package:kindah/dialog/loading_dialog.dart';
import 'package:kindah/models/order.dart' as template;
import 'package:kindah/models/order_transaction.dart';
import 'package:kindah/widgets/custom_popup.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../common_functions/color_functions.dart';
import '../../dialog/error_dialog.dart';
import '../../models/account.dart';
import '../../models/tariff.dart';
import '../../models/uniform.dart';

class AdminDODS extends DataGridSource {
  List<DataGridRow> _orders = [];

  AdminDODS(
      {required BuildContext context,
      required List<template.DoneOrder> doneOrders,
      required List<Tariff> tariffs}) {
    _orders = doneOrders
        .map<DataGridRow>((order) => DataGridRow(cells: [
              DataGridCell<Account>(
                  columnName: 'users', value: Account.fromJson(order.user)),
              DataGridCell<String>(
                  columnName: 'userRole',
                  value: toHumanReadable(order.userRole!)),
              DataGridCell<int>(
                  columnName: 'timestamp', value: order.timestamp),
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
                  value: adminCalculateTotalAmount(order, tariffs)),
              DataGridCell<Widget>(
                  columnName: "pay", value: payUser(context, order, tariffs))
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _orders;

  Widget buildChild(DataGridCell<dynamic> dataGridCell) {
    switch (dataGridCell.columnName) {
      case 'users':
        Account account = dataGridCell.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: const AssetImage("assets/images/profile.png"),
              backgroundColor: Config.customBlue.withOpacity(0.1),
              radius: 25.0,
              foregroundImage: account.photoUrl! == ""
                  ? null
                  : NetworkImage(account.photoUrl!),
            ),
            const SizedBox(width: 10.0),
            Text(account.username!)
          ],
        );
      case "timestamp":
        return Text(DateFormat("dd, MMM yyyy")
            .format(DateTime.fromMillisecondsSinceEpoch(dataGridCell.value)));
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
      case 'pay':
        return dataGridCell.value;
      default:
        return Text(dataGridCell.value.toString());
    }
  }

  Widget payUser(
      BuildContext context, template.DoneOrder order, List<Tariff> tariffs) {
    if (order.isPaid!) {
      return Container();
    } else {
      return TextButton.icon(
        onPressed: () => paySingleUser(context, order, tariffs),
        icon: const Icon(
          Icons.done_all_rounded,
          color: Colors.green,
        ),
        label: const Text(
          'Pay',
          style: TextStyle(color: Colors.green),
        ),
      );
    }
  }

  void paySingleUser(BuildContext context, template.DoneOrder order,
      List<Tariff> tariffs) async {
    String result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => CustomPopup(
              title: "Proceed to Pay",
              body: Text("Do you wish to pay ${order.user!["username"]}? "),
              acceptTitle: "Proceed",
              onAccepted: () => Navigator.pop(context, "proceed"),
              onCancel: () => Navigator.pop(context, "cancel"),
            ));

    if (result == "proceed") {
      // Find total amount for the order
      double totalAmount = adminCalculateTotalAmount(order, tariffs);

      if (totalAmount > 0.0) {
        try {
          showLoadingDialog(context, "Saving, Please wait...");

          // Update order payment status
          await FirebaseFirestore.instance
              .collection("done_orders")
              .doc(order.id)
              .update({
            "isPaid": true,
          });

          await FirebaseFirestore.instance
              .collection("users")
              .doc(order.user!["id"])
              .collection("done_orders")
              .doc(order.id)
              .update({
            "isPaid": true,
          });

          // Create a transaction history and save it
          int timestamp = DateTime.now().millisecondsSinceEpoch;

          OrderTransaction transaction = OrderTransaction(
            id: timestamp.toString(),
            timestamp: timestamp,
            totalAmount: totalAmount,
            user: order.user,
            order: order.toMap(),
          );

          await FirebaseFirestore.instance
              .collection("order_transactions")
              .doc(transaction.id)
              .set(transaction.toMap());

          showCustomToast("Saved Successfully!");

          Navigator.pop(context);
        } catch (e) {
          print(e.toString());

          showErrorDialog(context, e.toString());

          showCustomToast("An ERROR Occured :(");
        }
      } else {
        showCustomToast("Cannot pay Ksh 0.00 /=");
      }
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: (dataGridCell.columnName == 'pay')
            ? Alignment.centerRight
            : Alignment.centerLeft,
        padding: const EdgeInsets.all(16.0),
        child: buildChild(dataGridCell),
      );
    }).toList());
  }
}

double adminCalculateTotalAmount(
    template.DoneOrder order, List<Tariff> tariffs) {
  List<Tariff> appropriateTariff = tariffs
      .where((element) => toCoded(element.userCategory!) == order.userRole)
      .toList();

  if (appropriateTariff.isNotEmpty) {
    List<dynamic> tariffsForAppropriateTariff =
        appropriateTariff.first.tariffs!;

    Map<String, dynamic>? tariffMap;

    if (order.userRole == toCoded(UserRoles.specialMachineHandler)) {
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
