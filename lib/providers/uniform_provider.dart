import 'package:flutter/material.dart';
import 'package:kindah/models/uniform.dart';

class UniformProvider with ChangeNotifier {
  List<Uniform> _chosenUniforms = [];

  double _totalAmount = 0.0;

  List<Uniform> get chosenUniforms => _chosenUniforms;

  double get totalAmount => _totalAmount;

  void addUniform(Uniform uniform) {
    _chosenUniforms.add(uniform);

    computeTotalAmount();

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
