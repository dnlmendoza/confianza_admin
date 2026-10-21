import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confianza_admin/modulos/catalogos/servicio_catalogos.dart';

class ViewModelCierre extends ChangeNotifier {
  // Navigation & Tabs
  int _activeTab = 0; // 0 = Ingresos, 1 = Egresos
  int get activeTab => _activeTab;
  void setActiveTab(int index) {
    if (_activeTab != index) {
      _activeTab = index;
      deseleccionarRecibo();
      notifyListeners();
    }
  }

  bool isReceiptEgreso(Map<String, dynamic>? data) {
    if (data == null) return false;
    if (data['isEgreso'] == true) return true;
    final rec = (data['recibo']?.toString() ?? '').trim().toUpperCase();
    if (rec.startsWith('E-') || rec.startsWith('RECIBO E-')) return true;
    return false;
  }


  // Current User Profile
  String _nombreUsuarioActual = '';
  String get nombreUsuarioActual => _nombreUsuarioActual;
  String _idUsuarioActual = '';
  String get idUsuarioActual => _idUsuarioActual;
  Future<DocumentSnapshot>? _usuarioFuture;
  Future<DocumentSnapshot>? get usuarioFuture => _usuarioFuture;

  // Selected Receipt
  Map<String, dynamic>? _selectedRecibo;
  Map<String, dynamic>? get selectedRecibo => _selectedRecibo;

  // Bills Counting
  static const List<int> billetesFila1 = [500, 200, 100, 50, 20];
  static const List<int> billetesFila2 = [10, 5, 2, 1];

  final Map<int, int> _conteoBilletes = {
    500: 0,
    200: 0,
    100: 0,
    50: 0,
    20: 0,
    10: 0,
    5: 0,
    2: 0,
    1: 0,
  };
  Map<int, int> get conteoBilletes => _conteoBilletes;

  int _selectedDenominacion = 100;
  int get selectedDenominacion => _selectedDenominacion;

  final TextEditingController stepperController = TextEditingController();

  // Suppliers & Providers
  final TextEditingController proveedorController = TextEditingController();
  final FocusNode proveedorFocusNode = FocusNode();
  String? _proveedorSeleccionadoActivo;
  String? get proveedorSeleccionadoActivo => _proveedorSeleccionadoActivo;
  set proveedorSeleccionadoActivo(String? val) {
    _proveedorSeleccionadoActivo = val;
    notifyListeners();
  }

  // Egreso Total
  final TextEditingController totalEgresoController = TextEditingController();
  final FocusNode totalEgresoFocusNode = FocusNode();

  StreamSubscription? _proveedoresSub;
  final Map<String, String> _proveedoresMap = {};
  Map<String, String> get proveedoresMap => _proveedoresMap;
  List<String> _catalogoProveedores = [];
  List<String> get catalogoProveedores => _catalogoProveedores;

  // Streams
  Stream<QuerySnapshot> get ventasStream => FirebaseFirestore.instance
      .collection('Ventas')
      .where('fecha', isEqualTo: fechaHoy)
      .snapshots();

  Stream<QuerySnapshot> get cierreStream => FirebaseFirestore.instance
      .collection('Cierre')
      .where('fecha', isEqualTo: fechaHoy)
      .snapshots();

  String get fechaHoy {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
  }

  String get horaActual {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  ViewModelCierre() {
    _cargarUsuarioActual();
    _initCatalogos();
    totalEgresoFocusNode.addListener(_onTotalEgresoFocusChanged);
  }

  void _onTotalEgresoFocusChanged() {
    if (!totalEgresoFocusNode.hasFocus) {
      formatearTotalEgresoMonetario();
    }
  }

  void _cargarUsuarioActual() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _idUsuarioActual = user.uid;
      try {
        final doc = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final String nombresRaw = (data['Nombres'] ??
                  data['nombres'] ??
                  data['Nombre'] ??
                  data['nombre'] ??
                  '')
              .toString()
              .trim();
          final String apellidosRaw = (data['Apellidos'] ??
                  data['apellidos'] ??
                  data['Apellido'] ??
                  data['apellido'] ??
                  '')
              .toString()
              .trim();

          final String primerNombre = nombresRaw.isNotEmpty
              ? nombresRaw.split(RegExp(r'\s+')).first
              : '';
          final String primerApellido = apellidosRaw.isNotEmpty
              ? apellidosRaw.split(RegExp(r'\s+')).first
              : '';

          final fullName = "$primerNombre $primerApellido".trim();
          if (fullName.isNotEmpty) {
            _nombreUsuarioActual = fullName;
            if (_selectedRecibo?['isNuevo'] == true) {
              _selectedRecibo!['usuario'] = fullName;
            }
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        debugPrint("Error cargando perfil del usuario actual: $e");
      }

      final fallback = user.displayName?.trim() ??
          user.email?.split('@').first ??
          'Administrador';
      _nombreUsuarioActual = fallback;
      if (_selectedRecibo?['isNuevo'] == true) {
        _selectedRecibo!['usuario'] = fallback;
      }
      notifyListeners();
    }
  }

  void _initCatalogos() {
    _proveedoresSub = ServicioCatalogos().streamProveedores().listen((data) {
      _proveedoresMap.clear();
      _proveedoresMap.addAll({for (var e in data) e.key: e.value});
      _catalogoProveedores = data
          .map((e) => e.value.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      notifyListeners();
    });
    _cargarProveedoresFallback();
  }

  void _cargarProveedoresFallback() async {
    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('Catalogos')
          .doc('configuracion')
          .get();
      if (docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        final list = (data['proveedores'] ??
                data['items'] ??
                data['lista'] ??
                data['nombres']) as List<dynamic>? ??
            [];
        for (final item in list) {
          if (item is Map) {
            final id = item['id']?.toString() ?? '';
            final nombre =
                (item['nombre'] ?? item['name'] ?? '').toString().trim();
            if (id.isNotEmpty && nombre.isNotEmpty) {
              _proveedoresMap[id] = nombre;
            }
            if (nombre.isNotEmpty && !_catalogoProveedores.contains(nombre)) {
              _catalogoProveedores.add(nombre);
            }
          } else if (item is String && item.trim().isNotEmpty) {
            final n = item.trim();
            if (!_catalogoProveedores.contains(n)) {
              _catalogoProveedores.add(n);
            }
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<List<String>> obtenerSearchIdsParaProveedor(String proveedor) async {
    String normalizar(String s) {
      return s
          .toLowerCase()
          .trim()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ñ', 'n');
    }

    final targetNorm = normalizar(proveedor);
    final Set<String> ids = {proveedor.trim()};

    _proveedoresMap.forEach((id, nombre) {
      final normNombre = normalizar(nombre);
      final normId = normalizar(id);
      if (normNombre == targetNorm ||
          normNombre.contains(targetNorm) ||
          targetNorm.contains(normNombre) ||
          normId == targetNorm) {
        if (id.isNotEmpty) ids.add(id);
        if (nombre.isNotEmpty) ids.add(nombre);
      }
    });

    if (ids.length <= 1) {
      try {
        final docSnap = await FirebaseFirestore.instance
            .collection('Catalogos')
            .doc('configuracion')
            .get();
        if (docSnap.exists && docSnap.data() != null) {
          final provs =
              (docSnap.data()!['proveedores'] as List<dynamic>?) ?? [];
          for (final item in provs) {
            if (item is Map) {
              final id = item['id']?.toString() ?? '';
              final nombre = item['nombre']?.toString() ?? '';
              final normNombre = normalizar(nombre);
              final normId = normalizar(id);
              if (normNombre == targetNorm ||
                  normNombre.contains(targetNorm) ||
                  targetNorm.contains(normNombre) ||
                  normId == targetNorm) {
                if (id.isNotEmpty) {
                  ids.add(id);
                  _proveedoresMap[id] = nombre;
                }
                if (nombre.isNotEmpty) ids.add(nombre);
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Error buscando IDs de proveedor: $e");
      }
    }

    return ids.take(10).toList();
  }

  // Bills Counting Operations
  double get totalConteo {
    double total = 0.0;
    _conteoBilletes.forEach((denom, cantidad) {
      total += denom * cantidad;
    });
    return total;
  }

  String formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$integerPart.${parts[1]}';
  }

  void selectDenominacion(int denom) {
    if (_selectedDenominacion == denom) {
      final current = _conteoBilletes[denom] ?? 0;
      final next = current + 1;
      _conteoBilletes[denom] = next;
      stepperController.text = '$next';
    } else {
      _selectedDenominacion = denom;
      final current = _conteoBilletes[denom] ?? 0;
      stepperController.text = current == 0 ? '' : '$current';
    }
    notifyListeners();
  }

  void incrementSelected() {
    final current = _conteoBilletes[_selectedDenominacion] ?? 0;
    final next = current + 1;
    _conteoBilletes[_selectedDenominacion] = next;
    stepperController.text = '$next';
    notifyListeners();
  }

  void decrementSelected() {
    final current = _conteoBilletes[_selectedDenominacion] ?? 0;
    if (current > 0) {
      final next = current - 1;
      _conteoBilletes[_selectedDenominacion] = next;
      stepperController.text = next == 0 ? '' : '$next';
      notifyListeners();
    }
  }

  void setDenominacionCount(int denom, int count) {
    _conteoBilletes[denom] = count;
    notifyListeners();
  }

  void resetConteo() {
    for (final denom in _conteoBilletes.keys) {
      _conteoBilletes[denom] = 0;
    }
    stepperController.text = '';
    notifyListeners();
  }

  Color getDenomBaseColor(int denom) {
    switch (denom) {
      case 500:
        return const Color(0xFF4A5C8C);
      case 200:
        return const Color(0xFF5D938B);
      case 100:
        return const Color(0xFFC79251);
      case 50:
        return const Color(0xFF477395);
      case 20:
        return const Color(0xFF5A7F4F);
      case 10:
        return const Color(0xFFA25B49);
      case 5:
        return const Color(0xFF647768);
      case 2:
        return const Color(0xFF7E5F7A);
      case 1:
        return const Color(0xFFDF5844);
      default:
        return Colors.white;
    }
  }

  Color getDenomColor(int denom) {
    final base = getDenomBaseColor(denom);
    return Color.lerp(base, Colors.white, 0.22) ?? base;
  }

  // Receipt Selection & Operations
  void seleccionarRecibo(Map<String, dynamic> data) {
    _selectedRecibo = Map<String, dynamic>.from(data);
    if (_selectedRecibo!['articulos'] is List) {
      _selectedRecibo!['articulos'] =
          List<dynamic>.from(_selectedRecibo!['articulos'] as List);
    }
    final bool esEgreso = isReceiptEgreso(data);

    if (esEgreso) {
      proveedorFocusNode.unfocus();
      final prov = (data['proveedor']?.toString() ?? '').trim();
      proveedorController.text = prov;
      _proveedorSeleccionadoActivo = prov.isNotEmpty ? prov : null;

      totalEgresoFocusNode.unfocus();
      final rawTotal = data['total'];
      if (rawTotal is num) {
        totalEgresoController.text = rawTotal.toStringAsFixed(2);
      } else if (rawTotal != null && rawTotal.toString().trim().isNotEmpty) {
        final parsed =
            double.tryParse(rawTotal.toString().trim().replaceAll(',', ''));
        totalEgresoController.text = parsed != null
            ? parsed.toStringAsFixed(2)
            : rawTotal.toString().trim();
      } else {
        totalEgresoController.text = '0.00';
      }
    } else {
      proveedorFocusNode.unfocus();
      proveedorController.text = '';
      _proveedorSeleccionadoActivo = null;

      totalEgresoFocusNode.unfocus();
      totalEgresoController.text = '';
    }

    String? candidato = (data['id_usuario'] ??
            data['usuario'] ??
            data['vendedor'])
        ?.toString()
        .trim();

    if (data['isNuevo'] == true ||
        candidato == null ||
        candidato.isEmpty ||
        candidato == 'Caja') {
      final currentUid =
          FirebaseAuth.instance.currentUser?.uid ?? _idUsuarioActual;
      if (currentUid.isNotEmpty) {
        candidato = currentUid;
      }
    }

    if (candidato != null &&
        candidato.isNotEmpty &&
        candidato != 'Caja' &&
        candidato != 'S/N' &&
        !candidato.contains(' ')) {
      _usuarioFuture = FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(candidato)
          .get();
    } else {
      _usuarioFuture = null;
    }
    notifyListeners();
  }

  void deseleccionarRecibo() {
    _selectedRecibo = null;
    _usuarioFuture = null;
    proveedorFocusNode.unfocus();
    proveedorController.text = '';
    _proveedorSeleccionadoActivo = null;
    totalEgresoFocusNode.unfocus();
    totalEgresoController.text = '';
    notifyListeners();
  }

  // Business Rules for Provider & Articles
  bool tieneArticulos([Map<String, dynamic>? recibo]) {
    final target = recibo ?? _selectedRecibo;
    if (target != null && target['articulos'] is List) {
      return (target['articulos'] as List).isNotEmpty;
    }
    return false;
  }

  String proveedorFijado([Map<String, dynamic>? recibo]) {
    final target = recibo ?? _selectedRecibo;
    return (target?['proveedor']?.toString() ?? '').trim();
  }

  bool puedeCambiarProveedor([Map<String, dynamic>? recibo]) {
    return !tieneArticulos(recibo);
  }

  String? validarAsignacionProveedor(String nuevoProveedor) {
    final provActual = proveedorFijado();
    if (tieneArticulos() &&
        provActual.isNotEmpty &&
        nuevoProveedor.trim().toLowerCase() != provActual.toLowerCase()) {
      return "Este recibo ya contiene artículos de $provActual. Elimine los artículos para cambiar de proveedor.";
    }
    return null;
  }

  void onProveedorSelected(String selection) {
    _proveedorSeleccionadoActivo = selection;
    proveedorFocusNode.unfocus();
    proveedorController.text = selection;
    if (_selectedRecibo != null) {
      _selectedRecibo!['proveedor'] = selection;
    }
    notifyListeners();
  }

  void onProveedorChanged(String val) {
    if (_proveedorSeleccionadoActivo != null &&
        val.trim().toLowerCase() !=
            _proveedorSeleccionadoActivo!.trim().toLowerCase()) {
      _proveedorSeleccionadoActivo = null;
    }
    if (_selectedRecibo != null) {
      _selectedRecibo!['proveedor'] = val;
    }
    notifyListeners();
  }

  void onTotalEgresoChanged(String val) {
    final cleanVal = val.trim().replaceAll(',', '');
    final parsed = double.tryParse(cleanVal);
    if (_selectedRecibo != null) {
      _selectedRecibo!['total'] = parsed ?? 0.0;
    }
    notifyListeners();
  }

  void formatearTotalEgresoMonetario() {
    final cleanVal = totalEgresoController.text.trim().replaceAll(',', '');
    if (cleanVal.isNotEmpty) {
      final parsed = double.tryParse(cleanVal);
      if (parsed != null) {
        totalEgresoController.text = parsed.toStringAsFixed(2);
        if (_selectedRecibo != null) {
          _selectedRecibo!['total'] = parsed;
        }
      }
    } else {
      totalEgresoController.text = '0.00';
      if (_selectedRecibo != null) {
        _selectedRecibo!['total'] = 0.0;
      }
    }
    notifyListeners();
  }

  void actualizarArticulosRecibo(
    List<Map<String, dynamic>> nuevosArticulos,
    String proveedor,
  ) {
    if (_selectedRecibo != null) {
      _selectedRecibo!['articulos'] = nuevosArticulos;
      _selectedRecibo!['proveedor'] = proveedor;
    }
    proveedorController.text = proveedor;
    _proveedorSeleccionadoActivo = proveedor;
    notifyListeners();
  }

  void removerArticuloRecibo(int index) {
    if (_selectedRecibo != null && _selectedRecibo!['articulos'] is List) {
      final list = List<dynamic>.from(_selectedRecibo!['articulos'] as List);
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
        _selectedRecibo!['articulos'] = list;
        if (list.isEmpty) {
          _proveedorSeleccionadoActivo = null;
        }
        notifyListeners();
      }
    }
  }

  Iterable<String> filtrarProveedores(String query) {
    if (tieneArticulos()) {
      return const Iterable<String>.empty();
    }
    if (!proveedorFocusNode.hasFocus) {
      return const Iterable<String>.empty();
    }
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return const Iterable<String>.empty();
    }
    if (_proveedorSeleccionadoActivo != null &&
        q == _proveedorSeleccionadoActivo!.trim().toLowerCase()) {
      return const Iterable<String>.empty();
    }
    return _catalogoProveedores.where(
      (p) => p.toLowerCase().contains(q),
    );
  }

  @override
  void dispose() {
    stepperController.dispose();
    proveedorController.dispose();
    proveedorFocusNode.dispose();
    totalEgresoFocusNode.removeListener(_onTotalEgresoFocusChanged);
    totalEgresoController.dispose();
    totalEgresoFocusNode.dispose();
    _proveedoresSub?.cancel();
    super.dispose();
  }
}
