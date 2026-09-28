import sys
import re

def update_vista_inventario():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        content = f.read()

    # Import
    if "import 'widgets/inventory_tab_lote.dart';" not in content:
        content = content.replace(
            "import 'widgets/inventory_tab_articles.dart';",
            "import 'widgets/inventory_tab_articles.dart';\nimport 'widgets/inventory_tab_lote.dart';"
        )

    # Usage replacement
    old_usage = """              : _activeDetailTab == 1
              ? _buildContabilidadTab(pedido)"""
    new_usage = """              : _activeDetailTab == 1
              ? InventoryTabLote(
                  pedido: pedido,
                  selectedLoteIndex: _selectedLoteIndex,
                  onUpdate: () => setState(() {}),
                )"""
    content = content.replace(old_usage, new_usage)

    # Remove _buildContabilidadTab
    start_str = "Widget _buildContabilidadTab(PedidoInventario pedido) {"
    if start_str in content:
        start_idx = content.find(start_str)
        # We need to find the matching closing brace.
        brace_count = 0
        end_idx = start_idx
        found_first_brace = False
        for i in range(start_idx, len(content)):
            if content[i] == '{':
                brace_count += 1
                found_first_brace = True
            elif content[i] == '}':
                brace_count -= 1
            if found_first_brace and brace_count == 0:
                end_idx = i
                break
        
        # also remove any trailing newlines or whitespace
        content = content[:start_idx] + content[end_idx+1:]

    # One more thing: I need to delete the `_buildInteractiveTaxField` and `_buildInteractiveNumberField` 
    # from vista_inventario.dart because I moved them to the new widget. But maybe it's safer to leave them if they are used elsewhere.
    
    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.write(content)

update_vista_inventario()
