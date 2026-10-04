import 'dart:async';
import 'package:flutter/foundation.dart';
import 'servicio_catalogos.dart';

class VMCatalogos extends ChangeNotifier {
  final ServicioCatalogos _servicio = ServicioCatalogos();

  List<String> categorias = [];
  Map<String, String> categoriasMap = {};
  List<String> proveedores = [];
  Map<String, String> proveedoresMap = {};
  List<String> unidades = [];
  Map<String, String> unidadesMap = {};
  List<String> unidadesMayor = [];
  Map<String, String> unidadesMayorMap = {};

  List<Map<String, dynamic>> unidadesData = [];

  StreamSubscription? _subCategorias;
  StreamSubscription? _subProveedores;
  StreamSubscription? _subUnidades;

  VMCatalogos() {
    _initStreams();
  }

  void _initStreams() {
    _subCategorias = _servicio.streamCategorias().listen((data) {
      categoriasMap = { for (var e in data) e.key: e.value };
      categorias = data.map((e) => e.value).toList();
      notifyListeners();
    });

    _subProveedores = _servicio.streamProveedores().listen((data) {
      proveedoresMap = { for (var e in data) e.key: e.value };
      proveedores = data.map((e) => e.value).toList();
      notifyListeners();
    });

    _subUnidades = _servicio.streamUnidadesData().listen((data) {
      unidadesMap = {};
      unidadesMayorMap = {};
      unidades = [];
      unidadesMayor = [];
      unidadesData = data;
      
      for (var doc in data) {
        final id = doc['id'] as String;
        final nameVal = doc['nameVal'] as String;
        final bool isMayor = doc['mayor'] == true || doc['menor_mayor'] == true;
        
        if (isMayor) {
          unidadesMayorMap[id] = nameVal;
          unidadesMayor.add(nameVal);
        } else {
          unidadesMap[id] = nameVal;
          unidades.add(nameVal);
        }
      }
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

  Future<void> addUnidad(String nombre, String abreviado, bool menorMayor) => _servicio.addUnidad(nombre, abreviado, menorMayor);
  Future<void> updateUnidad(String id, String nombre, String abreviado, bool menorMayor) => _servicio.updateUnidad(id, nombre, abreviado, menorMayor);
  Future<void> deleteUnidad(String nombre) => _servicio.deleteUnidad(nombre);
  Future<void> renameUnidad(String oldName, String newName) => _servicio.renameUnidad(oldName, newName);
}
