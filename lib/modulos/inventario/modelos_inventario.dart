class BodegaDistribucion {
  String nombre;
  int cantidad;

  BodegaDistribucion({required this.nombre, required this.cantidad});

  Map<String, dynamic> toMap() => {'nombre': nombre, 'cantidad': cantidad};

  factory BodegaDistribucion.fromMap(Map<String, dynamic> map) {
    return BodegaDistribucion(
      nombre: map['nombre'] ?? '',
      cantidad: map['cantidad'] ?? 0,
    );
  }
}

class ProductoPedido {
  String nombre;
  String sku;
  double costo;
  List<BodegaDistribucion> bodegas;
  String descripcion;
  String codigoBarra;
  String categoria;
  String proveedor;
  int cantidadMinima;
  String tipoProducto;
  String tipoVenta;
  String fechaIngresado;
  String estado;
  String imagen;

  ProductoPedido({
    required this.nombre,
    required this.sku,
    required this.costo,
    required this.bodegas,
    this.descripcion = '',
    this.codigoBarra = '',
    this.categoria = 'General',
    this.proveedor = '',
    this.cantidadMinima = 1,
    this.tipoProducto = 'Normal',
    this.tipoVenta = 'Menor',
    this.fechaIngresado = '',
    this.estado = 'Activo',
    this.imagen = '',
  });

  int get totalStock => bodegas.fold(0, (total, b) => total + b.cantidad);
  double get subtotal => costo * totalStock;

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'sku': sku,
    'costo': costo,
    'bodegas': bodegas.map((b) => b.toMap()).toList(),
    'descripcion': descripcion,
    'codigoBarra': codigoBarra,
    'categoria': categoria,
    'proveedor': proveedor,
    'cantidadMinima': cantidadMinima,
    'tipo_producto': tipoProducto,
    'tipo_venta': tipoVenta,
    'menor_mayor': tipoVenta == 'Ambos' || tipoVenta == 'Mayor',
    'fechaIngresado': fechaIngresado,
    'estado': estado,
    'imagen': imagen,
  };

  factory ProductoPedido.fromMap(Map<String, dynamic> map) {
    return ProductoPedido(
      nombre: map['nombre'] ?? '',
      sku: map['sku'] ?? '',
      costo: (map['costo'] as num?)?.toDouble() ?? 0.0,
      bodegas:
          (map['bodegas'] as List?)
              ?.map(
                (b) => BodegaDistribucion.fromMap(b as Map<String, dynamic>),
              )
              .toList() ??
          [],
      descripcion: map['descripcion'] ?? '',
      codigoBarra: map['codigoBarra'] ?? '',
      categoria: map['categoria'] ?? 'General',
      proveedor: map['proveedor'] ?? '',
      cantidadMinima: map['cantidadMinima'] ?? 1,
      tipoProducto: map['tipoProducto'] ?? 'Normal',
      tipoVenta: (map['menor_mayor'] == true) ? 'Ambos' : (map['tipoVenta'] ?? map['tipo_venta'] ?? 'Menor'),
      fechaIngresado: map['fechaIngresado'] ?? map['fecha_ingreso'] ?? map['fecha'] ?? '',
      estado: map['estado'] ?? 'Activo',
      imagen: map['imagen'] ?? map['image'] ?? map['foto'] ?? map['url_imagen'] ?? map['imageUrl'] ?? '',
    );
  }
}

class LotePedido {
  String codigo;
  int stock;
  String fechaIngreso;
  String fechaVencimiento;
  double costo;
  double precioVenta;
  String unidades;
  double costoLote;
  double impuestoCompra;
  double impuestoVenta;
  int stockMayor;
  String unidadesMayor;
  double costoMayor;
  double precioVentaMayor;

  LotePedido({
    required this.codigo,
    required this.stock,
    required this.fechaIngreso,
    required this.fechaVencimiento,
    required this.costo,
    required this.precioVenta,
    this.unidades = '',
    double? costoLote,
    this.impuestoCompra = 15.0,
    this.impuestoVenta = 15.0,
    this.stockMayor = 0,
    this.unidadesMayor = '',
    this.costoMayor = 0.0,
    this.precioVentaMayor = 0.0,
  }) : costoLote = costoLote ?? (costo * stock);

  Map<String, dynamic> toMap() => {
    'codigo': codigo,
    'cantidad': stock,
    'fecha_ingreso': fechaIngreso,
    'fecha_vencimiento': fechaVencimiento,
    'costo_unitario': costo,
    'precio_venta': precioVenta,
    'unidades': unidades,
    'costo_lote': costoLote,
    'impuesto_compra': impuestoCompra,
    'impuesto_venta': impuestoVenta,
    'cantidad_mayor': stockMayor,
    'unidades_mayor': unidadesMayor,
    'costo_mayor': costoMayor,
    'venta_mayor': precioVentaMayor,
    'ganancia_unidad': precioVenta - costo,
    'ganancia_lote': (precioVenta - costo) * stock,
  };

  factory LotePedido.fromMap(Map<String, dynamic> map) {
    final c = (map['costo'] as num?)?.toDouble() ?? (map['costo_unitario'] as num?)?.toDouble() ?? 0.0;
    final s = map['stock'] ?? map['cantidad'] ?? 0;
    return LotePedido(
      codigo: map['codigo'] ?? map['id'] ?? '',
      stock: s,
      fechaIngreso: map['fechaIngreso'] ?? map['fecha_ingreso'] ?? '',
      fechaVencimiento: map['fechaVencimiento'] ?? map['fecha_vencimiento'] ?? '',
      costo: c,
      precioVenta: (map['precioVenta'] as num?)?.toDouble() ?? (map['precio_venta'] as num?)?.toDouble() ?? 0.0,
      unidades: map['unidades'] ?? '',
      costoLote: (map['costoLote'] as num?)?.toDouble() ?? (c * s),
      impuestoCompra: (map['impuestoCompra'] as num?)?.toDouble() ?? 15.0,
      impuestoVenta: (map['impuestoVenta'] as num?)?.toDouble() ?? 15.0,
      stockMayor: map['stockMayor'] ?? map['stock_mayor'] ?? map['cantidad_mayor'] ?? map['cantidadMayor'] ?? 0,
      unidadesMayor: map['unidadesMayor'] ?? map['unidades_mayor'] ?? '',
      costoMayor: (map['costoMayor'] as num?)?.toDouble() ?? (map['costo_mayor'] as num?)?.toDouble() ?? 0.0,
      precioVentaMayor: (map['precioVentaMayor'] as num?)?.toDouble() ?? (map['venta_mayor'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PedidoInventario {
  String id;
  String nombre;
  String descripcion;
  String proveedor;
  String fecha;
  String pagadoPor;
  String referencia;
  double descuento;
  double impuesto;
  double envio;
  List<ProductoPedido> productos;
  List<LotePedido> lotes;

  PedidoInventario({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.proveedor,
    required this.fecha,
    required this.pagadoPor,
    required this.referencia,
    required this.descuento,
    required this.impuesto,
    required this.envio,
    required this.productos,
    required this.lotes,
  });

  double get subtotalProductos =>
      productos.fold(0.0, (total, p) => total + p.subtotal);
  double get totalGeneral => subtotalProductos - descuento + impuesto + envio;

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'proveedor': proveedor,
    'fecha': fecha,
    'pagadoPor': pagadoPor,
    'referencia': referencia,
    'descuento': descuento,
    'impuesto': impuesto,
    'envio': envio,
    'productos': productos.map((p) => p.toMap()).toList(),
    'lotes': lotes.map((l) => l.toMap()).toList(),
  };

  factory PedidoInventario.fromMap(String id, Map<String, dynamic> map) {
    return PedidoInventario(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      proveedor: map['proveedor'] ?? '',
      fecha: map['fecha'] ?? '',
      pagadoPor: map['pagadoPor'] ?? '',
      referencia: map['referencia'] ?? '',
      descuento: (map['descuento'] as num?)?.toDouble() ?? 0.0,
      impuesto: (map['impuesto'] as num?)?.toDouble() ?? 0.0,
      envio: (map['envio'] as num?)?.toDouble() ?? 0.0,
      productos: (map['productos'] as List?)
              ?.map((p) => ProductoPedido.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [
            // Fallback si no hay productos: crear uno usando los datos de la raíz
            ProductoPedido(
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
              tipoVenta: (map['menor_mayor'] == true) ? 'Ambos' : (map['tipoVenta'] ?? map['tipo_venta'] ?? 'Menor'),
              fechaIngresado: map['fechaIngresado'] ?? map['fecha_ingreso'] ?? map['fecha'] ?? '',
              estado: map['estado'] ?? 'Activo',
              imagen: map['imagen'] ?? map['image'] ?? map['foto'] ?? map['url_imagen'] ?? map['imageUrl'] ?? '',
            )
          ],
      lotes:
          (map['lotes'] as List? ?? map['lista_lotes'] as List? ?? map['batch'] as List? ?? map['lote'] as List?)
              ?.map((l) => LotePedido.fromMap(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
