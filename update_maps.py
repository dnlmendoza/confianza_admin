import sys

def update_tab():
    with open('lib/modulos/inventario/widgets/inventory_tab_articles.dart', 'r') as f:
        content = f.read()

    # Update constructor to take maps
    content = content.replace("final List<String> categorias;", "final Map<String, String> categorias;")
    content = content.replace("final List<String> proveedores;", "final Map<String, String> proveedores;")
    
    # Replace DropdownFormField with MapDropdownFormField for Categoria and Proveedor
    
    old_cat = """                    child: DropdownFormField(
                      label: "Categoría",
                      currentValue: prod.categoria,
                      items: widget.categorias,
                      prefixIcon: Icons.category_outlined,"""
    new_cat = """                    child: MapDropdownFormField(
                      label: "Categoría",
                      currentValue: prod.categoria,
                      itemsMap: widget.categorias,
                      prefixIcon: Icons.category_outlined,"""
                      
    old_prov = """                    child: DropdownFormField(
                      label: "Proveedor",
                      currentValue: prod.proveedor,
                      items: widget.proveedores,
                      prefixIcon: Icons.local_shipping_outlined,"""
    new_prov = """                    child: MapDropdownFormField(
                      label: "Proveedor",
                      currentValue: prod.proveedor,
                      itemsMap: widget.proveedores,
                      prefixIcon: Icons.local_shipping_outlined,"""

    content = content.replace(old_cat, new_cat)
    content = content.replace(old_prov, new_prov)

    with open('lib/modulos/inventario/widgets/inventory_tab_articles.dart', 'w') as f:
        f.write(content)

update_tab()

def update_vista():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        content = f.read()
    
    # Update _buildProductosYTotalesSection calls
    old_call = """                  categorias: _vmCatalogos.categorias,
                  proveedores: _vmCatalogos.proveedores,"""
    new_call = """                  categorias: _vmCatalogos.categoriasMap,
                  proveedores: _vmCatalogos.proveedoresMap,"""
    
    content = content.replace(old_call, new_call)
    
    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.write(content)

update_vista()
