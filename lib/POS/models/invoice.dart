// ignore_for_file: unnecessary_this, unnecessary_new, prefer_collection_literals

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kindah/POS/models/pos_product.dart';

class Invoice {
  String? id;
  // String? customerName;
  // String? customerEmail;
  // String? customerPhone;
  // String? customerAddress;
  int? timestamp;
  double? totalAmount;
  //String? transactionStatus;
  //String? paymentMode;
  String? store;
  Map<String, dynamic>? posOperator;
  List<dynamic>? products;
  Map<String, dynamic>? paymentInfo;

  Invoice(
      {this.id,
      // this.customerName,
      // this.customerEmail,
      // this.customerPhone,
      //this.customerAddress,
      this.timestamp,
      this.totalAmount,
      // this.transactionStatus,
      // this.paymentMode,
      this.store,
      this.posOperator,
      this.paymentInfo,
      this.products});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "timestamp": timestamp,
      "totalAmount": totalAmount!.toDouble(),
      "store": store,
      "posOperator": posOperator,
      "paymentInfo": paymentInfo,
      "products": products
    };
  }

  factory Invoice.fromDocument(DocumentSnapshot doc) {
    return Invoice(
      id: doc.id,
      timestamp: doc["timestamp"],
      totalAmount: doc["totalAmount"].toDouble(),
      store: doc["store"],
      posOperator: doc["posOperator"],
      paymentInfo: doc["paymentInfo"],
      products: doc["products"],
    );
  }

  Invoice.fromJson(Map<String, dynamic> json) {
    id = json['invoice_id'];
    // customerName = json['customer_name'];
    // customerEmail = json['customer_email'];
    // customerPhone = json['customer_phone'];
    // customerAddress = json['customer_address'];
    timestamp = json['timestamp'];
    totalAmount = json['amount'].toDouble();
    // transactionStatus = json['transaction_status'];
    // paymentMode = json['payment_mode'];
    store = json['store'];
    paymentInfo = json['paymentInfo'];
    posOperator = json['pos_operator'];
    if (json['products'] != null) {
      products = <dynamic>[];
      json['products'].forEach((v) {
        products!.add(new POSProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['invoice_id'] = this.id;
    // data['customer_name'] = this.customerName;
    // data['customer_email'] = this.customerEmail;
    // data['customer_phone'] = this.customerPhone;
    // data['customer_address'] = this.customerAddress;
    data['timestamp'] = this.timestamp;
    data['amount'] = this.totalAmount!.toDouble();
    data['paymentInfo'] = this.paymentInfo;
    // data['transaction_status'] = this.transactionStatus;
    // data['payment_mode'] = this.paymentMode;
    data['store'] = this.store;
    data['pos_operator'] = this.posOperator;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
