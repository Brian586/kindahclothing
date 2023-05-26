import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String? title;
  final String? currency;
  final double? price;
  final String? description;
  final String? category;
  final List<dynamic>? images;
  final Map<String, dynamic>? rating;
  final int? timestamp;
  final String? publisher;
  final int? quantity;
  final List<dynamic>? searchKeys;

  Product(
      {this.id,
      this.title,
      this.currency,
      this.price,
      this.description,
      this.category,
      this.images,
      this.timestamp,
      this.publisher,
      required this.quantity,
      required this.searchKeys,
      this.rating});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "currency": currency,
      "price": price!.toDouble(),
      "description": description,
      "category": category,
      "images": images,
      "timestamp": timestamp,
      "rating": rating,
      "searchKeys": searchKeys,
      "quantity": quantity,
      "publisher": publisher
    };
  }

  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
        id: doc.id,
        title: doc["title"],
        currency: doc["currency"],
        price: doc["price"].toDouble(),
        description: doc["description"],
        category: doc["category"],
        images: doc["images"],
        timestamp: doc["timestamp"],
        publisher: doc["publisher"],
        quantity: doc["quantity"],
        searchKeys: doc["searchKeys"],
        rating: doc["rating"]);
  }

  factory Product.fromJson(json) {
    return Product(
        id: json["id"].toString(),
        title: json["title"],
        currency: "KES",
        quantity: 1,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        publisher: "1",
        price: json["price"].toDouble(),
        description: json["description"],
        category: json["category"],
        searchKeys: json["searchKeys"],
        images: [json["image"]],
        rating: json["rating"]);
  }

  static String encode(List<Product> products) => json.encode(products
      .map<Map<String, dynamic>>((product) => product.toMap())
      .toList());

  static List<Product> decode(String productsString) {
    if (productsString.isNotEmpty) {
      return (json.decode(productsString) as List<dynamic>)
          .map<Product>((item) => Product.fromJson(item))
          .toList();
    } else {
      return [];
    }
  }
}
