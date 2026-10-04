import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modelos_generador.dart';
import 'servicio_generador.dart';
import '../inventario/inventario_view_model.dart';

class ViewModelGenerador extends Notifier<int> {
  final ServicioGenerador _servicio = ServicioGenerador();
  StreamSubscription<List<BarcodeEntry>>? _codigosSub;

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

  // Listas de datos
  List<BarcodeEntry> generatedCodes = [];
  List<BarcodeEntry> reprintCodes = [];
  List<BarcodeEntry> printQueue = [];

  @override
  int build() {
    productNameController.addListener(notifyListeners);
    skuController.addListener(notifyListeners);
    priceController.addListener(notifyListeners);
    
    // Iniciar escucha a Firebase
    _listenToFirebase();
    
    ref.onDispose(() {
      _codigosSub?.cancel();
      productNameController.dispose();
      skuController.dispose();
      priceController.dispose();
    });
    
    return 0;
  }

  void _listenToFirebase() {
    _codigosSub = _servicio.listenToCodigos().listen((codigos) {
      final inventarioState = ref.read(inventarioViewModelProvider);
      
      generatedCodes.clear();
      reprintCodes.clear();
      for (var c in codigos) {
        c.enInventario = inventarioState.articulos.any((a) => a.productos.isNotEmpty && a.productos.first.codigoBarra == c.barcode);
        
        if (c.hasOriginalCode) {
          reprintCodes.add(c);
        } else {
          generatedCodes.add(c);
        }
      }
      notifyListeners();
    });

    ref.listen(inventarioViewModelProvider, (previous, next) {
      bool changed = false;
      for (var c in generatedCodes) {
        final newStatus = next.articulos.any((a) => a.productos.isNotEmpty && a.productos.first.codigoBarra == c.barcode);
        if (c.enInventario != newStatus) {
          c.enInventario = newStatus;
          changed = true;
        }
      }
      for (var c in reprintCodes) {
        final newStatus = next.articulos.any((a) => a.productos.isNotEmpty && a.productos.first.codigoBarra == c.barcode);
        if (c.enInventario != newStatus) {
          c.enInventario = newStatus;
          changed = true;
        }
      }
      if (changed) {
        notifyListeners();
      }
    });
  }

  void notifyListeners() {
    state++;
  }
}

final generadorViewModelProvider = NotifierProvider<ViewModelGenerador, int>(() {
  return ViewModelGenerador();
});
