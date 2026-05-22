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

  final List<ProductItem> products = [
    ProductItem(
      name: "Studio Pro Wireless",
      subtitle: "Over-ear active noise cancelling",
      sku: "STP-882-BLU",
      category: "Electrónica",
      stock: 156,
      maxStock: 200,
      price: 299.00,
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uhDGSJL6EQq__ES4O2BHuQPLhIu-v_4g9dOUZIK7_T_C3IqAudQPDnEnlH7hHQzst4S2rPl3Mts12ht5Y-_SbdPQUu1ub7GUcjjeYWFhomHxPINBqpxAJBKO90Kswd3b-3rivbPXBAgoRs_1GjMw7pxg8GwrO_1Xbaj96ZaNyENfufKBpOtyMNO8himPTyt-B8P8C6IoXm4_AFO45XaoFL_OjYQdCZP053oRa4BQhctwEdru2Sq18tQtzpUlRRrtCpnf1nIIrF_",
      lotes: [
        LoteItem(id: "L-8012", stock: 80, fechaIngreso: "12-04-2026"),
        LoteItem(id: "L-8013", stock: 76, fechaIngreso: "28-04-2026"),
      ],
    ),
    ProductItem(
      name: "Mechanic K1 Keyboard",
      subtitle: "RGB Backlit Mechanical Switches",
      sku: "MK-K1-744",
      category: "Periféricos",
      stock: 12,
      maxStock: 100,
      price: 149.50,
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uie9aXo1SLfhg9oUGqFi4nj1R8WsE7bT8hS8vdtDW1ECX8pNL-Rs-qEps1ft0cRqFODMqLGSDXutWEiHblqTxlePbkM7J1ag0U1jYhlT6NzJ91Um7oobtKxw1OsJxhJQ_7_9VfA-LFK1hQHzAgQy9y6yiGGW1MGZGnFnws73dmYfLqbK30MdXcUhAZ1WGfR1gUjpbzN19DA1IAVrbZN_jgFGMYwIMofXIqznfNk3_ib9SomYPmsyKJkn1iqRjorMszaPyTriM1KZQ",
      lotes: [
        LoteItem(id: "L-5021", stock: 12, fechaIngreso: "05-05-2026"),
      ],
    ),
    ProductItem(
      name: "UltraWide 34\" Display",
      subtitle: "IPS Panel 144Hz HDR400",
      sku: "UW-34-DSPL",
      category: "Monitores",
      stock: 45,
      maxStock: 100,
      price: 599.99,
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uh4Tj2eAXE_OWkZULpzK2h_Q8kPH-6MKNSC3wbUiSjuIeQFgke68asTEoP-OwydyJR-vHaoOza7-NbITPCUY5rVOcE1mVdRPQtX9q0SG1qsAzcLthOhHL7RXQrKwN5MUn190NZySmD45LzmuuocLrnRLtLizsFeVJg17xPdRcoksECY2NRTFBwqGF1qSGBRE0u6S_sNW2K1Y2G-WbYFAKgssRVf1iBWY9t6Y0HlbB1OPEA5Hd3iBoWqR_H4Vf3RS36pKAheDSSlQg",
      lotes: [
        LoteItem(id: "L-1090", stock: 30, fechaIngreso: "20-04-2026"),
        LoteItem(id: "L-1091", stock: 15, fechaIngreso: "10-05-2026"),
      ],
    ),
    ProductItem(
      name: "ErgoChair X-series",
      subtitle: "Breathable mesh with lumbar support",
      sku: "CH-ERG-881",
      category: "Mobiliario",
      stock: 210,
      maxStock: 250,
      price: 425.00,
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uj8I9f53CpSj40cca_fxt6KDo57B4z5FBtDqrwX6YOaNbbsU1WX7mEhu5cunyifZXLih2dswdROV7dw0Js73dJ6-qs5F2VgSeZBUVN4YFIaVu_oLsBL2c-rstYiGoQhE-uY0TM2gcuR09ryDxDAHAGOxRwKRDsshuF-3NnsAIx7hHyVwi16RaRRLlSy9jG1gnABu5nQv53OELiPWAR5XPkb_VxkSsTmeuvRyhFfaZfhzRVU6MflDLaPguo-x9gcLMgro1_ligRf5Q",
      lotes: [
        LoteItem(id: "L-3033", stock: 110, fechaIngreso: "01-04-2026"),
        LoteItem(id: "L-3034", stock: 100, fechaIngreso: "15-04-2026"),
      ],
    ),
  ];

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
