import 'package:flutter/material.dart';
import 'package:kindah/models/admin.dart';

class AdminProvider with ChangeNotifier {
  String _selectedDrawerItem = "dashboard";

  Admin? _admin;

  String get selectedDrawerItem => _selectedDrawerItem;

  Admin get admin => _admin!;

  changeDrawerItem(String value) {
    _selectedDrawerItem = value;

    notifyListeners();
  }

  changeAdmin(Admin val) {
    _admin = val;

    notifyListeners();
  }
}
