import sys
import re

def fix_vista():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        content = f.read()

    # The block we want to replace starts around line 1750
    # Let's use regex to find and replace the _buildMetadataItem calls in the header
    
    old_block = """                  Expanded(
                    child: _buildMetadataItem(
                      "CODIGO DE BARRAS",
                      pedido.proveedor,
                      Icons.view_week_outlined,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _buildMetadataItem(
                      "FECHA INGRESO",
                      pedido.fecha,
                      Icons.calendar_month_outlined,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _buildMetadataItem(
                      "CATEGORIA",
                      pedido.pagadoPor,
                      Icons.category_outlined,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _buildMetadataItem(
                      "PROVEEDOR",
                      pedido.referencia.isEmpty ? "Sin Ref" : pedido.referencia,
                      Icons.local_shipping_outlined,
                    ),
                  ),"""

    new_block = """                  Expanded(
                    child: _buildMetadataItem(
                      "CODIGO DE BARRAS",
                      pedido.productos.isNotEmpty ? pedido.productos.first.codigoBarra : "N/A",
                      Icons.view_week_outlined,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _buildMetadataItem(
                      "FECHA INGRESO",
                      pedido.productos.isNotEmpty ? pedido.productos.first.fechaIngresado : "N/A",
                      Icons.calendar_month_outlined,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _buildMetadataItem(
                      "CATEGORIA",
                      pedido.productos.isNotEmpty ? pedido.productos.first.categoria : "N/A",
                      Icons.category_outlined,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _buildMetadataItem(
                      "PROVEEDOR",
                      pedido.productos.isNotEmpty ? pedido.productos.first.proveedor : "N/A",
                      Icons.local_shipping_outlined,
                    ),
                  ),"""

    content = content.replace(old_block, new_block)

    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.write(content)

fix_vista()
