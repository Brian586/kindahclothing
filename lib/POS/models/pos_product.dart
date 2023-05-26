import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class POSProduct {
  String? id;
  String? name;
  String? description;
  String? category;
  double? price;
  double? sellingPrice;
  int? stockAmount;
  String? image;
  int? timestamp;
  int? quantity;
  String? publisher;

  POSProduct(
      {this.id,
      this.name,
      this.description,
      this.category,
      this.price,
      this.sellingPrice,
      this.stockAmount,
      this.quantity,
      this.timestamp,
      this.publisher,
      this.image});

  POSProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    category = json['category'];
    price = json['price'].toDouble();
    sellingPrice = json['selling_price'].toDouble();
    stockAmount = json['stock_amount'];
    timestamp = json['timestamp'];
    quantity = json['quantity'];
    image = json['image'];
    publisher = json['publisher'];
  }

  factory POSProduct.fromDocument(DocumentSnapshot doc) {
    return POSProduct(
        id: doc['id'],
        name: doc['name'],
        description: doc['description'],
        category: doc['category'],
        price: doc['price'].toDouble(),
        sellingPrice: doc['selling_price'].toDouble(),
        stockAmount: doc['stock_amount'],
        timestamp: doc['timestamp'],
        image: doc['image'],
        publisher: doc['publisher'],
        quantity: doc['quantity']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['category'] = category;
    data['price'] = price!.toDouble();
    data['selling_price'] = sellingPrice!.toDouble();
    data['stock_amount'] = stockAmount;
    data['timestamp'] = timestamp;
    data['image'] = image;
    data['quantity'] = quantity;
    data['publisher'] = publisher;
    return data;
  }

  static String encode(List<POSProduct> products) => json.encode(products
      .map<Map<String, dynamic>>((product) => product.toJson())
      .toList());

  static List<POSProduct> decode(String productsString) {
    if (productsString.isNotEmpty) {
      return (json.decode(productsString) as List<dynamic>)
          .map<POSProduct>((item) => POSProduct.fromJson(item))
          .toList();
    } else {
      return [];
    }
  }
}

class Keyword {
  String? category;
  String? query;

  Keyword({this.category, this.query});

  Keyword.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    query = json['query'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    data['query'] = query;
    return data;
  }
}
