import 'package:flutter/material.dart';

class LoteItem {
  String id;
  int stock;
  String fechaIngreso;
  String fechaVencimiento;
  String unidades;
  double costoLote;
  double costoUnitario;
  double impuestoCompra;
  double precioVenta;
  double impuestoVenta;
  double gananciaUnidad;
  double gananciaLote;
  int danados;
  String ubicacion;

  LoteItem({
    required this.id,
    required this.stock,
    required this.fechaIngreso,
    this.fechaVencimiento = "28-02-2027",
    this.unidades = "Unid",
    this.costoLote = 108.75,
    this.costoUnitario = 36.25,
    this.impuestoCompra = 15.0,
    this.precioVenta = 42.0,
    this.impuestoVenta = 15.0,
    this.gananciaUnidad = 5.75,
    this.gananciaLote = 17.25,
    this.danados = 0,
    this.ubicacion = "Estante A1",
  });
}

class ProductItem {
  String name;
  String subtitle;
  String sku;
  String category;
  int stock;
  int maxStock;
  double price;
  String imageUrl;
  List<LoteItem> lotes;
  String provider;
  int minStock;
  String productType;
  String dateEntered;

  ProductItem({
    required this.name,
    required this.subtitle,
    required this.sku,
    required this.category,
    required this.stock,
    required this.maxStock,
    required this.price,
    required this.imageUrl,
    required this.lotes,
    this.provider = "Bodega",
    this.minStock = 1,
    this.productType = "Normal",
    this.dateEntered = "19-05-26",
  });
}

class ViewModelInventario extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  
  String _selectedCategory = "Todas las Categorías";
  String get selectedCategory => _selectedCategory;
  set selectedCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  String _selectedProvider = "Todos los Proveedores";
  String get selectedProvider => _selectedProvider;
  set selectedProvider(String value) {
    _selectedProvider = value;
    notifyListeners();
  }

  final List<ProductItem> products = [];

  ViewModelInventario() {
    searchController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ProductItem> get filteredProducts {
    final query = searchController.text.trim().toLowerCase();
    return products.where((item) {
      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == "Todas las Categorías" ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get totalStock => products.fold(0, (sum, item) => sum + item.stock);
  int get lowStockCount => products.where((item) => item.stock < 20).length;
  double get totalValue => products.fold(0.0, (sum, item) => sum + (item.price * item.stock));
  int get uniqueCategories => products.map((item) => item.category).toSet().length;
}
