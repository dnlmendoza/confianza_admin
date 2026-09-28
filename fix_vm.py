import sys

def fix_vm():
    content = """import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void selectPedido(PedidoInventario pedido) {
    state = state.copyWith(
      selectedPedido: pedido,
      activeDetailTab: 0,
      selectedLoteIndex: 0,
    );
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
"""
    with open('lib/modulos/inventario/inventario_view_model.dart', 'w') as f:
        f.write(content)

fix_vm()
