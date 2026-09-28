import sys

def improve_fallback():
    with open('lib/modulos/inventario/modelos_inventario.dart', 'r') as f:
        content = f.read()
    
    old_block = """            ProductoPedido(
              nombre: map['nombre'] ?? '',
              sku: map['sku'] ?? map['codigo_sku'] ?? '',
              costo: (map['costo'] as num?)?.toDouble() ?? 0.0,
              bodegas: [],
              descripcion: map['descripcion'] ?? '',
              codigoBarra: map['codigoBarra'] ?? map['codigo_barras'] ?? map['codigo_barra'] ?? map['barcode'] ?? map['codigo'] ?? id,
              categoria: map['categoria'] ?? 'General',
              proveedor: map['proveedor'] ?? '',
              cantidadMinima: map['cantidadMinima'] ?? map['cantidad_minima'] ?? 1,
              tipoProducto: map['tipoProducto'] ?? map['tipo_producto'] ?? 'Normal',
              fechaIngresado: map['fechaIngresado'] ?? map['fecha_ingreso'] ?? map['fecha'] ?? '',
              estado: map['estado'] ?? 'Activo',
            )"""

    new_block = """            ProductoPedido(
              nombre: map['nombre'] ?? '',
              sku: map['sku'] ?? map['codigo_sku'] ?? '',
              costo: (map['costo'] as num?)?.toDouble() ?? 0.0,
              bodegas: [],
              descripcion: map['descripcion'] ?? '',
              codigoBarra: (map['codigoBarra']?.toString().isNotEmpty == true) 
                  ? map['codigoBarra']
                  : (map['codigo_barras']?.toString().isNotEmpty == true) 
                      ? map['codigo_barras']
                      : (map['codigo']?.toString().isNotEmpty == true)
                          ? map['codigo']
                          : id,
              categoria: map['categoria'] ?? 'General',
              proveedor: map['proveedor'] ?? '',
              cantidadMinima: map['cantidadMinima'] ?? map['cantidad_minima'] ?? 1,
              tipoProducto: map['tipoProducto'] ?? map['tipo_producto'] ?? 'Normal',
              fechaIngresado: map['fechaIngresado'] ?? map['fecha_ingreso'] ?? map['fecha'] ?? '',
              estado: map['estado'] ?? 'Activo',
            )"""

    content = content.replace(old_block, new_block)

    with open('lib/modulos/inventario/modelos_inventario.dart', 'w') as f:
        f.write(content)

improve_fallback()
