import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modelos_inventario.dart';
import 'dart:async';
import 'servicio_inventario.dart';

class InventarioState {
  final List<PedidoInventario> pedidos;
  final String searchQuery;
  final PedidoInventario? selectedPedido;
  final int activeDetailTab;
  final int selectedLoteIndex;

  InventarioState({
    this.pedidos = const [],
    this.searchQuery = '',
    this.selectedPedido,
    this.activeDetailTab = 0,
    this.selectedLoteIndex = 0,
  });

  InventarioState copyWith({
    List<PedidoInventario>? pedidos,
    String? searchQuery,
    PedidoInventario? selectedPedido,
    int? activeDetailTab,
    int? selectedLoteIndex,
  }) {
    return InventarioState(
      pedidos: pedidos ?? this.pedidos,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPedido: selectedPedido ?? this.selectedPedido,
      activeDetailTab: activeDetailTab ?? this.activeDetailTab,
      selectedLoteIndex: selectedLoteIndex ?? this.selectedLoteIndex,
    );
  }
}

class InventarioViewModel extends Notifier<InventarioState> {
  final _servicio = ServicioInventario();
  StreamSubscription? _subscription;

  @override
  InventarioState build() {
    _subscription = _servicio.streamPedidos().listen((pedidos) {
      // Al recibir una actualización, mantenemos el pedido seleccionado si aún existe
      PedidoInventario? newSelected = state.selectedPedido;
      if (newSelected != null) {
        try {
          newSelected = pedidos.firstWhere((p) => p.id == newSelected!.id);
        } catch (_) {
          newSelected = null;
        }
      }
      
      state = state.copyWith(
        pedidos: pedidos,
        selectedPedido: newSelected,
      );
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return InventarioState(
      pedidos: [],
      selectedPedido: null,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> selectPedido(PedidoInventario pedido) async {
    state = state.copyWith(
      selectedPedido: pedido,
      activeDetailTab: 0,
      selectedLoteIndex: 0,
    );
    
    final lotes = await _servicio.getLotesPorPedido(pedido.id);
    if (state.selectedPedido?.id == pedido.id) {
      final updatedPedido = PedidoInventario(
        id: pedido.id,
        nombre: pedido.nombre,
        descripcion: pedido.descripcion,
        proveedor: pedido.proveedor,
        fecha: pedido.fecha,
        pagadoPor: pedido.pagadoPor,
        referencia: pedido.referencia,
        descuento: pedido.descuento,
        impuesto: pedido.impuesto,
        envio: pedido.envio,
        productos: pedido.productos,
        lotes: lotes,
      );
      state = state.copyWith(selectedPedido: updatedPedido);
    }
  }

  Future<void> updateLote(PedidoInventario pedido, LotePedido lote) async {
    // Convert to map and ensure ganancia is also synced if needed (it is calculated in UI, but if DB needs it we can add it to toMap)
    final data = lote.toMap();
    // Assuming lote.codigo holds the document ID because of our fromMap logic.
    // If it doesn't, we might need a separate id field, but earlier we saw loteData['id'] = loteDoc.id was used in fromMap,
    // which mapped 'id' to 'codigo' if 'codigo' was null.
    // Wait, let's just use lote.codigo for the document ID.
    await _servicio.updateLote(pedido.id, lote.codigo, data);
    
    // Refresh local state if needed (optional since the stream might trigger, or the UI is already updated via local state)
  }

  void unselectPedido() {
    state = InventarioState(
      pedidos: state.pedidos,
      searchQuery: state.searchQuery,
      selectedPedido: null,
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

  List<PedidoInventario> get filteredPedidos {
    final query = state.searchQuery.toLowerCase().trim();
    if (query.isEmpty) return state.pedidos;

    return state.pedidos.where((p) {
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
