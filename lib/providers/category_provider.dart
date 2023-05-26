import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  String _selectedCategory = "All";
  String _selectedPOSCategory = "All";

  String get selectedCategory => _selectedCategory;
  String get selectedPOSCategory => _selectedPOSCategory;

  changeSelectedCategory(String newCat) {
    _selectedCategory = newCat;

    notifyListeners();
  }

  changePOSSelectedCategory(String newCat) {
    _selectedPOSCategory = newCat;

    notifyListeners();
  }
}
