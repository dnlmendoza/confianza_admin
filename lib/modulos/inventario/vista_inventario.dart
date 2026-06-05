import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:confianza_admin/modulos/catalogos/vm_catalogos.dart';
import 'package:confianza_admin/modulos/inventario/datos_inventario.dart';

// --- MODELOS DE DATOS ---

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
  String fechaIngresado;

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
    this.fechaIngresado = '',
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
    'tipoProducto': tipoProducto,
    'fechaIngresado': fechaIngresado,
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
      fechaIngresado: map['fechaIngresado'] ?? '',
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

  LotePedido({
    required this.codigo,
    required this.stock,
    required this.fechaIngreso,
    required this.fechaVencimiento,
    required this.costo,
    required this.precioVenta,
    this.unidades = 'UNIDAD',
    double? costoLote,
    this.impuestoCompra = 15.0,
    this.impuestoVenta = 15.0,
  }) : costoLote = costoLote ?? (costo * stock);

  Map<String, dynamic> toMap() => {
    'codigo': codigo,
    'stock': stock,
    'fechaIngreso': fechaIngreso,
    'fechaVencimiento': fechaVencimiento,
    'costo': costo,
    'precioVenta': precioVenta,
    'unidades': unidades,
    'costoLote': costoLote,
    'impuestoCompra': impuestoCompra,
    'impuestoVenta': impuestoVenta,
  };

  factory LotePedido.fromMap(Map<String, dynamic> map) {
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
      productos:
          (map['productos'] as List?)
              ?.map((p) => ProductoPedido.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      lotes:
          (map['lotes'] as List?)
              ?.map((l) => LotePedido.fromMap(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// --- CLASE VISTA PRINCIPAL ---

class VistaInventario extends StatefulWidget {
  const VistaInventario({super.key});

  @override
  State<VistaInventario> createState() => _VistaInventarioState();
}

class _VistaInventarioState extends State<VistaInventario> {
  // Dynamic lists for catalogs (vinculados al ViewModel)
  late final VMCatalogos _vmCatalogos;

  List<String> get _units => _vmCatalogos.unidades;

  // State for Inventory Orders Tab (Local state only, no Firestore stream)
  List<PedidoInventario> _pedidos = [];
  PedidoInventario? _selectedPedido;
  int _activeDetailTab =
      0; // 0: Datos Artículos, 1: Contabilidad, 2: Datos Lotes
  int _selectedLoteIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vmCatalogos = VMCatalogos()
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    // Populate initial local state immediately
    _pedidos = getInitialMockData();
    if (_pedidos.isNotEmpty) {
      _selectedPedido = _pedidos.first;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _vmCatalogos.dispose();
    super.dispose();
  }

  // --- FILTRADO ---

  List<PedidoInventario> get _filteredPedidos {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _pedidos;
    return _pedidos.where((p) {
      return p.nombre.toLowerCase().contains(query) ||
          p.descripcion.toLowerCase().contains(query) ||
          p.proveedor.toLowerCase().contains(query);
    }).toList();
  }

  // --- DIÁLOGOS Y ACCIONES INTERACTIVAS DE PEDIDOS ---

  void _showAddProductDialog(PedidoInventario pedido) {
    final nameController = TextEditingController();
    final skuController = TextEditingController();
    final costController = TextEditingController();
    final warehouseNameController = TextEditingController(text: "Brand Depot");
    final qtyController = TextEditingController(text: "1");
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Añadir Producto al Pedido",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Nombre del Producto",
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  TextFormField(
                    controller: skuController,
                    decoration: const InputDecoration(labelText: "SKU"),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  TextFormField(
                    controller: costController,
                    decoration: const InputDecoration(
                      labelText: "Costo Unitario (L.)",
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => (v == null || double.tryParse(v) == null)
                        ? "Costo inválido"
                        : null,
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    "Distribución de Bodega Inicial",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  TextFormField(
                    controller: warehouseNameController,
                    decoration: const InputDecoration(
                      labelText: "Nombre de la Bodega",
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  TextFormField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: "Cantidad"),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || int.tryParse(v) == null)
                        ? "Cantidad inválida"
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newProd = ProductoPedido(
                    nombre: nameController.text.trim(),
                    sku: skuController.text.trim(),
                    costo: double.parse(costController.text.trim()),
                    bodegas: [
                      BodegaDistribucion(
                        nombre: warehouseNameController.text.trim(),
                        cantidad: int.parse(qtyController.text.trim()),
                      ),
                    ],
                  );

                  setState(() {
                    pedido.productos.add(newProd);
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Añadir"),
            ),
          ],
        );
      },
    );
  }

  void _showEditStockDialog(
    ProductoPedido prod,
    int prodIndex,
    PedidoInventario pedido,
  ) {
    final formKey = GlobalKey<FormState>();
    final newWarehouseController = TextEditingController();
    final newQtyController = TextEditingController(text: "0");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                "Distribución de Stock - ${prod.nombre}",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(prod.bodegas.length, (idx) {
                          final b = prod.bodegas[idx];
                          final qtyCtrl = TextEditingController(
                            text: b.cantidad.toString(),
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    b.nombre,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: qtyCtrl,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.all(8),
                                    ),
                                    onChanged: (val) {
                                      final parsed = int.tryParse(val) ?? 0;
                                      b.cantidad = parsed;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setDialogState(() {
                                      prod.bodegas.removeAt(idx);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          "Añadir Nueva Bodega",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: newWarehouseController,
                                decoration: const InputDecoration(
                                  labelText: "Bodega",
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: newQtyController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Cant",
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                final name = newWarehouseController.text.trim();
                                final qty =
                                    int.tryParse(
                                      newQtyController.text.trim(),
                                    ) ??
                                    0;
                                if (name.isNotEmpty && qty > 0) {
                                  setDialogState(() {
                                    prod.bodegas.add(
                                      BodegaDistribucion(
                                        nombre: name,
                                        cantidad: qty,
                                      ),
                                    );
                                    newWarehouseController.clear();
                                    newQtyController.text = "0";
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditSummaryDialog(
    PedidoInventario pedido,
    String type,
    double currentValue,
  ) {
    final controller = TextEditingController(
      text: currentValue.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();
    final title = type == 'descuento'
        ? "Editar Descuento Recibido"
        : (type == 'impuesto'
              ? "Editar Impuesto Pagado"
              : "Editar Costo de Envío");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Valor (L.)"),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              validator: (v) => (v == null || double.tryParse(v) == null)
                  ? "Valor inválido"
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final val = double.parse(controller.text.trim());
                  setState(() {
                    if (type == 'descuento') {
                      pedido.descuento = val;
                    } else if (type == 'impuesto') {
                      pedido.impuesto = val;
                    } else if (type == 'envio') {
                      pedido.envio = val;
                    }
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // --- CONSTRUCCIÓN DE WIDGETS ---

  Widget _buildMetadataItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            size: 18,
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildProductTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "PRODUCTO",
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "COSTO",
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "STOCK / BODEGA",
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "SUBTOTAL",
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 40), // Spacing for delete button
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildProductTableRow(
    ProductoPedido prod,
    int index,
    PedidoInventario pedido,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // PRODUCT
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prod.nombre,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prod.sku,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // COST
          Expanded(
            flex: 2,
            child: Text(
              "L. ${prod.costo.toStringAsFixed(2)}",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.onSurface,
              ),
            ),
          ),
          // STOCK/WAREHOUSE
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: prod.bodegas.isEmpty
                        ? [
                            Text(
                              "Sin bodega",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ]
                        : prod.bodegas.map((b) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                "${b.cantidad} ${b.nombre}",
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  onPressed: () => _showEditStockDialog(prod, index, pedido),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),
          // SUB TOTAL
          Expanded(
            flex: 2,
            child: Text(
              "L. ${prod.subtotal.toStringAsFixed(2)}",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ),
          // DELETE BUTTON
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 16),
            onPressed: () {
              setState(() {
                pedido.productos.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String valueText, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    valueText,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 12,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalRow(double grandTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "TOTAL GENERAL",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "L. ${grandTotal.toStringAsFixed(2)}",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLotDialog(PedidoInventario pedido) {
    final today = DateTime.now();
    final dateStr =
        "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}";
    final defaultCode =
        "LOT-${today.year}-${(today.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}";

    final codeController = TextEditingController(text: defaultCode);
    final stockController = TextEditingController(text: "100");
    final entryDateController = TextEditingController(text: dateStr);
    final expiryDateController = TextEditingController(text: "28-02-2027");
    final costController = TextEditingController(text: "150.00");
    final priceController = TextEditingController(text: "220.00");
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Registrar Nuevo Lote",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: "Código de Lote",
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: "Stock Inicial",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || int.tryParse(v) == null)
                        ? "Cantidad inválida"
                        : null,
                  ),
                  TextFormField(
                    controller: entryDateController,
                    decoration: const InputDecoration(
                      labelText: "Fecha de Ingreso",
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  TextFormField(
                    controller: expiryDateController,
                    decoration: const InputDecoration(
                      labelText: "Fecha de Vencimiento",
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  TextFormField(
                    controller: costController,
                    decoration: const InputDecoration(
                      labelText: "Costo Unitario (L.)",
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => (v == null || double.tryParse(v) == null)
                        ? "Costo inválido"
                        : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: "Precio de Venta (L.)",
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => (v == null || double.tryParse(v) == null)
                        ? "Precio inválido"
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newLot = LotePedido(
                    codigo: codeController.text.trim(),
                    stock: int.parse(stockController.text.trim()),
                    fechaIngreso: entryDateController.text.trim(),
                    fechaVencimiento: expiryDateController.text.trim(),
                    costo: double.parse(costController.text.trim()),
                    precioVenta: double.parse(priceController.text.trim()),
                  );

                  setState(() {
                    pedido.lotes.add(newLot);
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLotesSection(PedidoInventario pedido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lista de Lotes",
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddLotDialog(pedido),
              icon: const Icon(Icons.add, size: 14),
              label: const Text("Nuevo Lote"),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: pedido.lotes.isEmpty
              ? Center(
                  child: Text(
                    "No hay lotes registrados.",
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: pedido.lotes.length,
                  itemBuilder: (context, index) {
                    final lote = pedido.lotes[index];
                    final isLoteSelected = _selectedLoteIndex == index;
                    return Card(
                      color: isLoteSelected
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : AppColors.surfaceContainerLow,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isLoteSelected
                              ? AppColors.primary
                              : AppColors.outlineVariant.withValues(alpha: 0.5),
                          width: isLoteSelected ? 1.5 : 1,
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedLoteIndex = index;
                            _activeDetailTab = 1; // Ir a Contabilidad
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.qr_code,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        lote.codigo,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "Activo",
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildLoteDetailRow(
                                "Stock disponible:",
                                "${lote.stock} Unid",
                              ),
                              _buildLoteDetailRow(
                                "Ingreso:",
                                lote.fechaIngreso,
                              ),
                              _buildLoteDetailRow(
                                "Vencimiento:",
                                lote.fechaVencimiento,
                              ),
                              const Divider(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Costo: L. ${lote.costo.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    "Venta: L. ${lote.precioVenta.toStringAsFixed(2)}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLoteDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTabButton(int index, String label, IconData icon) {
    final isSelected = _activeDetailTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeDetailTab = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              size: 16,
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              style: GoogleFonts.outfit(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.0,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailFormTextField({
    required String label,
    required String initialValue,
    required ValueKey key,
    required Function(String) onChanged,
    IconData? suffixIcon,
    IconData? prefixIcon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextFormField(
            key: key,
            initialValue: initialValue,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onTap: onTap,
            onChanged: onChanged,
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 16,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      size: 16,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCantidadField(LotePedido lote, String keyPrefix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cantidad",
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            InkWell(
              onTap: () {
                if (lote.stock > 1) {
                  setState(() {
                    lote.stock--;
                    lote.costoLote = lote.costo * lote.stock;
                  });
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.remove,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextFormField(
                  key: ValueKey('$keyPrefix-stock-${lote.stock}'),
                  initialValue: lote.stock.toString(),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow.withValues(
                      alpha: 0.3,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    final newStock = int.tryParse(val) ?? 0;
                    setState(() {
                      lote.stock = newStock;
                      lote.costoLote = lote.costo * lote.stock;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                setState(() {
                  lote.stock++;
                  lote.costoLote = lote.costo * lote.stock;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnidadesDropdown(LotePedido lote, String keyPrefix) {
    final list = _units.isEmpty
        ? ['UNIDAD', '2X1', 'CAJA']
        : List<String>.from(_units);
    if (!list.contains(lote.unidades)) {
      list.insert(0, lote.unidades);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Unidades",
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 6),
        PopupMenuButton<String>(
          onSelected: (val) {
            setState(() {
              lote.unidades = val;
            });
          },
          itemBuilder: (BuildContext context) {
            return list.map((String val) {
              return PopupMenuItem<String>(
                value: val,
                child: Text(val, style: GoogleFonts.outfit(fontSize: 13)),
              );
            }).toList();
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lote.unidades,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatosArticulosTab(PedidoInventario pedido) {
    if (pedido.productos.isEmpty) {
      return Center(
        child: Text(
          "No hay productos en este pedido.",
          style: GoogleFonts.outfit(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    final prod = pedido.productos.first;
    final keyPrefix = "${pedido.id}-${prod.sku}";

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 36,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildDetailFormTextField(
                      label: "Nombre del Producto",
                      initialValue: prod.nombre,
                      key: ValueKey('$keyPrefix-nombre-${prod.nombre}'),
                      onChanged: (val) {
                        setState(() {
                          prod.nombre = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDetailFormTextField(
                      label: "Descripción / Subtítulo",
                      initialValue: prod.descripcion,
                      key: ValueKey('$keyPrefix-desc-${prod.descripcion}'),
                      onChanged: (val) {
                        setState(() {
                          prod.descripcion = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = (width - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Código de Barra",
                      initialValue: prod.codigoBarra,
                      key: ValueKey('$keyPrefix-barcode-${prod.codigoBarra}'),
                      onChanged: (val) {
                        setState(() {
                          prod.codigoBarra = val;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Categoría",
                      initialValue: prod.categoria,
                      key: ValueKey('$keyPrefix-cat-${prod.categoria}'),
                      onChanged: (val) {
                        setState(() {
                          prod.categoria = val;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Proveedor",
                      initialValue: prod.proveedor,
                      key: ValueKey('$keyPrefix-prov-${prod.proveedor}'),
                      onChanged: (val) {
                        setState(() {
                          prod.proveedor = val;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Cantidad Mínima",
                      initialValue: prod.cantidadMinima.toString(),
                      key: ValueKey('$keyPrefix-minQty-${prod.cantidadMinima}'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() {
                          prod.cantidadMinima = int.tryParse(val) ?? 1;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Tipo de Producto",
                      initialValue: prod.tipoProducto,
                      key: ValueKey('$keyPrefix-type-${prod.tipoProducto}'),
                      onChanged: (val) {
                        setState(() {
                          prod.tipoProducto = val;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Fecha Ingresado",
                      initialValue: prod.fechaIngresado,
                      key: ValueKey('$keyPrefix-date-${prod.fechaIngresado}'),
                      suffixIcon: Icons.calendar_month,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          final formatted =
                              "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}";
                          setState(() {
                            prod.fechaIngresado = formatted;
                          });
                        }
                      },
                      onChanged: (val) {
                        setState(() {
                          prod.fechaIngresado = val;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContabilidadTab(PedidoInventario pedido) {
    if (pedido.lotes.isEmpty) {
      return Center(
        child: Text(
          "No hay lotes en este pedido.",
          style: GoogleFonts.outfit(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    final int index = _selectedLoteIndex.clamp(0, pedido.lotes.length - 1);
    final lote = pedido.lotes[index];
    final keyPrefix = "${pedido.id}-lote-${lote.codigo}";

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.layers_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lote.codigo,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "FIFO Activo",
                            style: GoogleFonts.outfit(
                              color: Colors.blue[800],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Ingreso: ${lote.fechaIngreso}",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Disponible",
                            style: GoogleFonts.outfit(
                              color: Colors.green[800],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${lote.stock} Unid",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_up,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = (width - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _buildCantidadField(lote, keyPrefix),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildUnidadesDropdown(lote, keyPrefix),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Fecha Ingreso",
                      initialValue: lote.fechaIngreso,
                      key: ValueKey(
                        '$keyPrefix-fechaIngreso-${lote.fechaIngreso}',
                      ),
                      suffixIcon: Icons.calendar_month,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          final formatted =
                              "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}";
                          setState(() {
                            lote.fechaIngreso = formatted;
                          });
                        }
                      },
                      onChanged: (val) {
                        setState(() {
                          lote.fechaIngreso = val;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Costo Lote",
                      initialValue: lote.costoLote.toStringAsFixed(2),
                      key: ValueKey(
                        '$keyPrefix-costoLote-${lote.costoLote.toStringAsFixed(2)}',
                      ),
                      prefixIcon: Icons.calculate_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        setState(() {
                          lote.costoLote = parsed;
                          lote.costo = lote.stock > 0
                              ? (parsed / lote.stock)
                              : 0.0;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Costo Unitario",
                      initialValue: lote.costo.toStringAsFixed(2),
                      key: ValueKey(
                        '$keyPrefix-costoUnitario-${lote.costo.toStringAsFixed(2)}',
                      ),
                      prefixIcon: Icons.payments_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        setState(() {
                          lote.costo = parsed;
                          lote.costoLote = parsed * lote.stock;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Impuesto Compra %",
                      initialValue: lote.impuestoCompra.toStringAsFixed(0),
                      key: ValueKey(
                        '$keyPrefix-impuestoCompra-${lote.impuestoCompra}',
                      ),
                      prefixIcon: Icons.percent,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        setState(() {
                          lote.impuestoCompra = parsed;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Precio Venta",
                      initialValue: lote.precioVenta.toStringAsFixed(2),
                      key: ValueKey(
                        '$keyPrefix-precioVenta-${lote.precioVenta.toStringAsFixed(2)}',
                      ),
                      prefixIcon: Icons.local_offer_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        setState(() {
                          lote.precioVenta = parsed;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Impuesto Venta %",
                      initialValue: lote.impuestoVenta.toStringAsFixed(0),
                      key: ValueKey(
                        '$keyPrefix-impuestoVenta-${lote.impuestoVenta}',
                      ),
                      prefixIcon: Icons.percent,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        setState(() {
                          lote.impuestoVenta = parsed;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Ganancia Unidad",
                      initialValue: (lote.precioVenta - lote.costo)
                          .toStringAsFixed(2),
                      key: ValueKey(
                        '$keyPrefix-gananciaUnidad-${(lote.precioVenta - lote.costo).toStringAsFixed(2)}',
                      ),
                      prefixIcon: Icons.calculate_outlined,
                      readOnly: true,
                      onChanged: (val) {},
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Ganancia Lote",
                      initialValue:
                          ((lote.precioVenta - lote.costo) * lote.stock)
                              .toStringAsFixed(2),
                      key: ValueKey(
                        '$keyPrefix-gananciaLote-${((lote.precioVenta - lote.costo) * lote.stock).toStringAsFixed(2)}',
                      ),
                      prefixIcon: Icons.calculate_outlined,
                      readOnly: true,
                      onChanged: (val) {},
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildDetailFormTextField(
                      label: "Fecha Vencimiento",
                      initialValue: lote.fechaVencimiento,
                      key: ValueKey(
                        '$keyPrefix-fechaVencimiento-${lote.fechaVencimiento}',
                      ),
                      suffixIcon: Icons.calendar_month,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          final formatted =
                              "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}";
                          setState(() {
                            lote.fechaVencimiento = formatted;
                          });
                        }
                      },
                      onChanged: (val) {
                        setState(() {
                          lote.fechaVencimiento = val;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductosYTotalesSection(PedidoInventario pedido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailTabButton(
                0,
                "Datos Generales",
                Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailTabButton(
                1,
                "Datos Lote",
                Icons.calculate_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailTabButton(
                2,
                "Contabilidad",
                Icons.layers_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _activeDetailTab == 0
              ? _buildDatosArticulosTab(pedido)
              : _activeDetailTab == 1
              ? _buildContabilidadTab(pedido)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showAddProductDialog(pedido),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Añadir nuevo producto"),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildSummaryRow(
                              "DESCUENTO RECIBIDO (I-I)",
                              "L. ${pedido.descuento.toStringAsFixed(2)}",
                              () => _showEditSummaryDialog(
                                pedido,
                                'descuento',
                                pedido.descuento,
                              ),
                            ),
                            _buildSummaryRow(
                              "IMPUESTO DE VENTA PAGADO",
                              "L. ${pedido.impuesto.toStringAsFixed(2)}",
                              () => _showEditSummaryDialog(
                                pedido,
                                'impuesto',
                                pedido.impuesto,
                              ),
                            ),
                            _buildSummaryRow(
                              "ENVÍO PAGADO",
                              "L. ${pedido.envio.toStringAsFixed(2)}",
                              () => _showEditSummaryDialog(
                                pedido,
                                'envio',
                                pedido.envio,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(width: 250, child: Divider()),
                            _buildGrandTotalRow(pedido.totalGeneral),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPedidoDetailsPanel(
    BuildContext context,
    PedidoInventario pedido,
  ) {
    return Card(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Datos Articulo",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            // Fila de Metadata (Vendor, Date, Paid By, Ref)
            // Fila de Metadata (Vendor, Date, Paid By, Ref) sin tarjetas
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Espacio inferior dividido bajo metadatos
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1/3: Lista de Lotes
                  Expanded(flex: 1, child: _buildLotesSection(pedido)),
                  Container(
                    width: 1,
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  // 2/3: Productos y Totales
                  Expanded(
                    flex: 2,
                    child: _buildProductosYTotalesSection(pedido),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryOrdersView(BuildContext context) {
    final filtered = _filteredPedidos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Layout Split Screen
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 0,
              right: 24,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Panel izquierdo (lista de pedidos)
                Container(
                  width: 450,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Buscador y filtro pegado a la izquierda
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: "Buscar...",
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 18,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceContainerLow,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: AppColors.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.filter_list, size: 18),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Lista de pedidos plana full-width
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.outlineVariant,
                            indent: 0,
                            endIndent: 0,
                          ),
                          itemBuilder: (context, index) {
                            final pedido = filtered[index];
                            final isSelected = _selectedPedido?.id == pedido.id;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPedido = pedido;
                                  _selectedLoteIndex = 0;
                                  _activeDetailTab = 0;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.zero,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pedido.nombre,
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            pedido.descripcion,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isSelected
                                                  ? Colors.white70
                                                  : AppColors.onSurfaceVariant,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Panel derecho (detalles del pedido)
                Expanded(
                  child: _selectedPedido == null
                      ? const Center(
                          child: Text(
                            "Seleccione un pedido para ver los detalles.",
                          ),
                        )
                      : _buildPedidoDetailsPanel(context, _selectedPedido!),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      activeRoute: '/inventario',
      title: 'Inventario',
      child: _buildInventoryOrdersView(context),
    );
  }
}
