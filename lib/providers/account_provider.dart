import 'package:flutter/material.dart';
import 'package:kindah/models/account.dart';

class AccountProvider with ChangeNotifier {
  Account? _account;

  Account get account => _account!;

  changeAccount(Account val) {
    _account = val;

    notifyListeners();
  }
}
