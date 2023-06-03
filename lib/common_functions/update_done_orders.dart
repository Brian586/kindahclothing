import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kindah/models/order.dart' as template;

import '../models/account.dart';
import '../models/user_payment.dart';

class UpdateDoneOrders {
  static Future<void> updatePendingOrders(
      Account account, String orderID) async {
    // UPDATE DONE ORDER=========================================
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(account.id)
        .collection("user_payments")
        .where("status", isEqualTo: "pending")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // CASE 1: Pending Payment Exists
      // Add Order To This "pending" payment

      List<dynamic> pendingOrders = querySnapshot.docs[0]["orders"];

      pendingOrders.add(orderID);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.id)
          .collection("user_payments")
          .doc(querySnapshot.docs[0].id)
          .update({
        "orders": pendingOrders,
      });

      // This also implies this payment exists globaly
      // So update the pending payment globally

      await FirebaseFirestore.instance
          .collection("user_payments")
          .doc(querySnapshot.docs[0].id)
          .update({
        "orders": pendingOrders,
      });
    } else {
      // CASE 2: Pending Payments do NOT Exist
      // Create new Pending Payment

      int timestamp = DateTime.now().millisecondsSinceEpoch;

      UserPayment userPayment = UserPayment(
          id: timestamp.toString(),
          user: account.toMap(),
          timestamp: timestamp,
          amount: 0.0, // Not sure what to put here
          status: "pending",
          orders: [orderID]);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.id)
          .collection("user_payments")
          .doc(userPayment.id)
          .set(userPayment.toMap());

      // Also update grobally
      await FirebaseFirestore.instance
          .collection("user_payments")
          .doc(userPayment.id)
          .set(userPayment.toMap());
    }
    // END HERE ============================================
  }

  static Future<void> updateScript() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("orders").get();

    for (DocumentSnapshot doc in querySnapshot.docs) {
      template.Order order = template.Order.fromDocument(doc);

      // For Shop Attendant
      if (order.shopAttendant!["id"] != null) {
        Account account = Account.fromJson(order.shopAttendant);

        await updatePendingOrders(account, order.id!);
      }

      // For Fabric Cutter
      if (order.fabricCutter!["id"] != null) {
        Account account = Account.fromJson(order.fabricCutter);

        await updatePendingOrders(account, order.id!);
      }

      // For Tailor
      if (order.tailor!["id"] != null) {
        Account account = Account.fromJson(order.tailor);

        await updatePendingOrders(account, order.id!);
      }

      // For Finisher
      if (order.finisher!["id"] != null) {
        Account account = Account.fromJson(order.finisher);

        await updatePendingOrders(account, order.id!);
      }
    }
  }
}
