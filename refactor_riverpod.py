import re

def refactor_riverpod():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        content = f.read()

    # 1. Add imports
    if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in content:
        content = content.replace("import 'package:flutter/material.dart';",
                                  "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'inventario_view_model.dart';")

    # 2. Change class signatures
    content = content.replace("class VistaInventario extends StatefulWidget", "class VistaInventario extends ConsumerStatefulWidget")
    content = content.replace("State<VistaInventario> createState() => _VistaInventarioState();", "ConsumerState<VistaInventario> createState() => _VistaInventarioState();")
    content = content.replace("class _VistaInventarioState extends State<VistaInventario>", "class _VistaInventarioState extends ConsumerState<VistaInventario>")

    # 3. Replace state declarations
    state_decls = """  final List<PedidoInventario> _pedidos = [];
  PedidoInventario? _selectedPedido;
  int _activeDetailTab =
      0; // 0: Datos Artículos, 1: Contabilidad, 2: Datos Lotes
  int _selectedLoteIndex = 0;"""
    
    new_state_decls = """  List<PedidoInventario> get _pedidos => ref.watch(inventarioViewModelProvider).pedidos;
  PedidoInventario? get _selectedPedido => ref.watch(inventarioViewModelProvider).selectedPedido;
  int get _activeDetailTab => ref.watch(inventarioViewModelProvider).activeDetailTab;
  int get _selectedLoteIndex => ref.watch(inventarioViewModelProvider).selectedLoteIndex;"""
    
    if state_decls in content:
        content = content.replace(state_decls, new_state_decls)

    # 4. Filtered Pedidos
    filtered_method = """  List<PedidoInventario> get _filteredPedidos {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _pedidos;
    return _pedidos.where((p) {
      return p.nombre.toLowerCase().contains(query) ||
          p.descripcion.toLowerCase().contains(query) ||
          p.proveedor.toLowerCase().contains(query);
    }).toList();
  }"""
    
    new_filtered_method = """  List<PedidoInventario> get _filteredPedidos => ref.watch(inventarioViewModelProvider.notifier).filteredPedidos;"""
    
    if filtered_method in content:
        content = content.replace(filtered_method, new_filtered_method)

    # 5. Connect Search Controller in initState
    init_state_pattern = """  void initState() {
    super.initState();
    _vmCatalogos = VMCatalogos()
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }"""
    
    new_init_state = """  void initState() {
    super.initState();
    _vmCatalogos = VMCatalogos()
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    _searchController.addListener(() {
      ref.read(inventarioViewModelProvider.notifier).setSearchQuery(_searchController.text);
    });
  }"""
    
    if init_state_pattern in content:
        content = content.replace(init_state_pattern, new_init_state)

    # 6. Replace mutations inside setState block
    # It's usually `setState(() { _selectedPedido = pedido; _activeDetailTab = 0; _selectedLoteIndex = 0; });`
    content = content.replace("_selectedPedido = pedido;", "ref.read(inventarioViewModelProvider.notifier).selectPedido(pedido);")
    content = content.replace("_selectedPedido = null;", "ref.read(inventarioViewModelProvider.notifier).unselectPedido();")
    content = content.replace("_activeDetailTab = 1;", "ref.read(inventarioViewModelProvider.notifier).setActiveDetailTab(1);")
    content = content.replace("_activeDetailTab = 0;", "ref.read(inventarioViewModelProvider.notifier).setActiveDetailTab(0);")
    content = content.replace("_activeDetailTab = index;", "ref.read(inventarioViewModelProvider.notifier).setActiveDetailTab(index);")
    content = content.replace("_selectedLoteIndex = i;", "ref.read(inventarioViewModelProvider.notifier).setSelectedLoteIndex(i);")

    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.write(content)
        
    print("Refactored to Riverpod successfully")

refactor_riverpod()
