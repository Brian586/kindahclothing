import 'package:cloud_firestore/cloud_firestore.dart';

class UserPayment {
  final String? id;
  final double? amount;
  final int? timestamp;
  final String? paymentType;
  final List<dynamic>? orders;

  UserPayment(
      {this.id, this.amount, this.timestamp, this.paymentType, this.orders});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "timestamp": timestamp,
      "amount": amount!.toDouble(),
      "paymentType": paymentType,
      "orders": orders,
    };
  }

  factory UserPayment.fromDocument(DocumentSnapshot doc) {
    return UserPayment(
        id: doc.id,
        timestamp: doc["timestamp"],
        amount: doc["amount"].toDouble(),
        paymentType: doc["paymentType"],
        orders: doc["orders"]);
  }
}
