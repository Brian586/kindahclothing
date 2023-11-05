import 'package:cloud_firestore/cloud_firestore.dart';

class Tariff {
  final String? id;
  final int? timestamp;
  final String? userCategory;
  final String? basedOn;
  final double? pricePerUnit;
  final List<dynamic>? tariffs;

  Tariff(
      {this.id,
      this.timestamp,
      this.userCategory,
      this.basedOn,
      this.pricePerUnit,
      this.tariffs});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "timestamp": timestamp,
      "userCategory": userCategory,
      "basedOn": basedOn,
      "pricePerUnit": pricePerUnit,
      "tariffs": tariffs
    };
  }

  factory Tariff.fromDocument(DocumentSnapshot doc) {
    return Tariff(
        id: doc.id,
        timestamp: doc["timestamp"],
        userCategory: doc["userCategory"],
        basedOn: doc["basedOn"],
        pricePerUnit: doc["pricePerUnit"],
        tariffs: doc["tariffs"]);
  }
}
