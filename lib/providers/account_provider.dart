import 'package:flutter/material.dart';
import 'package:kindah/models/account.dart';

class AccountProvider with ChangeNotifier {
  String _selectedDrawerItem = "dashboard";
  String? _preferedRole;

  Account? _account;

  String get selectedDrawerItem => _selectedDrawerItem;

  Account get account => _account!;

  String get preferedRole => _preferedRole!;

  changeAccount(Account val) {
    _account = val;

    notifyListeners();
  }

  changeDrawerItem(String value) {
    _selectedDrawerItem = value;

    notifyListeners();
  }

  setPreferedRole(String role) {
    _preferedRole = role;

    notifyListeners();
  }
}
