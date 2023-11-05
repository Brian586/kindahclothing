import 'package:flutter/material.dart';
import 'package:kindah/common_functions/custom_toast.dart';
import 'package:kindah/models/uniform.dart';

class UniformProvider with ChangeNotifier {
  List<Uniform> _chosenUniforms = [];
  // This is the format for tariffUniforms
  //
  // {
  //   "name": "Shirt",
  //   "price": 50.00,
  // }
  List<Map<String, dynamic>> tariffUniforms = [];

  double _totalAmount = 0.0;

  List<Uniform> get chosenUniforms => _chosenUniforms;

  double get totalAmount => _totalAmount;

  void addUniform(Uniform uniform) {
    _chosenUniforms.add(uniform);

    computeTotalAmount();

    notifyListeners();
  }

  // Add tariff uniforms function
  void addTariffUniform(Map<String, dynamic> map) {
    tariffUniforms.add(map);

    notifyListeners();
  }

  // Update tariff price
  void updateTariffPrice({required String name, required double newPrice}) {
    // Find the first map with the specified name and update its "price" field.
    Map<String, dynamic>? map =
        tariffUniforms.firstWhere((item) => item["name"] == name);
    if (map != null) {
      map["price"] = newPrice; // Update the "price" field
      print("Updated $name");

      print(tariffUniforms.length);
    } else {
      showCustomToast("Could not update");
      print("$name not found in the list");
    }
  }

  // Remove tariff uniforms
  void removeTariffUniform(String name) {
    tariffUniforms.removeWhere((element) => element['name'] == name);

    notifyListeners();
  }

  void clearTariffUniformsList() {
    tariffUniforms.clear();

    notifyListeners();
  }

  void removeUniform(Uniform uniform) {
    _chosenUniforms.remove(uniform);

    computeTotalAmount();

    notifyListeners();
  }

  void clearChosenList() {
    _chosenUniforms.clear();

    _totalAmount = 0.0;

    notifyListeners();
  }

  computeTotalAmount() {
    _totalAmount = 0.0;

    for (Uniform uniform in _chosenUniforms) {
      _totalAmount = _totalAmount + (uniform.unitPrice! * uniform.quantity!);
    }
  }
}
