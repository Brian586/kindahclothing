import 'package:cloud_firestore/cloud_firestore.dart';

class UserRequest {
  final String? id;
  final String? request;
  final Map<String, dynamic>? user;
  final int? timestamp;
  final String? status;

  UserRequest(
      {this.id, this.request, this.user, this.timestamp, required this.status});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "request": request,
      "user": user,
      "timestamp": timestamp,
      "status": status
    };
  }

  factory UserRequest.fromDocument(DocumentSnapshot doc) {
    return UserRequest(
        id: doc.id,
        request: doc["request"],
        user: doc["user"],
        status: doc["status"],
        timestamp: doc["timestamp"]);
  }
}
