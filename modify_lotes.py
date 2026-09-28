import sys

def modify_lotes():
    with open('lib/modulos/inventario/modelos_inventario.dart', 'r') as f:
        content = f.read()

    old_from_map = """  factory LotePedido.fromMap(Map<String, dynamic> map) {
    final c = (map['costo'] as num?)?.toDouble() ?? 0.0;
    final s = map['stock'] ?? 0;
    return LotePedido(
      codigo: map['codigo'] ?? '',
      stock: s,
      fechaIngreso: map['fechaIngreso'] ?? '',
      fechaVencimiento: map['fechaVencimiento'] ?? '',
      costo: c,
      precioVenta: (map['precioVenta'] as num?)?.toDouble() ?? 0.0,
      unidades: map['unidades'] ?? 'UNIDAD',
      costoLote: (map['costoLote'] as num?)?.toDouble() ?? (c * s),
      impuestoCompra: (map['impuestoCompra'] as num?)?.toDouble() ?? 15.0,
      impuestoVenta: (map['impuestoVenta'] as num?)?.toDouble() ?? 15.0,
    );
  }"""

    new_from_map = """  factory LotePedido.fromMap(Map<String, dynamic> map) {
    final c = (map['costo'] as num?)?.toDouble() ?? (map['costo_unitario'] as num?)?.toDouble() ?? 0.0;
    final s = map['stock'] ?? map['cantidad'] ?? 0;
    return LotePedido(
      codigo: map['codigo'] ?? map['id'] ?? '',
      stock: s,
      fechaIngreso: map['fechaIngreso'] ?? map['fecha_ingreso'] ?? '',
      fechaVencimiento: map['fechaVencimiento'] ?? map['fecha_vencimiento'] ?? '',
      costo: c,
      precioVenta: (map['precioVenta'] as num?)?.toDouble() ?? (map['precio_venta'] as num?)?.toDouble() ?? 0.0,
      unidades: map['unidades'] ?? 'UNIDAD',
      costoLote: (map['costoLote'] as num?)?.toDouble() ?? (c * s),
      impuestoCompra: (map['impuestoCompra'] as num?)?.toDouble() ?? 15.0,
      impuestoVenta: (map['impuestoVenta'] as num?)?.toDouble() ?? 15.0,
    );
  }"""

    content = content.replace(old_from_map, new_from_map)

    with open('lib/modulos/inventario/modelos_inventario.dart', 'w') as f:
        f.write(content)

modify_lotes()
