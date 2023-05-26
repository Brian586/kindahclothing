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
  final List<dynamic>? measurements;

  Uniform(
      {this.id,
      this.name,
      this.category,
      this.unitPrice,
      this.imageUrl,
      this.quantity,
      this.timestamp,
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
