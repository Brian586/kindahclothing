import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String? id;
  final String? clientName;
  final int? clientClass;
  final String? gender;
  final Map<String, dynamic>? school;
  final int? timestamp;
  final String? status;
  final String? publisher;
  final Map<String, dynamic>? paymentInfo;
  final double? totalAmount;
  final String? processedStatus;
  final String? assignedStatus;
  final Map<String, dynamic>? shopAttendant;
  final Map<String, dynamic>? fabricCutter;
  final Map<String, dynamic>? tailor;
  final Map<String, dynamic>? finisher;

  Order(
      {this.id,
      this.clientName,
      this.clientClass,
      this.gender,
      this.school,
      this.timestamp,
      this.status,
      this.processedStatus,
      this.shopAttendant,
      this.assignedStatus,
      this.paymentInfo,
      this.fabricCutter,
      this.publisher,
      this.tailor,
      required this.finisher,
      this.totalAmount});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "clientName": clientName,
      "clientClass": clientClass,
      "gender": gender,
      "school": school,
      "timestamp": timestamp,
      "fabricCutter": fabricCutter,
      "status": status,
      "processedStatus": processedStatus,
      "assignedStatus": assignedStatus,
      "shopAttendant": shopAttendant,
      "finisher": finisher ?? {},
      "tailor": tailor,
      "publisher": publisher,
      "paymentInfo": paymentInfo,
      "totalAmount": totalAmount!.toDouble()
    };
  }

  factory Order.fromDocument(DocumentSnapshot doc) {
    return Order(
        id: doc.id,
        clientName: doc["clientName"],
        clientClass: doc["clientClass"],
        gender: doc["gender"],
        school: doc["school"],
        timestamp: doc["timestamp"],
        shopAttendant: doc["shopAttendant"],
        status: doc["status"],
        fabricCutter: doc["fabricCutter"],
        processedStatus: doc["processedStatus"],
        paymentInfo: doc["paymentInfo"],
        tailor: doc["tailor"],
        publisher: doc["publisher"],
        finisher: doc["finisher"] ?? {},
        assignedStatus: doc["assignedStatus"],
        totalAmount: doc["totalAmount"].toDouble());
  }
}

class DoneOrder {
  final String? id;
  final String? orderId;
  final String? userRole;
  final int? timestamp;
  final bool? isPaid;
  final String? type;
  // final double? totalAmount;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? uniform;

  DoneOrder(
      {this.id,
      this.orderId,
      this.userRole,
      this.timestamp,
      this.isPaid,
      required this.type,
      // this.totalAmount,
      this.user,
      this.uniform});

  /// Create [toMap()] function for this object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'userRole': userRole,
      'timestamp': timestamp,
      'isPaid': isPaid,
      'type': type,
      // 'totalAmount': totalAmount,
      'user': user,
      'uniform': uniform
    };
  }

  factory DoneOrder.fromDocument(DocumentSnapshot doc) {
    return DoneOrder(
        id: doc.id,
        orderId: doc["orderId"],
        userRole: doc['userRole'],
        timestamp: doc['timestamp'],
        isPaid: doc['isPaid'],
        type: doc['type'],
        // totalAmount: doc['totalAmount'].toDouble(),
        user: doc['user'],
        uniform: doc['uniform']);
  }
}
