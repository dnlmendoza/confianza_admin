import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modelos_inventario.dart';
import 'dart:async';
import 'servicio_inventario.dart';

class InventarioState {
  final List<ArticuloInventario> articulos;
  final String searchQuery;
  final ArticuloInventario? selectedArticulo;
  final int activeDetailTab;
  final int selectedLoteIndex;

  InventarioState({
    this.articulos = const [],
    this.searchQuery = '',
    this.selectedArticulo,
    this.activeDetailTab = 0,
    this.selectedLoteIndex = 0,
  });

  InventarioState copyWith({
    List<ArticuloInventario>? articulos,
    String? searchQuery,
    ArticuloInventario? selectedArticulo,
    int? activeDetailTab,
    int? selectedLoteIndex,
  }) {
    return InventarioState(
      articulos: articulos ?? this.articulos,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedArticulo: selectedArticulo ?? this.selectedArticulo,
      activeDetailTab: activeDetailTab ?? this.activeDetailTab,
      selectedLoteIndex: selectedLoteIndex ?? this.selectedLoteIndex,
    );
  }
}

class InventarioViewModel extends Notifier<InventarioState> {
  final _servicio = ServicioInventario();
  StreamSubscription? _subscription;
  StreamSubscription? _lotesSubscription;

  @override
  InventarioState build() {
    _subscription = _servicio.streamArticulos().listen((articulos) {
      // Al recibir una actualización, mantenemos el articulo seleccionado si aún existe
      ArticuloInventario? newSelected = state.selectedArticulo;
      if (newSelected != null) {
        try {
          final updatedRoot = articulos.firstWhere(
            (p) => p.id == newSelected!.id,
          );
          // Al reconstruir desde el root, los lotes vienen vacíos por estar en subcolección.
          // Debemos preservar los lotes que ya teníamos (que se actualizan por su propio stream)
          newSelected = ArticuloInventario(
            id: updatedRoot.id,
            nombre: updatedRoot.nombre,
            descripcion: updatedRoot.descripcion,
            proveedor: updatedRoot.proveedor,
            fecha: updatedRoot.fecha,
            pagadoPor: updatedRoot.pagadoPor,
            referencia: updatedRoot.referencia,
            descuento: updatedRoot.descuento,
            impuesto: updatedRoot.impuesto,
            envio: updatedRoot.envio,
            productos: updatedRoot.productos,
            lotes:
                state.selectedArticulo?.lotes ??
                [], // Mantenemos los lotes actuales
          );
        } catch (_) {
          newSelected = null;
        }
      }

      state = state.copyWith(
        articulos: articulos,
        selectedArticulo: newSelected,
      );
    });

    ref.onDispose(() {
      _subscription?.cancel();
      _lotesSubscription?.cancel();
    });

    return InventarioState(articulos: [], selectedArticulo: null);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> selectArticulo(ArticuloInventario articulo) async {
    state = state.copyWith(
      selectedArticulo: articulo,
      activeDetailTab: 0,
      selectedLoteIndex: 0,
    );

    _lotesSubscription?.cancel();
    _lotesSubscription = _servicio.streamLotesPorArticulo(articulo.id).listen((
      lotes,
    ) {
      lotes.sort(
        (a, b) => a.parsedFechaIngreso.compareTo(b.parsedFechaIngreso),
      );
      if (state.selectedArticulo?.id == articulo.id) {
        final current = state.selectedArticulo!;
        final updatedArticulo = ArticuloInventario(
          id: current.id,
          nombre: current.nombre,
          descripcion: current.descripcion,
          proveedor: current.proveedor,
          fecha: current.fecha,
          pagadoPor: current.pagadoPor,
          referencia: current.referencia,
          descuento: current.descuento,
          impuesto: current.impuesto,
          envio: current.envio,
          productos: current.productos,
          lotes: lotes,
        );
        state = state.copyWith(selectedArticulo: updatedArticulo);
      }
    });
  }

  Future<void> updateLote(
    ArticuloInventario articulo,
    LoteArticulo lote,
  ) async {
    final data = lote.toMap();

    // LIMPIEZA DE LOTE: El modelo verdadero NO incluye el 'codigo' dentro
    // del documento porque ya es el ID del documento en Firestore.
    data['codigo'] = FieldValue.delete();

    await _servicio.updateLote(articulo.id, lote.codigo, data);
  }

  Future<void> updateArticulo(ArticuloInventario articulo) async {
    final Map<String, dynamic> data = {};

    if (articulo.productos.isNotEmpty) {
      final prod = articulo.productos.first;

      // Campos de la raíz exactos según el modelo original
      data['nombre'] = prod.nombre;
      data['descripcion'] = prod.descripcion;
      data['proveedor'] = prod.proveedor;
      data['categoria'] = prod.categoria;
      data['estado'] = prod.estado;
      data['imagen'] = prod.imagen;
      data['cantidad_minima'] = prod.cantidadMinima;
      data['pesado'] = prod.pesado;
      data['menor_mayor'] =
          prod.tipoVenta == 'Ambos' || prod.tipoVenta == 'Mayor';
      data['fecha'] = prod.fechaIngresado.isNotEmpty
          ? prod.fechaIngresado
          : articulo.fecha;

      // LIMPIEZA TOTAL DE CAMPOS BASURA que se inyectaron históricamente
      // El modelo verdadero NO tiene array de "productos" en Inventario,
      // ni los campos de un "Articulo" comercial.
      data['productos'] = FieldValue.delete();
      data['descuento'] = FieldValue.delete();
      data['envio'] = FieldValue.delete();
      data['impuesto'] = FieldValue.delete();
      data['codigo_barras'] = FieldValue.delete();
      data['codigoBarra'] = FieldValue.delete();
      data['codigo'] = FieldValue.delete();
      data['pagadoPor'] = FieldValue.delete();
      data['referencia'] = FieldValue.delete();

      // Borramos los campos camelCase erróneos de la raíz
      data['cantidadMinima'] = FieldValue.delete();
      data['fechaIngresado'] = FieldValue.delete();
      data['codigoBarra'] = FieldValue.delete();
      data['tipo_venta'] = FieldValue.delete();
      data['sku'] = FieldValue.delete();
      data['costo'] = FieldValue.delete();
    }

    await _servicio.updateArticulo(articulo.id, data);
  }

  Future<void> createNuevoArticulo(
    ArticuloInventario articulo,
    LoteArticulo lote,
  ) async {
    final Map<String, dynamic> data = {};

    if (articulo.productos.isNotEmpty) {
      final prod = articulo.productos.first;

      data['nombre'] = prod.nombre;
      data['descripcion'] = prod.descripcion;
      data['proveedor'] = prod.proveedor;
      data['categoria'] = prod.categoria;
      data['estado'] = 'Activo'; // Siempre Activo para nuevos
      data['imagen'] = prod.imagen;
      data['cantidad_minima'] = prod.cantidadMinima;
      data['pesado'] = prod.pesado;
      data['menor_mayor'] =
          prod.tipoVenta == 'Ambos' || prod.tipoVenta == 'Mayor';
      data['fecha'] = prod.fechaIngresado.isNotEmpty
          ? prod.fechaIngresado
          : articulo.fecha;
    }

    final loteData = lote.toMap();
    loteData.remove('codigo');

    // El código de barras es el identificador único del documento raíz en Firebase
    final String newArticuloId = articulo.productos.isNotEmpty && articulo.productos.first.codigoBarra.isNotEmpty
        ? articulo.productos.first.codigoBarra.trim()
        : FirebaseFirestore.instance.collection('Inventario').doc().id;

    await _servicio.createArticulo(newArticuloId, data, loteData);

    // Deseleccionar y resetear al guardar con éxito
    unselectArticulo();
  }

  void unselectArticulo() {
    _lotesSubscription?.cancel();
    state = InventarioState(
      articulos: state.articulos,
      searchQuery: state.searchQuery,
      selectedArticulo: null,
      activeDetailTab: 0,
      selectedLoteIndex: 0,
    );
  }

  void setActiveDetailTab(int tabIndex) {
    state = state.copyWith(activeDetailTab: tabIndex);
  }

  void setSelectedLoteIndex(int index) {
    state = state.copyWith(selectedLoteIndex: index);
  }

  List<ArticuloInventario> get filteredArticulos {
    final query = state.searchQuery.toLowerCase().trim();
    if (query.isEmpty) return state.articulos;

    return state.articulos.where((p) {
      return p.nombre.toLowerCase().contains(query) ||
          p.proveedor.toLowerCase().contains(query) ||
          p.referencia.toLowerCase().contains(query);
    }).toList();
  }
}

final inventarioViewModelProvider =
    NotifierProvider<InventarioViewModel, InventarioState>(() {
      return InventarioViewModel();
    });
