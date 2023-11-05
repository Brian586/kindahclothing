import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTransaction {
  final String? id;
  final int? timestamp;
  final double? totalAmount;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? order;

  OrderTransaction(
      {this.id, this.timestamp, this.totalAmount, this.user, this.order});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'totalAmount': totalAmount,
      'user': user,
      'order': order,
    };
  }

  factory OrderTransaction.fromDocument(DocumentSnapshot doc) {
    return OrderTransaction(
      id: doc['id'],
      timestamp: doc['timestamp'],
      totalAmount: doc['totalAmount'].toDouble(),
      user: doc['user'],
      order: doc['order'],
    );
  }
}
