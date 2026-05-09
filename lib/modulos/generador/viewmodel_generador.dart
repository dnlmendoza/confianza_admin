import 'package:flutter/material.dart';

class ViewModelGenerador extends ChangeNotifier {
  final TextEditingController productNameController = TextEditingController(
    text: "Smartphone Ultra X12 - Negro Medianoche",
  );
  final TextEditingController skuController = TextEditingController(text: "IPH-14-PRO-BK");
  final TextEditingController priceController = TextEditingController(text: "1,299.00");

  String _labelSize = "Estándar (50mm x 30mm)";
  String get labelSize => _labelSize;
  set labelSize(String value) {
    _labelSize = value;
    notifyListeners();
  }

  int _quantity = 15;
  int get quantity => _quantity;
  set quantity(int value) {
    _quantity = value;
    notifyListeners();
  }

  bool _includeLogo = true;
  bool get includeLogo => _includeLogo;
  set includeLogo(bool value) {
    _includeLogo = value;
    notifyListeners();
  }

  bool _showPrice = true;
  bool get showPrice => _showPrice;
  set showPrice(bool value) {
    _showPrice = value;
    notifyListeners();
  }

  ViewModelGenerador() {
    productNameController.addListener(notifyListeners);
    skuController.addListener(notifyListeners);
    priceController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    productNameController.dispose();
    skuController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
