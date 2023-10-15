import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String? id;
  final String? username;
  final String? email;
  final String? phone;
  final String? idNumber;
  final String? photoUrl;
  final List<dynamic>? userRole;
  final int? timestamp;
  final bool? isNew;
  final bool? verified;
  final List<dynamic>? devices;

  Account(
      {this.id,
      this.username,
      this.idNumber,
      this.photoUrl,
      this.email,
      this.userRole,
      this.isNew,
      this.timestamp,
      required this.verified,
      required this.devices,
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
      "verified": verified,
      "devices": devices,
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
        verified: doc["verified"],
        devices: doc["devices"],
        phone: doc["phone"]);
  }

  factory Account.fromJson(doc) {
    return Account(
        id: doc["id"],
        username: doc["username"],
        email: doc["email"],
        idNumber: doc["idNumber"],
        photoUrl: doc["photoUrl"],
        userRole: doc["userRole"],
        timestamp: doc["timestamp"],
        isNew: doc["isNew"],
        verified: doc["verified"],
        devices: doc["devices"],
        phone: doc["phone"]);
  }
}

class UserRoles {
  static const String shopAttendant = "Shop Attendant";
  static const String fabricCutter = "Fabric Cutter";
  static const String tailor = "Tailor";
  static const String finisher = "Finisher";
  static const String specialMachineHandler = "Special Machine Handler";
}

final List<String> userRoles = [
  UserRoles.shopAttendant,
  UserRoles.fabricCutter,
  UserRoles.tailor,
  UserRoles.finisher,
  UserRoles.specialMachineHandler
];
