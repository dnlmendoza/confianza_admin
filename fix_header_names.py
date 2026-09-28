import sys

def fix_vista():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        content = f.read()
    
    old_block = """                  Expanded(
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

    new_block = """                  Expanded(
                    child: _buildMetadataItem(
                      "CATEGORIA",
                      pedido.productos.isNotEmpty 
                          ? _vmCatalogos.categoriasMap[pedido.productos.first.categoria] ?? pedido.productos.first.categoria 
                          : "N/A",
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
                      pedido.productos.isNotEmpty 
                          ? _vmCatalogos.proveedoresMap[pedido.productos.first.proveedor] ?? pedido.productos.first.proveedor 
                          : "N/A",
                      Icons.local_shipping_outlined,
                    ),
                  ),"""

    content = content.replace(old_block, new_block)
    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.write(content)

fix_vista()
