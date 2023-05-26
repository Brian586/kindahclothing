import 'package:cloud_firestore/cloud_firestore.dart';

class POSUser {
  final String? userID;
  final String? username;
  final String? storeID;
  final int? timestamp;
  final String? phone;
  final bool? isNew;
  final int? orderCount;
  final int? products;

  POSUser(
      {this.userID,
      this.username,
      this.orderCount,
      this.storeID,
      this.timestamp,
      this.phone,
      required this.products,
      this.isNew});

  Map<String, dynamic> toMap() {
    return {
      "userID": userID,
      "username": username,
      "storeID": storeID,
      "timestamp": timestamp,
      "phone": phone,
      "isNew": isNew,
      "order_count": orderCount,
      "products": products
    };
  }

  factory POSUser.fromDocument(DocumentSnapshot doc) {
    return POSUser(
      userID: doc["userID"],
      username: doc["username"],
      storeID: doc["storeID"],
      orderCount: doc["order_count"],
      timestamp: doc["timestamp"],
      phone: doc["phone"],
      products: doc["products"],
      isNew: doc["isNew"],
    );
  }
}
