import 'package:flutter/material.dart';
import 'package:kindah/models/account.dart';

class AccountProvider with ChangeNotifier {
  String _selectedDrawerItem = "dashboard";

  Account? _account;

  String get selectedDrawerItem => _selectedDrawerItem;

  Account get account => _account!;

  changeAccount(Account val) {
    _account = val;

    notifyListeners();
  }

  changeDrawerItem(String value) {
    _selectedDrawerItem = value;

    notifyListeners();
  }
}
