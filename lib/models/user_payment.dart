import 'package:cloud_firestore/cloud_firestore.dart';

class UserPayment {
  final String? id;
  final double? amount;
  final int? timestamp;
  final String? paymentType;
  final List<dynamic>? orders;
  final Map<String, dynamic>? user;

  UserPayment(
      {this.id,
      required this.user,
      this.amount,
      this.timestamp,
      this.paymentType,
      this.orders});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "timestamp": timestamp,
      "amount": amount!.toDouble(),
      "paymentType": paymentType,
      "orders": orders,
      "user": user
    };
  }

  factory UserPayment.fromDocument(DocumentSnapshot doc) {
    return UserPayment(
        id: doc.id,
        timestamp: doc["timestamp"],
        amount: doc["amount"].toDouble(),
        paymentType: doc["paymentType"],
        user: doc["user"] ?? {},
        orders: doc["orders"]);
  }
}
