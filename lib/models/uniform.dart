import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Uniform {
  final String? id;
  final String? name;
  final String? category;
  final double? unitPrice;
  final String? imageUrl;
  final int? quantity;
  final int? timestamp;
  final String? size;
  final String? color;
  final List<dynamic>? measurements;

  Uniform(
      {this.id,
      this.name,
      this.category,
      this.unitPrice,
      this.imageUrl,
      this.quantity,
      this.timestamp,
      required this.size,
      required this.color,
      this.measurements});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "category": category,
      "unitPrice": unitPrice!.toDouble(),
      "imageUrl": imageUrl,
      "quantity": quantity,
      "timestamp": timestamp,
      "size": size,
      "color": color,
      "measurements": measurements
    };
  }

  factory Uniform.fromMap(doc) {
    return Uniform(
        id: doc["id"],
        name: doc["name"],
        unitPrice: doc["unitPrice"].toDouble(),
        imageUrl: doc["imageUrl"],
        category: doc["category"],
        quantity: doc["quantity"],
        timestamp: doc["timestamp"],
        size: doc["size"] ?? "M",
        color: doc["color"] ?? "",
        measurements: doc["measurements"]);
  }

  factory Uniform.fromDocument(DocumentSnapshot doc) {
    return Uniform(
        id: doc.id,
        name: doc["name"],
        unitPrice: doc["unitPrice"].toDouble(),
        imageUrl: doc["imageUrl"],
        category: doc["category"],
        quantity: doc["quantity"],
        timestamp: doc["timestamp"],
        size: doc["size"] ?? "M",
        color: doc["color"] ?? "",
        measurements: doc["measurements"]);
  }

  static String encode(List<Uniform> uniforms) => json.encode(uniforms
      .map<Map<String, dynamic>>((uniform) => uniform.toMap())
      .toList());

  static List<Uniform> decode(String uniformsString) {
    if (uniformsString.isNotEmpty) {
      return (json.decode(uniformsString) as List<dynamic>)
          .map<Uniform>((item) => Uniform.fromMap(item))
          .toList();
    } else {
      return [];
    }
  }
}

class UniformMeasurement {
  final String? symbol;
  final String? name;
  final double? measurement;
  final String? units;

  UniformMeasurement({this.symbol, this.name, this.units, this.measurement});

  Map<String, dynamic> toMap() {
    return {
      "symbol": symbol,
      "name": name,
      "measurement": measurement!.toDouble(),
      "units": units
    };
  }

  factory UniformMeasurement.fromJson(Map<String, dynamic> json) {
    return UniformMeasurement(
        symbol: json["symbol"],
        name: json["name"],
        units: json["units"],
        measurement: json["measurement"].toDouble());
  }
}

final List<String> uniformSizes = [
  'XS', // Extra Small
  'S', // Small
  'M', // Medium
  'L', // Large
  'XL', // Extra Large
  'XXL', // Extra Extra Large
];

String sizeMatcher(String size) {
  switch (size) {
    case 'XS':
      return 'Extra Small';
    case 'S':
      return 'Small';
    case 'M':
      return 'Medium';
    case 'L':
      return 'Large';
    case 'XL':
      return 'Extra Large';
    case 'XXL':
      return 'Extra Extra Large';
    default:
      return '';
  }
}
