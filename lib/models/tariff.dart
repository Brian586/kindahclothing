import 'package:cloud_firestore/cloud_firestore.dart';

class Tariff {
  final String? id;
  final int? timestamp;
  final double? value;
  final List<dynamic>? users;
  final bool? isOn;
  final String? title;

  Tariff(
      {this.id, this.timestamp, this.value, this.users, this.isOn, this.title});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "timestamp": timestamp,
      "value": value!.toDouble(),
      "users": users,
      "isOn": isOn,
      "title": title,
    };
  }

  factory Tariff.fromDocument(DocumentSnapshot doc) {
    return Tariff(
        id: doc.id,
        timestamp: doc["timestamp"],
        value: doc["value"].toDouble(),
        users: doc["users"],
        title: doc["title"],
        isOn: doc["isOn"]);
  }
}
