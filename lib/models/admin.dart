import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String? id;
  final String? username;
  final String? email;
  final String? phone;
  final String? password;
  final int? tailors;
  final int? fabricCutters;
  final int? shopAttendants;
  final int? finishers;
  final String? photoUrl;
  final int? products;
  final int? schools;
  final int? uniforms;

  Admin(
      {this.id,
      this.tailors,
      this.fabricCutters,
      this.shopAttendants,
      this.username,
      this.password,
      this.photoUrl,
      this.products,
      this.email,
      this.schools,
      this.uniforms,
      required this.finishers,
      this.phone});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "username": username,
      "phone": phone,
      "password": password,
      "tailors": tailors,
      "fabricCutters": fabricCutters,
      "photoUrl": photoUrl,
      "shopAttendants": shopAttendants,
      "products": products,
      "schools": schools,
      "uniforms": uniforms,
      "finishers": finishers
    };
  }

  factory Admin.fromDocument(DocumentSnapshot doc) {
    return Admin(
        id: doc["id"],
        username: doc["username"],
        email: doc["email"],
        password: doc["password"],
        shopAttendants: doc["shopAttendants"],
        tailors: doc["tailors"],
        fabricCutters: doc["fabricCutters"],
        photoUrl: doc["photoUrl"],
        products: doc["products"],
        schools: doc["schools"],
        finishers: doc["finishers"],
        uniforms: doc["uniforms"],
        phone: doc["phone"]);
  }
}
