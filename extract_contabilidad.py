import sys

def extract():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        lines = f.readlines()
    
    start_idx = -1
    end_idx = -1
    for i, line in enumerate(lines):
        if 'Widget _buildContabilidadTab' in line:
            start_idx = i
        if 'Widget _buildProductosYTotalesSection' in line:
            end_idx = i - 1
            break
            
    if start_idx == -1 or end_idx == -1:
        print("Not found")
        return
        
    method_lines = lines[start_idx:end_idx]
    
    # We will wrap it in InventoryTabAccounting
    header = """import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import '../modelos_inventario.dart';
import 'inventory_form_fields.dart';

class InventoryTabAccounting extends StatefulWidget {
  final PedidoInventario pedido;

  const InventoryTabAccounting({
    super.key,
    required this.pedido,
  });

  @override
  State<InventoryTabAccounting> createState() => _InventoryTabAccountingState();
}

class _InventoryTabAccountingState extends State<InventoryTabAccounting> {
  @override
  Widget build(BuildContext context) {
    return _buildContabilidadTab(widget.pedido);
  }

"""
    
    footer = """}
"""
    
    with open('lib/modulos/inventario/widgets/inventory_tab_accounting.dart', 'w') as f:
        f.write(header)
        f.writelines(method_lines)
        f.write(footer)
        
    print("Extracted successfully")

extract()
