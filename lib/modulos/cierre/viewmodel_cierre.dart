import 'package:flutter/material.dart';

class TransactionRecord {
  final String time;
  final String description;
  final bool isIngreso;
  final double amount;

  const TransactionRecord({
    required this.time,
    required this.description,
    required this.isIngreso,
    required this.amount,
  });
}

class ViewModelCierre extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController cnt100Controller = TextEditingController(text: "0");
  final TextEditingController cnt50Controller = TextEditingController(text: "12");
  final TextEditingController cnt20Controller = TextEditingController(text: "45");
  final TextEditingController cnt10Controller = TextEditingController(text: "82");
  final TextEditingController cnt5Controller = TextEditingController(text: "30");
  final TextEditingController coinsController = TextEditingController(text: "40.30");

  String _selectedFilter = "Todos"; // "Todos", "Ingresos", "Egresos"
  String get selectedFilter => _selectedFilter;
  set selectedFilter(String value) {
    _selectedFilter = value;
    notifyListeners();
  }

  static const double expectedBalance = 4510.30;

  final List<TransactionRecord> transactions = const [
    TransactionRecord(time: "08:15 AM", description: "Venta #9421 - Juan Pérez", isIngreso: true, amount: 120.00),
    TransactionRecord(time: "09:30 AM", description: "Pago Suministros Oficina", isIngreso: false, amount: 45.50),
    TransactionRecord(time: "11:00 AM", description: "Venta #9422 - Cliente Final", isIngreso: true, amount: 3200.00),
    TransactionRecord(time: "01:45 PM", description: "Reposición de Caja Chica", isIngreso: false, amount: 150.00),
    TransactionRecord(time: "03:20 PM", description: "Venta #9423 - Ana María", isIngreso: true, amount: 450.00),
  ];

  ViewModelCierre() {
    searchController.addListener(notifyListeners);
    cnt100Controller.addListener(notifyListeners);
    cnt50Controller.addListener(notifyListeners);
    cnt20Controller.addListener(notifyListeners);
    cnt10Controller.addListener(notifyListeners);
    cnt5Controller.addListener(notifyListeners);
    coinsController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    searchController.dispose();
    cnt100Controller.dispose();
    cnt50Controller.dispose();
    cnt20Controller.dispose();
    cnt10Controller.dispose();
    cnt5Controller.dispose();
    coinsController.dispose();
    super.dispose();
  }

  int _parseCount(String text) => int.tryParse(text) ?? 0;
  double _parseValue(String text) => double.tryParse(text) ?? 0.0;

  double get total100 => _parseCount(cnt100Controller.text) * 100.0;
  double get total50 => _parseCount(cnt50Controller.text) * 50.0;
  double get total20 => _parseCount(cnt20Controller.text) * 20.0;
  double get total10 => _parseCount(cnt10Controller.text) * 10.0;
  double get total5 => _parseCount(cnt5Controller.text) * 5.0;
  double get totalCoins => _parseValue(coinsController.text);

  double get totalCounted => total100 + total50 + total20 + total10 + total5 + totalCoins;
  double get difference => expectedBalance - totalCounted;

  List<TransactionRecord> get filteredTransactions {
    final query = searchController.text.trim().toLowerCase();
    return transactions.where((item) {
      final matchesSearch = query.isEmpty || item.description.toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == "Todos" ||
          (_selectedFilter == "Ingresos" && item.isIngreso) ||
          (_selectedFilter == "Egresos" && !item.isIngreso);

      return matchesSearch && matchesFilter;
    }).toList();
  }
}
