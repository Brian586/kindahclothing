import 'package:cloud_firestore/cloud_firestore.dart';

class AdvancePayment {
  final String? id;
  final int? timestamp;
  final double? amount;
  final String? status;

  AdvancePayment({this.id, this.timestamp, this.amount, this.status});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "timestamp": timestamp,
      "amount": amount!.toDouble(),
      "status": status,
    };
  }

  factory AdvancePayment.fromDocument(DocumentSnapshot doc) {
    return AdvancePayment(
        id: doc.id,
        timestamp: doc["timestamp"],
        amount: doc["amount"].toDouble(),
        status: doc["status"]);
  }
}
