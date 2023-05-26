import 'package:cloud_firestore/cloud_firestore.dart';

class School {
  final String? id;
  final String? name;
  final String? imageUrl;
  final String? logo;
  final String? city;
  final String? country;
  final String? category;
  final int? timestamp;

  School(
      {this.id,
      this.timestamp,
      this.name,
      this.imageUrl,
      this.logo,
      required this.category,
      this.city,
      this.country});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "imageUrl": imageUrl,
      "city": city,
      "logo": logo,
      "country": country,
      "timestamp": timestamp,
      "category": category
    };
  }

  factory School.fromDocument(DocumentSnapshot doc) {
    return School(
        id: doc.id,
        name: doc["name"],
        imageUrl: doc["imageUrl"],
        city: doc["city"],
        logo: doc["logo"],
        timestamp: doc["timestamp"],
        category: doc["category"],
        country: doc["country"]);
  }

  factory School.fromJson(doc) {
    return School(
        id: doc["id"],
        name: doc["name"],
        imageUrl: doc["imageUrl"],
        city: doc["city"],
        logo: doc["logo"] ?? "",
        category: doc["category"],
        timestamp: doc["timestamp"],
        country: doc["country"]);
  }
}
