import 'package:cloud_firestore/cloud_firestore.dart';

class AdvancePayment {
  final String? id;
  final int? timestamp;
  final double? amount;
  final String? status;
  final String? installmentPeriod;
  final int? installmentCount;
  final Map<String, dynamic>? user;
  final List<dynamic>? paidInstallments;
  final List<dynamic>? missedInstallments;

  AdvancePayment(
      {this.id,
      required this.user,
      required this.installmentCount,
      required this.installmentPeriod,
      required this.paidInstallments,
      required this.missedInstallments,
      this.timestamp,
      this.amount,
      this.status});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "timestamp": timestamp,
      "amount": amount!.toDouble(),
      "installmentCount": installmentCount,
      "installmentPeriod": installmentPeriod,
      "status": status,
      "user": user,
      "paidInstallments": paidInstallments,
      "missedInstallments": missedInstallments,
    };
  }

  factory AdvancePayment.fromDocument(DocumentSnapshot doc) {
    return AdvancePayment(
        id: doc.id,
        timestamp: doc["timestamp"],
        amount: doc["amount"].toDouble(),
        user: doc["user"],
        status: doc["status"],
        installmentCount: doc["installmentCount"],
        missedInstallments: doc["missedInstallments"],
        paidInstallments: doc["paidInstallments"],
        installmentPeriod: doc["installmentPeriod"]);
  }
}
