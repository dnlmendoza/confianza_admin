import 'dart:async';
import 'package:flutter/foundation.dart';
import 'servicio_catalogos.dart';

class VMCatalogos extends ChangeNotifier {
  final ServicioCatalogos _servicio = ServicioCatalogos();

  List<String> categorias = [];
  List<String> proveedores = [];
  List<String> unidades = [];

  StreamSubscription? _subCategorias;
  StreamSubscription? _subProveedores;
  StreamSubscription? _subUnidades;

  VMCatalogos() {
    _initStreams();
  }

  void _initStreams() {
    _subCategorias = _servicio.streamCategorias().listen((data) {
      categorias = data;
      notifyListeners();
    });

    _subProveedores = _servicio.streamProveedores().listen((data) {
      proveedores = data;
      notifyListeners();
    });

    _subUnidades = _servicio.streamUnidades().listen((data) {
      unidades = data;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subCategorias?.cancel();
    _subProveedores?.cancel();
    _subUnidades?.cancel();
    super.dispose();
  }

  // Métodos para la UI
  Future<void> addCategoria(String nombre) => _servicio.addCategoria(nombre);
  Future<void> deleteCategoria(String nombre) => _servicio.deleteCategoria(nombre);
  Future<void> renameCategoria(String oldName, String newName) => _servicio.renameCategoria(oldName, newName);

  Future<void> addProveedor(String nombre) => _servicio.addProveedor(nombre);
  Future<void> deleteProveedor(String nombre) => _servicio.deleteProveedor(nombre);
  Future<void> renameProveedor(String oldName, String newName) => _servicio.renameProveedor(oldName, newName);

  Future<void> addUnidad(String nombre) => _servicio.addUnidad(nombre);
  Future<void> deleteUnidad(String nombre) => _servicio.deleteUnidad(nombre);
  Future<void> renameUnidad(String oldName, String newName) => _servicio.renameUnidad(oldName, newName);
}
