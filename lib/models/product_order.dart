import 'package:cloud_firestore/cloud_firestore.dart';

class ProductOrder {
  final String? id;
  final String? title;
  final double? paidAmount;
  final String? deliveryStatus;
  final String? shippingStatus;
  final String? paidStatus;
  final List<dynamic>? orderedProducts;
  final int? timestamp;
  final Map<String, dynamic>? paymentInfo;

  ProductOrder(
      {this.id,
      this.title,
      this.paidAmount,
      this.deliveryStatus,
      this.shippingStatus,
      this.paidStatus,
      this.orderedProducts,
      this.timestamp,
      this.paymentInfo});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "paidAmount": paidAmount!.toDouble(),
      "deliveryStatus": deliveryStatus,
      "shippingStatus": shippingStatus,
      "paidStatus": paidStatus,
      "orderedProducts": orderedProducts,
      "timestamp": timestamp,
      "paymentInfo": paymentInfo,
    };
  }

  factory ProductOrder.fromDocument(DocumentSnapshot doc) {
    return ProductOrder(
      id: doc.id,
      title: doc["title"],
      paidAmount: doc["paidAmount"].toDouble(),
      deliveryStatus: doc["deliveryStatus"],
      shippingStatus: doc["shippingStatus"],
      paidStatus: doc["paidStatus"],
      orderedProducts: doc["orderedProducts"],
      timestamp: doc["timestamp"],
      paymentInfo: doc["paymentInfo"],
    );
  }
}
