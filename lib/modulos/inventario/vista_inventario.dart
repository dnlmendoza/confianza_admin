import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:confianza_admin/modulos/inventario/vm_catalogos.dart';

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

  ProductoPedido({
    required this.nombre,
    required this.sku,
    required this.costo,
    required this.bodegas,
  });

  int get totalStock => bodegas.fold(0, (total, b) => total + b.cantidad);
  double get subtotal => costo * totalStock;

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'sku': sku,
    'costo': costo,
    'bodegas': bodegas.map((b) => b.toMap()).toList(),
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

  LotePedido({
    required this.codigo,
    required this.stock,
    required this.fechaIngreso,
    required this.fechaVencimiento,
    required this.costo,
    required this.precioVenta,
  });

  Map<String, dynamic> toMap() => {
    'codigo': codigo,
    'stock': stock,
    'fechaIngreso': fechaIngreso,
    'fechaVencimiento': fechaVencimiento,
    'costo': costo,
    'precioVenta': precioVenta,
  };

  factory LotePedido.fromMap(Map<String, dynamic> map) {
    return LotePedido(
      codigo: map['codigo'] ?? '',
      stock: map['stock'] ?? 0,
      fechaIngreso: map['fechaIngreso'] ?? '',
      fechaVencimiento: map['fechaVencimiento'] ?? '',
      costo: (map['costo'] as num?)?.toDouble() ?? 0.0,
      precioVenta: (map['precioVenta'] as num?)?.toDouble() ?? 0.0,
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
  // Tab State
  int _activeTab = 0; // 0: Gestión de Inventario, 1: Catálogos
  int _activeCatalogTab =
      0; // 0: Categorías, 1: Proveedores, 2: Unidades de Venta
  final TextEditingController _catalogSearchController =
      TextEditingController();

  // Dynamic lists for catalogs (vinculados al ViewModel)
  late final VMCatalogos _vmCatalogos;

  List<String> get _categories => _vmCatalogos.categorias;
  List<String> get _providers => _vmCatalogos.proveedores;
  List<String> get _units => _vmCatalogos.unidades;

  // State for Inventory Orders Tab (Local state only, no Firestore stream)
  List<PedidoInventario> _pedidos = [];
  PedidoInventario? _selectedPedido;
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
    _pedidos = _getInitialMockData();
    if (_pedidos.isNotEmpty) {
      _selectedPedido = _pedidos.first;
    }
  }

  @override
  void dispose() {
    _catalogSearchController.dispose();
    _searchController.dispose();
    _vmCatalogos.dispose();
    super.dispose();
  }

  // --- MÉTODOS DE BASE DE DATOS E INICIALIZACIÓN ---

  List<PedidoInventario> _getInitialMockData() {
    return [
      PedidoInventario(
        id: '1',
        nombre: 'Catpillar Tractor-Scrapers',
        descripcion:
            'Carga rápida, alta velocidad de desplazamiento y capacidad para realizar trabajo continuo.',
        proveedor: 'Catpillar',
        fecha: '11/03/2017',
        pagadoPor: 'Eric Hoffman',
        referencia: 'JKU2439800001838',
        descuento: 350.00,
        impuesto: 733.50,
        envio: 123.50,
        productos: [
          ProductoPedido(
            nombre: 'Cargadoras de Ruedas Compactas',
            sku: 'SKU-131200238',
            costo: 188.00,
            bodegas: [
              BodegaDistribucion(nombre: 'Brand Depot', cantidad: 39),
              BodegaDistribucion(nombre: 'Warehously', cantidad: 10),
              BodegaDistribucion(nombre: 'Pod Capital', cantidad: 10),
            ],
          ),
          ProductoPedido(
            nombre: 'Desbrozadoras de Maleza',
            sku: 'SKU-131200238',
            costo: 117.99,
            bodegas: [BodegaDistribucion(nombre: 'Brand Depot', cantidad: 88)],
          ),
          ProductoPedido(
            nombre: 'Paralelo de Acoplamiento de Cargador',
            sku: 'SKU-131200238',
            costo: 789.00,
            bodegas: [BodegaDistribucion(nombre: 'Pod Capital', cantidad: 39)],
          ),
          ProductoPedido(
            nombre: 'Desbrozadoras de Maleza',
            sku: 'SKU-131200238',
            costo: 117.99,
            bodegas: [BodegaDistribucion(nombre: 'Brand Depot', cantidad: 88)],
          ),
          ProductoPedido(
            nombre: 'Cucharas de Grata',
            sku: 'SKU-131200238',
            costo: 789.00,
            bodegas: [BodegaDistribucion(nombre: 'Pod Capital', cantidad: 39)],
          ),
        ],
        lotes: [
          LotePedido(
            codigo: 'LOT-2026-001',
            stock: 59,
            fechaIngreso: '11/03/2017',
            fechaVencimiento: '28-02-2027',
            costo: 188.00,
            precioVenta: 250.00,
          ),
          LotePedido(
            codigo: 'LOT-2026-002',
            stock: 88,
            fechaIngreso: '12/03/2017',
            fechaVencimiento: '12-03-2028',
            costo: 117.99,
            precioVenta: 180.00,
          ),
          LotePedido(
            codigo: 'LOT-2026-003',
            stock: 39,
            fechaIngreso: '13/03/2017',
            fechaVencimiento: '13-03-2028',
            costo: 789.00,
            precioVenta: 1100.00,
          ),
        ],
      ),
      PedidoInventario(
        id: '2',
        nombre: 'Cucharas de Grata',
        descripcion: 'Para sujetar y transportar material empacado.',
        proveedor: 'General',
        fecha: '15/04/2026',
        pagadoPor: 'Admin',
        referencia: 'REF-GRAB-001',
        descuento: 100.00,
        impuesto: 150.00,
        envio: 50.00,
        productos: [
          ProductoPedido(
            nombre: 'Cucharas de Grata',
            sku: 'SKU-7772299',
            costo: 250.00,
            bodegas: [BodegaDistribucion(nombre: 'Brand Depot', cantidad: 10)],
          ),
        ],
        lotes: [
          LotePedido(
            codigo: 'LOT-2026-004',
            stock: 10,
            fechaIngreso: '15/04/2026',
            fechaVencimiento: '15-04-2029',
            costo: 250.00,
            precioVenta: 350.00,
          ),
        ],
      ),
      PedidoInventario(
        id: '3',
        nombre: 'Paralelo de Acoplamiento de Cargador',
        descripcion: 'Cargador de varillaje en Z optimizado por Cat.',
        proveedor: 'Catpillar',
        fecha: '20/05/2026',
        pagadoPor: 'John Doe',
        referencia: 'REF-PAR-002',
        descuento: 0.00,
        impuesto: 300.00,
        envio: 80.00,
        productos: [
          ProductoPedido(
            nombre: 'Paralelo de Acoplamiento de Cargador',
            sku: 'SKU-8822001',
            costo: 800.00,
            bodegas: [BodegaDistribucion(nombre: 'Warehously', cantidad: 1)],
          ),
        ],
        lotes: [
          LotePedido(
            codigo: 'LOT-2026-005',
            stock: 1,
            fechaIngreso: '20/05/2026',
            fechaVencimiento: '20-05-2029',
            costo: 800.00,
            precioVenta: 1200.00,
          ),
        ],
      ),
    ];
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

  // --- MÉTODOS AUXILIARES CATÁLOGOS ---

  void _renameCategory(String oldCat, String newCat) {
    _vmCatalogos.renameCategoria(oldCat, newCat);
    setState(() {});
  }

  void _deleteCategory(String cat) {
    _vmCatalogos.deleteCategoria(cat);
    setState(() {});
  }

  void _renameProvider(String oldProv, String newProv) {
    _vmCatalogos.renameProveedor(oldProv, newProv);
    setState(() {});
  }

  void _deleteProvider(String prov) {
    _vmCatalogos.deleteProveedor(prov);
    setState(() {});
  }

  void _renameUnit(String oldUnit, String newUnit) {
    _vmCatalogos.renameUnidad(oldUnit, newUnit);
    setState(() {});
  }

  void _deleteUnit(String unit) {
    _vmCatalogos.deleteUnidad(unit);
    setState(() {});
  }

  Future<int> _fetchCatalogUsageCount(String item, int tabIndex) async {
    try {
      final firestore = FirebaseFirestore.instance;
      if (tabIndex == 0) {
        final catSnap = await firestore
            .collection('Categorias')
            .where('Nombre', isEqualTo: item)
            .get();
        int count = 0;
        for (var doc in catSnap.docs) {
          final snapId = await firestore
              .collection('Inventario')
              .where('categoria', isEqualTo: doc.id)
              .count()
              .get();
          count += (snapId.count ?? 0);
        }
        final snapStr = await firestore
            .collection('Inventario')
            .where('categoria', isEqualTo: item)
            .count()
            .get();
        return count + (snapStr.count ?? 0);
      } else if (tabIndex == 1) {
        final provSnap = await firestore
            .collection('Proveedores')
            .where('Nombre', isEqualTo: item)
            .get();
        int count = 0;
        for (var doc in provSnap.docs) {
          final snapId = await firestore
              .collection('Inventario')
              .where('proveedor', isEqualTo: doc.id)
              .count()
              .get();
          count += (snapId.count ?? 0);
        }
        final snapStr = await firestore
            .collection('Inventario')
            .where('proveedor', isEqualTo: item)
            .count()
            .get();
        return count + (snapStr.count ?? 0);
      } else {
        final unitSnap = await firestore
            .collection('Unidades')
            .where('Tipo', isEqualTo: item)
            .get();
        final List<String> possibleValues = unitSnap.docs
            .map((d) => d.id)
            .toList();
        possibleValues.add(item);

        int count = 0;
        try {
          final snapId = await firestore
              .collectionGroup('lote')
              .where('unidades', whereIn: possibleValues)
              .count()
              .get();
          count = snapId.count ?? 0;
        } catch (e) {
          final invSnap = await firestore.collection('Inventario').get();

          final lotesFutures = invSnap.docs.map(
            (doc) => doc.reference.collection('lote').get(),
          );
          final allLotesSnaps = await Future.wait(lotesFutures);

          for (var lotesSnap in allLotesSnaps) {
            for (var loteDoc in lotesSnap.docs) {
              final data = loteDoc.data();
              if (data.containsKey('unidades')) {
                final val = data['unidades']?.toString().trim();
                if (val != null && possibleValues.contains(val)) {
                  count++;
                } else if (val != null &&
                    val.toLowerCase() == item.toLowerCase()) {
                  count++;
                }
              }
            }
          }
        }
        return count;
      }
    } catch (e) {
      debugPrint("Error fetching usage: $e");
      return 0;
    }
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

  // --- DIÁLOGOS CATÁLOGOS ---

  void _showAddCatalogDialog(BuildContext context, int tabIndex) {
    final title = tabIndex == 0
        ? "Nueva Categoría"
        : (tabIndex == 1 ? "Nuevo Proveedor" : "Nueva Unidad");
    final label = tabIndex == 0
        ? "Nombre de la Categoría"
        : (tabIndex == 1 ? "Nombre del Proveedor" : "Tipo de Unidad");
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final val = controller.text.trim();
                if (val.isNotEmpty) {
                  if (tabIndex == 0 && !_categories.contains(val)) {
                    _vmCatalogos.addCategoria(val);
                  } else if (tabIndex == 1 && !_providers.contains(val)) {
                    _vmCatalogos.addProveedor(val);
                  } else if (tabIndex == 2 && !_units.contains(val)) {
                    _vmCatalogos.addUnidad(val);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCatalog(
    BuildContext context,
    String item,
    int tabIndex,
  ) async {
    final usage = await _fetchCatalogUsageCount(item, tabIndex);
    if (!context.mounted) return;

    final typeStr = tabIndex == 0
        ? "categoría"
        : (tabIndex == 1 ? "proveedor" : "unidad");
    final fallbackStr = tabIndex == 0
        ? "General"
        : (tabIndex == 1 ? "Bodega" : "Unid");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                "Eliminar $typeStr",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("¿Estás seguro que deseas eliminar '$item'?"),
              if (usage > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Esta $typeStr está siendo usada por $usage producto(s) o lote(s). Si la eliminas, se reasignarán a '$fallbackStr'.",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (tabIndex == 0) {
                  _deleteCategory(item);
                } else if (tabIndex == 1) {
                  _deleteProvider(item);
                } else {
                  _deleteUnit(item);
                }
                Navigator.pop(context);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _showRenameCatalogDialog(
    BuildContext context,
    String item,
    int tabIndex,
  ) {
    final title = tabIndex == 0
        ? "Renombrar Categoría"
        : (tabIndex == 1 ? "Renombrar Proveedor" : "Renombrar Unidad");
    final controller = TextEditingController(text: item);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Nuevo Nombre",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final val = controller.text.trim();
                if (val.isNotEmpty && val != item) {
                  if (tabIndex == 0) {
                    _renameCategory(item, val);
                  } else if (tabIndex == 1) {
                    _renameProvider(item, val);
                  } else {
                    _renameUnit(item, val);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text("Renombrar"),
            ),
          ],
        );
      },
    );
  }

  // --- CONSTRUCCIÓN DE WIDGETS ---

  Widget _buildCustomTab(int index, String label) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13.5,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildCatalogTab(int index, String label, IconData icon) {
    final isSelected = _activeCatalogTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCatalogTab = index;
          _catalogSearchController.clear();
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
              size: 20,
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
                fontSize: 14.5,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

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
    final dateStr = "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}";
    final defaultCode = "LOT-${today.year}-${(today.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}";

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
                    decoration: const InputDecoration(labelText: "Código de Lote"),
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: "Stock Inicial"),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || int.tryParse(v) == null) ? "Cantidad inválida" : null,
                  ),
                  TextFormField(
                    controller: entryDateController,
                    decoration: const InputDecoration(labelText: "Fecha de Ingreso"),
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  TextFormField(
                    controller: expiryDateController,
                    decoration: const InputDecoration(labelText: "Fecha de Vencimiento"),
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  TextFormField(
                    controller: costController,
                    decoration: const InputDecoration(labelText: "Costo Unitario (L.)"),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (v == null || double.tryParse(v) == null) ? "Costo inválido" : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Precio de Venta (L.)"),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (v == null || double.tryParse(v) == null) ? "Precio inválido" : null,
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
                textStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
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
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: pedido.lotes.length,
                  itemBuilder: (context, index) {
                    final lote = pedido.lotes[index];
                    return Card(
                      color: AppColors.surfaceContainerLow,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.qr_code, size: 16, color: AppColors.primary),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "Activo",
                                    style: TextStyle(color: Colors.green[700], fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildLoteDetailRow("Stock disponible:", "${lote.stock} Unid"),
                            _buildLoteDetailRow("Ingreso:", lote.fechaIngreso),
                            _buildLoteDetailRow("Vencimiento:", lote.fechaVencimiento),
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Costo: L. ${lote.costo.toStringAsFixed(2)}",
                                  style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
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
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProductosYTotalesSection(PedidoInventario pedido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProductTableHeader(),
        Expanded(
          child: pedido.productos.isEmpty
              ? Center(
                  child: Text(
                    "No hay productos en este pedido.",
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: pedido.productos.length,
                  itemBuilder: (context, index) {
                    return _buildProductTableRow(
                      pedido.productos[index],
                      index,
                      pedido,
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
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
                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
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
                  () =>
                      _showEditSummaryDialog(pedido, 'envio', pedido.envio),
                ),
                const SizedBox(height: 8),
                const SizedBox(width: 250, child: Divider()),
                _buildGrandTotalRow(pedido.totalGeneral),
              ],
            ),
          ],
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
                      "PROVEEDOR",
                      pedido.proveedor,
                      Icons.storefront_outlined,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _buildMetadataItem(
                      "FECHA",
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
                      "PAGADO POR",
                      pedido.pagadoPor,
                      Icons.person_outline,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _buildMetadataItem(
                      "REF / MEMO",
                      pedido.referencia.isEmpty ? "Sin Ref" : pedido.referencia,
                      Icons.receipt_long_outlined,
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
                  Expanded(
                    flex: 1,
                    child: _buildLotesSection(pedido),
                  ),
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

  Widget _buildCatalogMaintenance(BuildContext context) {
    final tabs = ["Categorías", "Proveedores", "Unidades de Venta"];
    final icons = [
      Icons.category_outlined,
      Icons.local_shipping_outlined,
      Icons.square_foot_outlined,
    ];

    List<String> currentList;
    if (_activeCatalogTab == 0) {
      currentList = _categories;
    } else if (_activeCatalogTab == 1) {
      currentList = _providers;
    } else {
      currentList = _units;
    }

    final searchQuery = _catalogSearchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      currentList = currentList
          .where((e) => e.toLowerCase().contains(searchQuery))
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Navigation Tabs
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
          ),
          child: Row(
            children: List.generate(tabs.length, (index) {
              return Expanded(
                child: _buildCatalogTab(index, tabs[index], icons[index]),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        // Data Table Card
        Expanded(
          child: Card(
            color: AppColors.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Search & Add)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _catalogSearchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText:
                                "Buscar en ${tabs[_activeCatalogTab].toLowerCase()}...",
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.onSurfaceVariant,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text("Añadir Nuevo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () =>
                            _showAddCatalogDialog(context, _activeCatalogTab),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "NOMBRE",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "USO (PRODUCTOS/LOTES)",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          "ACCIONES",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Table Body
                Expanded(
                  child: currentList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: AppColors.outlineVariant,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No se encontraron resultados",
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: currentList.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = currentList[index];

                            return FutureBuilder<int>(
                              future: _fetchCatalogUsageCount(
                                item,
                                _activeCatalogTab,
                              ),
                              builder: (context, snapshot) {
                                final usage = snapshot.data ?? 0;
                                final isLoading =
                                    snapshot.connectionState ==
                                    ConnectionState.waiting;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: usage > 0
                                                    ? AppColors.primary
                                                    : Colors.grey,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isLoading
                                                  ? Colors.transparent
                                                  : (usage > 0
                                                        ? AppColors.primary
                                                              .withValues(
                                                                alpha: 0.1,
                                                              )
                                                        : AppColors
                                                              .surfaceContainerLow),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: isLoading
                                                ? const SizedBox(
                                                    width: 12,
                                                    height: 12,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : Text(
                                                    usage > 0
                                                        ? "$usage asociados"
                                                        : "Sin uso",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: usage > 0
                                                          ? AppColors.primary
                                                          : AppColors
                                                                .onSurfaceVariant,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                              ),
                                              color: AppColors.primary,
                                              tooltip: "Renombrar",
                                              onPressed: () =>
                                                  _showRenameCatalogDialog(
                                                    context,
                                                    item,
                                                    _activeCatalogTab,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                              ),
                                              color: Colors.red,
                                              tooltip: "Eliminar",
                                              onPressed: () =>
                                                  _confirmDeleteCatalog(
                                                    context,
                                                    item,
                                                    _activeCatalogTab,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
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
      centerWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCustomTab(0, "Gestión de Inventario"),
          const SizedBox(width: 12),
          _buildCustomTab(1, "Catálogos"),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección principal
          if (_activeTab == 0)
            Expanded(child: _buildInventoryOrdersView(context))
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: _buildCatalogMaintenance(context),
              ),
            ),
        ],
      ),
    );
  }
}
