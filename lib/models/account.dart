import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String? id;
  final String? username;
  final String? email;
  final String? phone;
  final String? idNumber;
  final String? photoUrl;
  final String? userRole;
  final int? timestamp;
  final bool? isNew;

  Account(
      {this.id,
      this.username,
      this.idNumber,
      this.photoUrl,
      this.email,
      this.userRole,
      this.isNew,
      this.timestamp,
      this.phone});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "username": username,
      "phone": phone,
      "idNumber": idNumber,
      "userRole": userRole,
      "photoUrl": photoUrl,
      "timestamp": timestamp,
      "isNew": isNew,
    };
  }

  factory Account.fromDocument(DocumentSnapshot doc) {
    return Account(
        id: doc["id"],
        username: doc["username"],
        email: doc["email"],
        idNumber: doc["idNumber"],
        photoUrl: doc["photoUrl"],
        userRole: doc["userRole"],
        timestamp: doc["timestamp"],
        isNew: doc["isNew"],
        phone: doc["phone"]);
  }
}
