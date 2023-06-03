import 'package:cloud_firestore/cloud_firestore.dart';

class AdvancePayment {
  final String? id;
  final int? timestamp;
  final double? amount;
  final String? status;
  final Map<String, dynamic>? user;

  AdvancePayment(
      {this.id, required this.user, this.timestamp, this.amount, this.status});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "timestamp": timestamp,
      "amount": amount!.toDouble(),
      "status": status,
      "user": user,
    };
  }

  factory AdvancePayment.fromDocument(DocumentSnapshot doc) {
    return AdvancePayment(
        id: doc.id,
        timestamp: doc["timestamp"],
        amount: doc["amount"].toDouble(),
        user: doc["user"],
        status: doc["status"]);
  }
}
