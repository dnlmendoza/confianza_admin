import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:confianza_admin/modulos/inventario/viewmodel_inventario.dart';
import 'package:confianza_admin/modulos/inventario/vm_catalogos.dart';

class VistaInventario extends StatefulWidget {
  const VistaInventario({super.key});

  @override
  State<VistaInventario> createState() => _VistaInventarioState();
}

class _VistaInventarioState extends State<VistaInventario> {
  // Controladores y estados reactivos
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "Todas las Categorías";
  String _selectedProvider = "Todos los Proveedores";

  // Tab State
  int _activeTab = 0; // 0: Inventario y Lotes, 1: Mantenimiento de Catálogos
  int _activeCatalogTab = 0; // 0: Categorías, 1: Proveedores, 2: Unidades
  final TextEditingController _catalogSearchController =
      TextEditingController();

  // Dynamic lists for catalogs (vinculados al ViewModel)
  late final VMCatalogos _vmCatalogos;

  List<String> get _categories => _vmCatalogos.categorias;
  List<String> get _providers => _vmCatalogos.proveedores;
  List<String> get _units => _vmCatalogos.unidades;

  // Lista base del inventario
  List<ProductItem> _products = [];

  ProductItem? _selectedProduct;
  bool _isDetailsExpanded = false;

  StreamSubscription? _inventarioSub;
  StreamSubscription? _lotesSub;

  List<Map<String, dynamic>> _rawProducts = [];
  List<Map<String, dynamic>> _rawLotes = [];

  late final TextEditingController _nameEditController;
  late final TextEditingController _subtitleEditController;
  late final TextEditingController _skuEditController;
  late final TextEditingController _categoryEditController;
  late final TextEditingController _minStockEditController;
  late final TextEditingController _providerEditController;
  late final TextEditingController _productTypeEditController;
  late final TextEditingController _dateEnteredEditController;

  @override
  void initState() {
    super.initState();
    _vmCatalogos = VMCatalogos()
      ..addListener(() {
        if (mounted) {
          _combineAndSetProducts();
          setState(() {});
        }
      });

    _nameEditController = TextEditingController(text: "");
    _subtitleEditController = TextEditingController(text: "");
    _skuEditController = TextEditingController(text: "");
    _categoryEditController = TextEditingController(text: "");
    _minStockEditController = TextEditingController(text: "1");
    _providerEditController = TextEditingController(text: "Bodega");
    _productTypeEditController = TextEditingController(text: "Normal");
    _dateEnteredEditController = TextEditingController(text: "");

    _nameEditController.addListener(_onFormChanged);
    _subtitleEditController.addListener(_onFormChanged);
    _skuEditController.addListener(_onFormChanged);
    _categoryEditController.addListener(_onFormChanged);
    _minStockEditController.addListener(_onFormChanged);
    _providerEditController.addListener(_onFormChanged);
    _productTypeEditController.addListener(_onFormChanged);
    _dateEnteredEditController.addListener(_onFormChanged);

    _initInventarioStreams();
  }

  @override
  void dispose() {
    _inventarioSub?.cancel();
    _lotesSub?.cancel();
    _vmCatalogos.dispose();
    _searchController.dispose();
    _catalogSearchController.dispose();
    _nameEditController.dispose();
    _subtitleEditController.dispose();
    _skuEditController.dispose();
    _categoryEditController.dispose();
    _minStockEditController.dispose();
    _providerEditController.dispose();
    _productTypeEditController.dispose();
    _dateEnteredEditController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
  }

  bool _isFormDirty() {
    if (_selectedProduct == null) return false;
    return _nameEditController.text != _selectedProduct!.name ||
        _subtitleEditController.text != _selectedProduct!.subtitle ||
        _skuEditController.text != _selectedProduct!.sku ||
        _categoryEditController.text != _selectedProduct!.category ||
        _minStockEditController.text != _selectedProduct!.minStock.toString() ||
        _providerEditController.text != _selectedProduct!.provider ||
        _productTypeEditController.text != _selectedProduct!.productType ||
        _dateEnteredEditController.text != _selectedProduct!.dateEntered;
  }

  void _saveProductDetails() {
    if (_selectedProduct == null) return;
    setState(() {
      _selectedProduct!.name = _nameEditController.text.trim();
      _selectedProduct!.subtitle = _subtitleEditController.text.trim();
      _selectedProduct!.sku = _skuEditController.text.trim();
      _selectedProduct!.category = _categoryEditController.text.trim();
      _selectedProduct!.minStock =
          int.tryParse(_minStockEditController.text) ?? 1;
      _selectedProduct!.provider = _providerEditController.text.trim();
      _selectedProduct!.productType = _productTypeEditController.text.trim();
      _selectedProduct!.dateEntered = _dateEnteredEditController.text.trim();
    });
    _saveProductToFirestore(_selectedProduct!);
  }

  void _selectProduct(ProductItem product) {
    setState(() {
      _selectedProduct = product;
      _nameEditController.text = product.name;
      _subtitleEditController.text = product.subtitle;
      _skuEditController.text = product.sku;
      _categoryEditController.text = product.category;
      _minStockEditController.text = product.minStock.toString();
      _providerEditController.text = product.provider;
      _productTypeEditController.text = product.productType;
      _dateEnteredEditController.text = product.dateEntered;
    });
  }

  void _initInventarioStreams() {
    final firestore = FirebaseFirestore.instance;

    _inventarioSub = firestore
        .collection('Inventario')
        .snapshots()
        .listen(
          (invSnap) {
            _rawProducts = invSnap.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList();
            _combineAndSetProducts();
          },
          onError: (e) {
            debugPrint("Error al escuchar colección Inventario: $e");
          },
        );

    _lotesSub = firestore
        .collectionGroup('lote')
        .snapshots()
        .listen(
          (lotesSnap) {
            _rawLotes = lotesSnap.docs.map((doc) {
              final sku = doc.reference.parent.parent?.id ?? '';
              return {'id': doc.id, 'sku': sku, ...doc.data()};
            }).toList();
            _combineAndSetProducts();
          },
          onError: (e) {
            debugPrint("Error al escuchar collectionGroup lote: $e");
          },
        );
  }

  void _combineAndSetProducts() {
    if (!mounted) return;

    final List<ProductItem> parsedProducts = [];

    for (var rawProd in _rawProducts) {
      final String sku = rawProd['id'] ?? '';
      final prodLotesRaw = _rawLotes.where((l) => l['sku'] == sku).toList();

      final List<LoteItem> lotes = prodLotesRaw.map((l) {
        final stock = int.tryParse(l['cantidad']?.toString() ?? '0') ?? 0;
        final costoUnitario =
            double.tryParse(l['costo_unitario']?.toString() ?? '0.0') ?? 0.0;
        final precioVenta =
            double.tryParse(l['precio_venta']?.toString() ?? '0.0') ?? 0.0;
        final costoLote =
            double.tryParse(l['costo_lote']?.toString() ?? '') ??
            (costoUnitario * stock);
        final gananciaUnidad =
            double.tryParse(l['ganancia_unidad']?.toString() ?? '') ??
            (precioVenta - costoUnitario);
        final gananciaLote =
            double.tryParse(l['ganancia_lote']?.toString() ?? '') ??
            (gananciaUnidad * stock);
        final danados =
            int.tryParse(l['cantidad_danada']?.toString() ?? '0') ?? 0;

        final String unidadId = l['unidades']?.toString() ?? 'Unid';
        final String unidadName = _vmCatalogos.unidadesMap[unidadId] ?? unidadId;

        return LoteItem(
          id: l['id'] ?? '',
          stock: stock,
          fechaIngreso: l['fecha_ingreso']?.toString() ?? '',
          fechaVencimiento: l['fecha_vencimiento']?.toString() ?? '28-02-2027',
          unidades: unidadName,
          costoLote: costoLote,
          costoUnitario: costoUnitario,
          impuestoCompra:
              double.tryParse(l['impuesto_compra']?.toString() ?? '15.0') ??
              15.0,
          precioVenta: precioVenta,
          impuestoVenta:
              double.tryParse(l['impuesto_venta']?.toString() ?? '15.0') ??
              15.0,
          gananciaUnidad: gananciaUnidad,
          gananciaLote: gananciaLote,
          danados: danados,
          ubicacion: l['ubicacion']?.toString() ?? 'Estante A1',
        );
      }).toList();

      lotes.sort((a, b) {
        final dateA = _parseFechaStr(a.fechaIngreso);
        final dateB = _parseFechaStr(b.fechaIngreso);
        return dateA.compareTo(dateB);
      });

      final totalStock = lotes.fold<int>(0, (total, lot) => total + lot.stock);
      final price = lotes.isNotEmpty ? lotes.first.precioVenta : 0.00;

      final minStock =
          int.tryParse(rawProd['cantidad_minima']?.toString() ?? '1') ?? 1;

      final String catId = rawProd['categoria']?.toString() ?? 'General';
      final String catName = _vmCatalogos.categoriasMap[catId] ?? catId;

      final String provId = rawProd['proveedor']?.toString() ?? 'Bodega';
      final String provName = _vmCatalogos.proveedoresMap[provId] ?? provId;

      parsedProducts.add(
        ProductItem(
          name: rawProd['nombre']?.toString() ?? 'Sin nombre',
          subtitle: rawProd['descripcion']?.toString() ?? '',
          sku: sku,
          category: catName,
          stock: totalStock,
          maxStock:
              int.tryParse(rawProd['stockMaximo']?.toString() ?? '100') ?? 100,
          price: price,
          imageUrl:
              rawProd['imagen']?.toString() ??
              rawProd['fotoUrl']?.toString() ??
              rawProd['imagePath']?.toString() ??
              rawProd['Imagen']?.toString() ??
              '',
          lotes: lotes,
          provider: provName,
          minStock: minStock,
          productType: rawProd['tipo_producto']?.toString() ?? 'Normal',
          dateEntered: rawProd['fecha']?.toString() ?? '19-05-26',
        ),
      );
    }

    setState(() {
      _products = parsedProducts;

      if (_selectedProduct != null) {
        final updatedProd = _products.firstWhere(
          (p) => p.sku == _selectedProduct!.sku,
          orElse: () =>
              _products.isNotEmpty ? _products.first : _selectedProduct!,
        );

        final changedSelection = updatedProd.sku != _selectedProduct!.sku;

        if (_products.isNotEmpty) {
          _selectedProduct = updatedProd;
          if (changedSelection || !_isFormDirty()) {
            _selectProduct(_selectedProduct!);
          }
        } else {
          _selectedProduct = null;
        }
      } else if (_products.isNotEmpty) {
        _selectedProduct = _products.first;
        _selectProduct(_selectedProduct!);
      }
    });
  }

  DateTime _parseFechaStr(String valor) {
    if (valor.isNotEmpty) {
      try {
        final parts = valor.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } catch (_) {}
    }
    return DateTime(1900);
  }

  Future<void> _saveProductToFirestore(ProductItem product) async {
    try {
      final String catName = product.category;
      final String catId = _vmCatalogos.categoriasMap.entries
          .firstWhere(
            (e) => e.value == catName,
            orElse: () => MapEntry(catName, catName),
          )
          .key;

      final String provName = product.provider;
      final String provId = _vmCatalogos.proveedoresMap.entries
          .firstWhere(
            (e) => e.value == provName,
            orElse: () => MapEntry(provName, provName),
          )
          .key;

      final firestore = FirebaseFirestore.instance;
      await firestore.collection('Inventario').doc(product.sku).set({
        'nombre': product.name,
        'descripcion': product.subtitle,
        'categoria': catId,
        'proveedor': provId,
        'cantidad_minima': product.minStock,
        'tipo_producto': product.productType,
        'fecha': product.dateEntered,
        'imagen': product.imageUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error al guardar producto en Firestore: $e");
    }
  }

  Future<void> _saveLoteToFirestore(String productSku, LoteItem lote) async {
    try {
      final String uniName = lote.unidades;
      final String uniId = _vmCatalogos.unidadesMap.entries
          .firstWhere(
            (e) => e.value == uniName,
            orElse: () => MapEntry(uniName, uniName),
          )
          .key;

      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('Inventario')
          .doc(productSku)
          .collection('lote')
          .doc(lote.id)
          .set({
            'cantidad': lote.stock,
            'cantidad_danada': lote.danados,
            'costo_unitario': lote.costoUnitario,
            'precio_venta': lote.precioVenta,
            'impuesto_compra': lote.impuestoCompra,
            'impuesto_venta': lote.impuestoVenta,
            'unidades': uniId,
            'fecha_vencimiento': lote.fechaVencimiento,
            'fecha_ingreso': lote.fechaIngreso,
            'costo_lote': lote.costoLote,
            'ganancia_unidad': lote.gananciaUnidad,
            'ganancia_lote': lote.gananciaLote,
            'ubicacion': lote.ubicacion,
            'actualizado': lote.fechaIngreso,
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error al guardar lote en Firestore: $e");
    }
  }

  // Filtrado reactivo de productos basado en búsqueda y dropdowns
  List<ProductItem> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((item) {
      final matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == "Todas las Categorías" ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesProvider =
          _selectedProvider == "Todos los Proveedores" ||
          item.provider.toLowerCase() == _selectedProvider.toLowerCase();

      return matchesSearch && matchesCategory && matchesProvider;
    }).toList();
  }

  // KPI calculations
  int get _totalStock {
    return _products.fold(0, (total, item) {
      final activeLot = _getActiveLot(item);
      return total + (activeLot?.stock ?? 0);
    });
  }

  int get _lowStockCount {
    return _products.where((item) {
      final activeLot = _getActiveLot(item);
      return (activeLot?.stock ?? 0) < 20;
    }).length;
  }

  double get _totalValue {
    return _products.fold(0.0, (total, item) {
      final activeLot = _getActiveLot(item);
      final price = activeLot?.precioVenta ?? item.price;
      final stock = activeLot?.stock ?? 0;
      return total + (price * stock);
    });
  }

  int get _uniqueCategories =>
      _products.map((item) => item.category).toSet().length;

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return DateTime(2000, 1, 1);
  }

  LoteItem? _getActiveLot(ProductItem product) {
    if (product.lotes.isEmpty) return null;
    final sorted = List<LoteItem>.from(product.lotes)
      ..sort(
        (a, b) =>
            _parseDate(a.fechaIngreso).compareTo(_parseDate(b.fechaIngreso)),
      );
    for (var lote in sorted) {
      if (lote.stock > 0) {
        return lote;
      }
    }
    return sorted.last;
  }

  // _buildTabButton was removed in favor of SegmentedButton

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      activeRoute: '/inventario',
      title: 'Inventario',
      centerWidget: SegmentedButton<int>(
        segments: const [
          ButtonSegment<int>(
            value: 0,
            icon: Icon(Icons.inventory_2_outlined, size: 18),
            label: Text(
              "Gestión de Inventario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ButtonSegment<int>(
            value: 1,
            icon: Icon(Icons.settings_outlined, size: 18),
            label: Text(
              "Catálogos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
        selected: {_activeTab},
        onSelectionChanged: (v) {
          setState(() {
            _activeTab = v.first;
          });
        },
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección superior fija: KPIs + controles de tabla
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBentoGrid(context),
                const SizedBox(height: 14),
                if (_activeTab == 0) ...[],
              ],
            ),
          ),

          // Sección inferior expandida: llena el espacio restante hasta abajo
          if (_activeTab == 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _buildSplitScreenLayout(context),
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _buildCatalogMaintenance(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSplitScreenLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Columna Izquierda: Tabla de Artículos (llena toda la altura)
          Expanded(flex: 1, child: _buildInventoryTableCard(context)),
          const SizedBox(width: 24),
          // Columna Derecha: Detalles + Lotes
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildArticleDetailsCard(context),
                const SizedBox(height: 24),
                Expanded(child: _buildArticleBatchesCard(context)),
              ],
            ),
          ),
        ],
      );
    } else {
      // Vista Móvil / Tablet: Apilado vertical con scroll
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInventoryTableCard(context),
            const SizedBox(height: 24),
            _buildArticleDetailsCard(context),
            const SizedBox(height: 24),
            _buildArticleBatchesCard(context),
          ],
        ),
      );
    }
  }

  /// 1. Bento-Grid de Tarjetas KPI
  Widget _buildBentoGrid(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GridView.count(
      crossAxisCount: isMobile ? 1 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isMobile ? 4.0 : 2.1,
      children: [
        _buildKpiCard(
          title: "Stock Total",
          value: _totalStock.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => "${m[1]},",
          ),
          subtitle: "+2.4% este mes",
          icon: Icons.inventory_2,
          iconColor: AppColors.primary,
          iconBgColor: const Color(0xFFCCE5FF),
          subtitleColor: const Color(0xFF10B981),
          isTrend: true,
        ),
        _buildKpiCard(
          title: "Bajo Stock",
          value: _lowStockCount.toString(),
          subtitle: "Artículos críticos",
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFBA1A1A),
          iconBgColor: const Color(0xFFFFDAD6),
          subtitleColor: const Color(0xFFBA1A1A),
          isTrend: false,
        ),
        _buildKpiCard(
          title: "Valor Inventario",
          value: "L. ${(_totalValue / 1000).toStringAsFixed(1)}k",
          subtitle: "Valor estimado",
          icon: Icons.payments,
          iconColor: const Color(0xFF4E6073),
          iconBgColor: const Color(0xFFD1E4FB),
          subtitleColor: AppColors.onSurfaceVariant,
          isTrend: false,
        ),
        _buildKpiCard(
          title: "Categorías",
          value: _uniqueCategories.toString(),
          subtitle: "Activas",
          icon: Icons.category,
          iconColor: const Color(0xFF8E6A00),
          iconBgColor: const Color(0xFFFFEDC8),
          subtitleColor: AppColors.onSurfaceVariant,
          isTrend: false,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color subtitleColor,
    bool isTrend = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (isTrend) ...[
                    Icon(Icons.trending_up, color: subtitleColor, size: 14),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. Tabla de Inventario Completa
  Widget _buildInventoryTableCard(BuildContext context) {
    final filtered = _filteredProducts;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header y Buscador
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Lista Inventario",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddProductDialog(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Nuevo Artículo"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (_) {
                            setState(() {}); // Actualiza la tabla al buscar
                          },
                          decoration: InputDecoration(
                            hintText: "Buscar nombre o código...",
                            hintStyle: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                            isDense: true,
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: AppColors.onSurfaceVariant,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      tooltip: "Filtrar por Categoría",
                      icon: Icon(
                        Icons.category_outlined,
                        color: _selectedCategory != "Todas las Categorías"
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                      onSelected: (String newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return {"Todas las Categorías", ..._categories}
                            .map((String value) {
                          return PopupMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontWeight: _selectedCategory == value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedCategory == value
                                    ? AppColors.primary
                                    : AppColors.onSurface,
                              ),
                            ),
                          );
                        }).toList();
                      },
                    ),
                    PopupMenuButton<String>(
                      tooltip: "Filtrar por Proveedor",
                      icon: Icon(
                        Icons.local_shipping_outlined,
                        color: _selectedProvider != "Todos los Proveedores"
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                      onSelected: (String newValue) {
                        setState(() {
                          _selectedProvider = newValue;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return {"Todos los Proveedores", ..._providers}
                            .map((String value) {
                          return PopupMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontWeight: _selectedProvider == value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedProvider == value
                                    ? AppColors.primary
                                    : AppColors.onSurface,
                              ),
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tabla con scroll vertical o mensaje de lista vacía
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: AppColors.outlineVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchController.text.isNotEmpty
                                ? "No se encontraron productos coincidentes"
                                : "No hay artículos en el inventario",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(5.2), // Nombre del Item
                        1: FlexColumnWidth(2.5), // Categoría/Proveedor
                      },
                      children: [
                        ...filtered.map((item) {
                          final isSelected = _selectedProduct == item;

                          return TableRow(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : null,
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.outlineVariant,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            children: [
                              // Nombre del Item + Descripcion
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => _selectProduct(item),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 10.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            color: AppColors.onSurface,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.subtitle,
                                          style: const TextStyle(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Categoría y Proveedor
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => _selectProduct(item),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 10.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.category_outlined,
                                              size: 14,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                item.category,
                                                style: const TextStyle(
                                                  color: AppColors.onSurface,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.local_shipping_outlined,
                                              size: 14,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                item.provider,
                                                style: const TextStyle(
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// 5. Tarjeta de Detalles del Artículo Seleccionado (Collapsible & Smart)
  Widget _buildArticleDetailsCard(BuildContext context) {
    if (_selectedProduct == null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          "Seleccione un artículo para ver detalles",
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    final showGuardar = _isDetailsExpanded && _isFormDirty();

    return Card(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Datos del Artículo",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (showGuardar)
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: ElevatedButton.icon(
                            onPressed: _saveProductDetails,
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text("Guardar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isDetailsExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: AppColors.onSurfaceVariant,
                          ),
                          tooltip: _isDetailsExpanded
                              ? "Ocultar detalles"
                              : "Mostrar detalles",
                          onPressed: () {
                            setState(() {
                              _isDetailsExpanded = !_isDetailsExpanded;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 130,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _selectedProduct!.imageUrl.isNotEmpty
                          ? Image.network(
                              _selectedProduct!.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.image,
                                    color: AppColors.outlineVariant,
                                    size: 32,
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(
                                Icons.image,
                                color: AppColors.outlineVariant,
                                size: 32,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFormField(
                            label: "Nombre del Producto",
                            controller: _nameEditController,
                            visible: true,
                          ),
                          _buildFormField(
                            label: "Descripción / Subtítulo",
                            controller: _subtitleEditController,
                            visible: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isDetailsExpanded) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: "Código de Barra",
                        controller: _skuEditController,
                        visible: true,
                        readOnly: true,
                        prefixIcon: Icons.calendar_view_week_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                "Tipo de Producto",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment<String>(
                                    value: "Normal",
                                    label: Text(
                                      "Normal",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    icon: Icon(
                                      Icons.inventory_2_outlined,
                                      size: 16,
                                    ),
                                  ),
                                  ButtonSegment<String>(
                                    value: "Pesado",
                                    label: Text(
                                      "Pesado",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    icon: Icon(Icons.scale_rounded, size: 16),
                                  ),
                                ],
                                selected: {
                                  (_productTypeEditController.text
                                              .toLowerCase() ==
                                          "pesado")
                                      ? "Pesado"
                                      : "Normal",
                                },
                                onSelectionChanged: (Set<String> newSelection) {
                                  setState(() {
                                    _productTypeEditController.text =
                                        newSelection.first;
                                  });
                                },
                                showSelectedIcon: false,
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                  side: const WidgetStatePropertyAll(
                                    BorderSide(
                                      color: AppColors.outlineVariant,
                                      width: 1,
                                    ),
                                  ),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePickerFormField(
                        label: "Fecha Ingresado",
                        controller: _dateEnteredEditController,
                        visible: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCounterFormField(
                        label: "Cantidad Mínima",
                        controller: _minStockEditController,
                        visible: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownFormField(
                        label: "Categoría",
                        controller: _categoryEditController,
                        options: _categories,
                        visible: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownFormField(
                        label: "Proveedor",
                        controller: _providerEditController,
                        options: _providers,
                        visible: true,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required TextEditingController controller,
    required List<String> options,
    required bool visible,
  }) {
    if (!visible) return const SizedBox.shrink();

    final safeOptions = List<String>.from(options);
    final currentValue = controller.text.trim();
    if (currentValue.isNotEmpty && !safeOptions.contains(currentValue)) {
      safeOptions.add(currentValue);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: currentValue.isEmpty ? null : currentValue,
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.text = newValue;
              }
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              isDense: true,
              hintText: "Seleccione $label",
              hintStyle: const TextStyle(
                color: AppColors.outlineVariant,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            items: safeOptions.map((String opt) {
              return DropdownMenuItem<String>(
                value: opt,
                child: Text(
                  opt,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterFormField({
    required String label,
    required TextEditingController controller,
    required bool visible,
  }) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              isDense: true,
              hintText: "0",
              hintStyle: const TextStyle(
                color: AppColors.outlineVariant,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              prefixIcon: IconButton(
                icon: const Icon(
                  Icons.remove,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  final val = int.tryParse(controller.text) ?? 0;
                  if (val > 0) {
                    controller.text = (val - 1).toString();
                  }
                },
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  final val = int.tryParse(controller.text) ?? 0;
                  controller.text = (val + 1).toString();
                },
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerFormField({
    required String label,
    required TextEditingController controller,
    required bool visible,
  }) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            readOnly: false,
            keyboardType: TextInputType.datetime,
            style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              isDense: true,
              hintText: "Ingrese $label",
              hintStyle: const TextStyle(
                color: AppColors.outlineVariant,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () async {
                  DateTime initialDate = DateTime.now();
                  try {
                    final parsed = _parseDate(controller.text);
                    int year = parsed.year;
                    if (year < 100) {
                      year += 2000;
                    }
                    final adjustedDate = DateTime(
                      year,
                      parsed.month,
                      parsed.day,
                    );
                    final first = DateTime(2020);
                    final last = DateTime(2035);
                    if (!adjustedDate.isBefore(first) &&
                        !adjustedDate.isAfter(last)) {
                      initialDate = adjustedDate;
                    }
                  } catch (_) {}

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    controller.text =
                        "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                  }
                },
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required bool visible,
    int maxLines = 1,
    bool readOnly = false,
    IconData? prefixIcon,
  }) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            style: TextStyle(
              fontSize: 13,
              color: readOnly
                  ? AppColors.onSurfaceVariant
                  : AppColors.onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: "Ingrese $label",
              filled: readOnly,
              fillColor: readOnly ? AppColors.surfaceContainerLowest : null,
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    )
                  : null,
              prefixIconConstraints: prefixIcon != null
                  ? const BoxConstraints(minWidth: 36, minHeight: 36)
                  : null,
              hintStyle: const TextStyle(
                color: AppColors.outlineVariant,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Tarjeta de Lotes del Artículo Seleccionado
  Widget _buildArticleBatchesCard(BuildContext context) {
    if (_selectedProduct == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          "Seleccione un artículo para ver los lotes",
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    final activeLot = _getActiveLot(_selectedProduct!);
    final sortedLotes = List<LoteItem>.from(_selectedProduct!.lotes)
      ..sort(
        (a, b) =>
            _parseDate(a.fechaIngreso).compareTo(_parseDate(b.fechaIngreso)),
      );

    return Card(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final loteList = sortedLotes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.layers_clear_outlined,
                            size: 48,
                            color: AppColors.outlineVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No hay ningún lote registrado",
                            style: GoogleFonts.outfit(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: !constraints.hasBoundedHeight,
                    physics: constraints.hasBoundedHeight
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemCount: sortedLotes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final lote = sortedLotes[index];
                      final isActive =
                          activeLot != null && lote.id == activeLot.id;
                      return _InteractiveLoteRow(
                        lote: lote,
                        isActiveLot: isActive,
                        units: _units,
                        onChanged: () {
                          setState(() {
                            // Recalcular stock total del producto
                            _selectedProduct!.stock = _selectedProduct!.lotes
                                .fold(0, (total, lot) => total + lot.stock);
                          });
                          _saveLoteToFirestore(_selectedProduct!.sku, lote);
                        },
                      );
                    },
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Historial de Lotes",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Control de los lotes ingresados para este artículo.",
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddLoteDialog(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Nuevo Lote"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (sortedLotes.isEmpty)
                  loteList
                else
                  Expanded(child: loteList),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) async {
    final newProduct = await showDialog<ProductItem>(
      context: context,
      builder: (context) {
        final cats = _categories
            .where((c) => c != "Todas las Categorías" && c != "Todas")
            .toList();
        final provs = _providers
            .where((p) => p != "Todos los Proveedores" && p != "Todos")
            .toList();
        return _AddProductDialog(
          categories: cats.isNotEmpty ? cats : ["General"],
          providers: provs.isNotEmpty ? provs : ["Bodega"],
        );
      },
    );

    if (newProduct != null) {
      setState(() {
        _products.insert(0, newProduct);
        _selectProduct(newProduct);
      });
      _saveProductToFirestore(newProduct);
    }
  }

  void _showAddLoteDialog(BuildContext context) async {
    if (_selectedProduct == null) return;
    final newLote = await showDialog<LoteItem>(
      context: context,
      builder: (context) =>
          _AddLoteDialog(product: _selectedProduct!, units: _units),
    );
    if (newLote != null) {
      setState(() {
        _selectedProduct!.lotes.add(newLote);
        // Recalcular stock total del producto
        _selectedProduct!.stock = _selectedProduct!.lotes.fold(
          0,
          (total, lot) => total + lot.stock,
        );
      });
      _saveLoteToFirestore(_selectedProduct!.sku, newLote);
    }
  }

  void _renameCategory(String oldCat, String newCat) {
    _vmCatalogos.renameCategoria(oldCat, newCat);
    setState(() {
      for (var product in _products) {
        if (product.category.toLowerCase() == oldCat.toLowerCase()) {
          product.category = newCat;
        }
      }
      // Also update selected product if needed
      if (_selectedProduct != null) {
        _selectProduct(_selectedProduct!);
      }
    });
  }

  void _deleteCategory(String cat) {
    _vmCatalogos.deleteCategoria(cat);
    setState(() {
      final fallback = "General";
      for (var product in _products) {
        if (product.category.toLowerCase() == cat.toLowerCase()) {
          product.category = fallback;
        }
      }
      // Reset selected category filter if it matches the deleted one
      if (_selectedCategory.toLowerCase() == cat.toLowerCase()) {
        _selectedCategory = "Todas las Categorías";
      }
      if (_selectedProduct != null) {
        _selectProduct(_selectedProduct!);
      }
    });
  }

  void _renameProvider(String oldProv, String newProv) {
    _vmCatalogos.renameProveedor(oldProv, newProv);
    setState(() {
      for (var product in _products) {
        if (product.provider.toLowerCase() == oldProv.toLowerCase()) {
          product.provider = newProv;
        }
      }
      if (_selectedProduct != null) {
        _selectProduct(_selectedProduct!);
      }
    });
  }

  void _deleteProvider(String prov) {
    _vmCatalogos.deleteProveedor(prov);
    setState(() {
      final fallback = "Bodega";
      for (var product in _products) {
        if (product.provider.toLowerCase() == prov.toLowerCase()) {
          product.provider = fallback;
        }
      }
      if (_selectedProvider.toLowerCase() == prov.toLowerCase()) {
        _selectedProvider = "Todos los Proveedores";
      }
      if (_selectedProduct != null) {
        _selectProduct(_selectedProduct!);
      }
    });
  }

  void _renameUnit(String oldUnit, String newUnit) {
    _vmCatalogos.renameUnidad(oldUnit, newUnit);
    setState(() {
      for (var product in _products) {
        for (var lote in product.lotes) {
          if (lote.unidades.toLowerCase() == oldUnit.toLowerCase()) {
            lote.unidades = newUnit;
          }
        }
      }
      if (_selectedProduct != null) {
        _selectProduct(_selectedProduct!);
      }
    });
  }

  void _deleteUnit(String unit) {
    _vmCatalogos.deleteUnidad(unit);
    setState(() {
      final fallback = "Unid";
      for (var product in _products) {
        for (var lote in product.lotes) {
          if (lote.unidades.toLowerCase() == unit.toLowerCase()) {
            lote.unidades = fallback;
          }
        }
      }
      if (_selectedProduct != null) {
        _selectProduct(_selectedProduct!);
      }
    });
  }

  Future<int> _fetchCatalogUsageCount(String item, int tabIndex) async {
    try {
      final firestore = FirebaseFirestore.instance;
      if (tabIndex == 0) {
        // Categorías: Guardan el ID, no el nombre. Primero buscamos el ID.
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
        // Fallback: por si acaso hay registros antiguos que usaron el texto
        final snapStr = await firestore
            .collection('Inventario')
            .where('categoria', isEqualTo: item)
            .count()
            .get();
        return count + (snapStr.count ?? 0);
      } else if (tabIndex == 1) {
        // Proveedores: Igual que categorías
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
        // Fallback texto
        final snapStr = await firestore
            .collection('Inventario')
            .where('proveedor', isEqualTo: item)
            .count()
            .get();
        return count + (snapStr.count ?? 0);
      } else {
        // Unidades: Guardan el ID o el texto.
        final unitSnap = await firestore
            .collection('Unidades')
            .where('Tipo', isEqualTo: item)
            .get();
        final List<String> possibleValues = unitSnap.docs
            .map((d) => d.id)
            .toList();
        possibleValues.add(item); // Fallback al texto

        int count = 0;
        try {
          // Intentamos usar collectionGroup primero (requiere índice)
          final snapId = await firestore
              .collectionGroup('lote')
              .where('unidades', whereIn: possibleValues)
              .count()
              .get();
          count = snapId.count ?? 0;
        } catch (e) {
          debugPrint(
            "Falta índice collectionGroup, usando iteración manual en memoria: $e",
          );
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
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = _activeCatalogTab == index;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _activeCatalogTab = index;
                      _catalogSearchController.clear();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[index],
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tabs[index],
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                  color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
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
}

class _InteractiveLoteRow extends StatefulWidget {
  final LoteItem lote;
  final bool isActiveLot;
  final List<String> units;
  final VoidCallback onChanged;

  const _InteractiveLoteRow({
    required this.lote,
    required this.isActiveLot,
    required this.units,
    required this.onChanged,
  });

  @override
  State<_InteractiveLoteRow> createState() => _InteractiveLoteRowState();
}

class _InteractiveLoteRowState extends State<_InteractiveLoteRow> {
  bool _isExpanded = false;

  late final TextEditingController _stockController;
  late final TextEditingController _danadosController;

  late final TextEditingController _costoUnitarioController;
  late final TextEditingController _precioVentaController;
  late final TextEditingController _impuestoCompraController;
  late final TextEditingController _impuestoVentaController;

  late final TextEditingController _costoLoteController;
  late final TextEditingController _gananciaUnidadController;
  late final TextEditingController _gananciaLoteController;

  late String _unidades;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(
      text: widget.lote.stock.toString(),
    );
    _danadosController = TextEditingController(
      text: widget.lote.danados.toString(),
    );

    _costoUnitarioController = TextEditingController(
      text: widget.lote.costoUnitario.toString(),
    );
    _precioVentaController = TextEditingController(
      text: widget.lote.precioVenta.toString(),
    );
    _impuestoCompraController = TextEditingController(
      text: widget.lote.impuestoCompra.toStringAsFixed(0),
    );
    _impuestoVentaController = TextEditingController(
      text: widget.lote.impuestoVenta.toStringAsFixed(0),
    );

    _costoLoteController = TextEditingController(
      text: widget.lote.costoLote.toStringAsFixed(2),
    );
    _gananciaUnidadController = TextEditingController(
      text: widget.lote.gananciaUnidad.toStringAsFixed(2),
    );
    _gananciaLoteController = TextEditingController(
      text: widget.lote.gananciaLote.toStringAsFixed(2),
    );

    _unidades = widget.lote.unidades;
    if (!widget.units.contains(_unidades) && widget.units.isNotEmpty) {
      _unidades = widget.units.first;
    }

    _stockController.addListener(_onFieldsChanged);
    _danadosController.addListener(_onFieldsChanged);

    _costoUnitarioController.addListener(_onFieldsChanged);
    _precioVentaController.addListener(_onFieldsChanged);
    _impuestoCompraController.addListener(_onFieldsChanged);
    _impuestoVentaController.addListener(_onFieldsChanged);

    _costoLoteController.addListener(_onDerivedFieldsChanged);
    _gananciaUnidadController.addListener(_onDerivedFieldsChanged);
    _gananciaLoteController.addListener(_onDerivedFieldsChanged);
  }

  @override
  void dispose() {
    _stockController.dispose();
    _danadosController.dispose();

    _costoUnitarioController.dispose();
    _precioVentaController.dispose();
    _impuestoCompraController.dispose();
    _impuestoVentaController.dispose();

    _costoLoteController.dispose();
    _gananciaUnidadController.dispose();
    _gananciaLoteController.dispose();
    super.dispose();
  }

  void _onFieldsChanged() {
    setState(() {
      widget.lote.stock = int.tryParse(_stockController.text) ?? 0;
      widget.lote.danados = int.tryParse(_danadosController.text) ?? 0;

      widget.lote.costoUnitario =
          double.tryParse(_costoUnitarioController.text) ?? 0.0;
      widget.lote.precioVenta =
          double.tryParse(_precioVentaController.text) ?? 0.0;
      widget.lote.impuestoCompra =
          double.tryParse(_impuestoCompraController.text) ?? 0.0;
      widget.lote.impuestoVenta =
          double.tryParse(_impuestoVentaController.text) ?? 0.0;
      widget.lote.unidades = _unidades;

      // Derived calculations
      final calcCostoLote = widget.lote.costoUnitario * widget.lote.stock;
      final calcGananciaUnidad =
          widget.lote.precioVenta - widget.lote.costoUnitario;
      final calcGananciaLote = calcGananciaUnidad * widget.lote.stock;

      if (_costoLoteController.text != calcCostoLote.toStringAsFixed(2)) {
        _costoLoteController.text = calcCostoLote.toStringAsFixed(2);
      }
      if (_gananciaUnidadController.text !=
          calcGananciaUnidad.toStringAsFixed(2)) {
        _gananciaUnidadController.text = calcGananciaUnidad.toStringAsFixed(2);
      }
      if (_gananciaLoteController.text != calcGananciaLote.toStringAsFixed(2)) {
        _gananciaLoteController.text = calcGananciaLote.toStringAsFixed(2);
      }

      widget.lote.costoLote = calcCostoLote;
      widget.lote.gananciaUnidad = calcGananciaUnidad;
      widget.lote.gananciaLote = calcGananciaLote;
    });
    widget.onChanged();
  }

  void _onDerivedFieldsChanged() {
    widget.lote.costoLote =
        double.tryParse(_costoLoteController.text) ?? widget.lote.costoLote;
    widget.lote.gananciaUnidad =
        double.tryParse(_gananciaUnidadController.text) ??
        widget.lote.gananciaUnidad;
    widget.lote.gananciaLote =
        double.tryParse(_gananciaLoteController.text) ??
        widget.lote.gananciaLote;
    widget.onChanged();
  }

  Widget _buildInlineCounterField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            prefixIcon: IconButton(
              icon: const Icon(
                Icons.remove,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: () {
                final val = int.tryParse(controller.text) ?? 0;
                if (val > 0) {
                  controller.text = (val - 1).toString();
                }
              },
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.add,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: () {
                final val = int.tryParse(controller.text) ?? 0;
                controller.text = (val + 1).toString();
              },
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInlineInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 16),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInlineDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final safeOptions = List<String>.from(options);
    if (value.isNotEmpty && !safeOptions.contains(value)) {
      safeOptions.add(value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value.isEmpty && safeOptions.isNotEmpty
              ? safeOptions.first
              : (value.isEmpty ? null : value),
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          items: safeOptions
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInlineDateField({
    required String label,
    required String dateStr,
    ValueChanged<String>? onSelected,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: enabled && onSelected != null
              ? () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    final formatted =
                        "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                    onSelected(formatted);
                  }
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.transparent
                  : AppColors.surfaceContainerLow.withValues(alpha: 0.5),
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 13,
                    color: enabled
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveGainCard({
    required String label,
    required double gainValue,
    required double pctValue,
  }) {
    final isProfit = gainValue > 0;
    final isLoss = gainValue < 0;

    Color textColor;
    Color bgColor;
    IconData icon;
    String signStr = "";

    if (isProfit) {
      textColor = const Color(0xFF10B981); // Emerald green
      bgColor = const Color(0xFFD1FAE5); // Emerald light bg
      icon = Icons.trending_up_rounded;
      signStr = "+";
    } else if (isLoss) {
      textColor = const Color(0xFFEF4444); // Red
      bgColor = const Color(0xFFFEE2E2); // Red light bg
      icon = Icons.trending_down_rounded;
    } else {
      textColor = AppColors.onSurfaceVariant;
      bgColor = AppColors.surfaceContainerLow;
      icon = Icons.trending_flat_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: textColor, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text(
                      "L. ${gainValue.toStringAsFixed(2)}",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (gainValue != 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        "$signStr${pctValue.toStringAsFixed(1)}%",
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasStock = widget.lote.stock > 0;

    // Calcular ganancias y porcentajes dinámicos para los indicadores interactivos
    final stockVal = int.tryParse(_stockController.text) ?? 0;
    final costoUnitVal = double.tryParse(_costoUnitarioController.text) ?? 0.0;
    final precioVentaVal = double.tryParse(_precioVentaController.text) ?? 0.0;
    final gainUnidadVal = precioVentaVal - costoUnitVal;
    final gainLoteVal = gainUnidadVal * stockVal;
    final pctVal = costoUnitVal > 0
        ? (gainUnidadVal / costoUnitVal) * 100
        : 0.0;
    final statusColor = hasStock
        ? const Color(0xFF10B981)
        : const Color(0xFFBA1A1A);
    final statusBg = hasStock
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFEE2E2);
    final statusText = hasStock ? "Disponible" : "Agotado";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: widget.isActiveLot
            ? AppColors.primary.withValues(alpha: 0.02)
            : Colors.transparent,
        border: Border.all(
          color: widget.isActiveLot
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isActiveLot
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.layers_outlined,
                      size: 20,
                      color: widget.isActiveLot
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "Lote: ${widget.lote.id}",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Ingreso: ${widget.lote.fechaIngreso}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isActiveLot)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "FIFO Activo",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "${widget.lote.stock}",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.lote.unidades,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.8,
                    children: [
                      // 1. Cantidad (móvil)
                      _buildInlineCounterField(
                        label: "Cantidad",
                        controller: _stockController,
                      ),
                      // 2. Unidades (móvil)
                      _buildInlineDropdownField(
                        label: "Unidades",
                        value: widget.units.contains(_unidades)
                            ? _unidades
                            : (widget.units.isNotEmpty
                                  ? widget.units.first
                                  : _unidades),
                        options: widget.units,
                        onChanged: (val) {
                          if (val != null) {
                            _unidades = val;
                            _onFieldsChanged();
                          }
                        },
                      ),
                      // 3. Costo Lote
                      _buildInlineInputField(
                        label: "Precio Costo Lote",
                        controller: _costoLoteController,
                        icon: Icons.calculate_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      // 4. Costo unitario
                      _buildInlineInputField(
                        label: "Costo Unitario",
                        controller: _costoUnitarioController,
                        icon: Icons.payments_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      // 5. Impuesto compra
                      _buildInlineInputField(
                        label: "Impuesto Compra %",
                        controller: _impuestoCompraController,
                        icon: Icons.receipt_long_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      // 6. Impuesto venta
                      _buildInlineInputField(
                        label: "Impuesto Venta %",
                        controller: _impuestoVentaController,
                        icon: Icons.receipt_long_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      // 7. Precio Venta
                      _buildInlineInputField(
                        label: "Precio Venta",
                        controller: _precioVentaController,
                        icon: Icons.sell_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      // 8. Fecha Vencimiento
                      _buildInlineDateField(
                        label: "Fecha Vencimiento",
                        dateStr: widget.lote.fechaVencimiento,
                        onSelected: (val) {
                          setState(() {
                            widget.lote.fechaVencimiento = val;
                          });
                          _onFieldsChanged();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInteractiveGainCard(
                          label: "Ganancia Unidad",
                          gainValue: gainUnidadVal,
                          pctValue: pctVal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInteractiveGainCard(
                          label: "Ganancia Lote",
                          gainValue: gainLoteVal,
                          pctValue: pctVal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AddLoteDialog extends StatefulWidget {
  final ProductItem product;
  final List<String> units;

  const _AddLoteDialog({required this.product, required this.units});

  @override
  State<_AddLoteDialog> createState() => _AddLoteDialogState();
}

class _AddLoteDialogState extends State<_AddLoteDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idController;
  final _stockController = TextEditingController(text: "1");

  final _costoUnitarioController = TextEditingController(text: "0.00");
  final _precioVentaController = TextEditingController(text: "0.00");
  final _impuestoCompraController = TextEditingController(text: "15");
  final _impuestoVentaController = TextEditingController(text: "15");

  String _unidades = "Unid";
  String _fechaIngreso = "";
  String _fechaVencimiento = "28-02-2027";

  final _costoLoteController = TextEditingController(text: "0.00");
  final _gananciaUnidadController = TextEditingController(text: "0.00");
  final _gananciaLoteController = TextEditingController(text: "0.00");

  @override
  void initState() {
    super.initState();
    if (widget.units.isNotEmpty) {
      _unidades = widget.units.contains("Unid") ? "Unid" : widget.units.first;
    }
    final randomDigits = 1000 + (DateTime.now().millisecond % 9000);
    _idController = TextEditingController(text: "L-$randomDigits");

    final today = DateTime.now();
    _fechaIngreso =
        "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}";

    _stockController.addListener(_calculateCostsAndGains);
    _costoUnitarioController.addListener(_calculateCostsAndGains);
    _precioVentaController.addListener(_calculateCostsAndGains);
    _calculateCostsAndGains();
  }

  @override
  void dispose() {
    _idController.dispose();
    _stockController.dispose();

    _costoUnitarioController.dispose();
    _precioVentaController.dispose();
    _impuestoCompraController.dispose();
    _impuestoVentaController.dispose();

    _costoLoteController.dispose();
    _gananciaUnidadController.dispose();
    _gananciaLoteController.dispose();

    super.dispose();
  }

  void _calculateCostsAndGains() {
    final stock = int.tryParse(_stockController.text) ?? 0;
    final costoUnitario = double.tryParse(_costoUnitarioController.text) ?? 0.0;
    final precioVenta = double.tryParse(_precioVentaController.text) ?? 0.0;

    final cLote = costoUnitario * stock;
    final gUnidad = precioVenta - costoUnitario;
    final gLote = gUnidad * stock;

    if (_costoLoteController.text != cLote.toStringAsFixed(2)) {
      _costoLoteController.text = cLote.toStringAsFixed(2);
    }
    if (_gananciaUnidadController.text != gUnidad.toStringAsFixed(2)) {
      _gananciaUnidadController.text = gUnidad.toStringAsFixed(2);
    }
    if (_gananciaLoteController.text != gLote.toStringAsFixed(2)) {
      _gananciaLoteController.text = gLote.toStringAsFixed(2);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildCounterTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: validator,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        prefixIcon: IconButton(
          icon: const Icon(
            Icons.remove,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: () {
            final val = int.tryParse(controller.text) ?? 0;
            if (val > 1) {
              controller.text = (val - 1).toString();
            }
          },
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.add,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: () {
            final val = int.tryParse(controller.text) ?? 0;
            controller.text = (val + 1).toString();
          },
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String dateStr,
    required ValueChanged<String> onSelected,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) {
          final formatted =
              "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
          onSelected(formatted);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateStr, style: const TextStyle(fontSize: 13)),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Registrar Nuevo Lote",
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.onSurface,
        ),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _idController,
                        label: "ID Lote",
                        hint: "Ej. L-8014",
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? "Requerido"
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCounterTextField(
                        controller: _stockController,
                        label: "Cantidad Stock",
                        hint: "1",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final initVal = widget.units.contains(_unidades)
                              ? _unidades
                              : (widget.units.isNotEmpty
                                    ? widget.units.first
                                    : "Unid");
                          final safeUnits = List<String>.from(widget.units);
                          if (!safeUnits.contains(initVal)) {
                            safeUnits.add(initVal);
                          }
                          return DropdownButtonFormField<String>(
                            initialValue: initVal,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurface,
                            ),
                            decoration: const InputDecoration(
                              labelText: "Unidades",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            items: safeUnits
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt,
                                    child: Text(opt),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _unidades = val;
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _costoUnitarioController,
                        label: "Costo Unitario (L.)",
                        hint: "0.00",
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _precioVentaController,
                        label: "Precio de Venta (L.)",
                        hint: "0.00",
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: "Fecha Ingreso",
                        dateStr: _fechaIngreso,
                        onSelected: (val) =>
                            setState(() => _fechaIngreso = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(
                        label: "Fecha Vencimiento",
                        dateStr: _fechaVencimiento,
                        onSelected: (val) =>
                            setState(() => _fechaVencimiento = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _costoLoteController,
                        label: "Costo Lote",
                        hint: "0.00",
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: _gananciaUnidadController,
                        label: "Ganancia/Unidad",
                        hint: "0.00",
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: _gananciaLoteController,
                        label: "Ganancia Lote",
                        hint: "0.00",
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
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
            if (_formKey.currentState?.validate() ?? false) {
              final newLote = LoteItem(
                id: _idController.text.trim(),
                stock: int.tryParse(_stockController.text) ?? 0,
                fechaIngreso: _fechaIngreso,
                fechaVencimiento: _fechaVencimiento,
                unidades: _unidades,
                costoLote: double.tryParse(_costoLoteController.text) ?? 0.0,
                costoUnitario:
                    double.tryParse(_costoUnitarioController.text) ?? 0.0,
                precioVenta:
                    double.tryParse(_precioVentaController.text) ?? 0.0,
                impuestoCompra:
                    double.tryParse(_impuestoCompraController.text) ?? 15.0,
                impuestoVenta:
                    double.tryParse(_impuestoVentaController.text) ?? 15.0,
                gananciaUnidad:
                    double.tryParse(_gananciaUnidadController.text) ?? 0.0,
                gananciaLote:
                    double.tryParse(_gananciaLoteController.text) ?? 0.0,
              );
              Navigator.pop(context, newLote);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text("Registrar"),
        ),
      ],
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> providers;

  const _AddProductDialog({required this.categories, required this.providers});

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _skuController = TextEditingController();
  final _minStockController = TextEditingController(text: "1");

  String _category = "";
  String _provider = "";
  String _productType = "Normal";

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _category = widget.categories.first;
    }
    if (widget.providers.isNotEmpty) {
      _provider = widget.providers.first;
    }
    final randomVal = 100000 + (DateTime.now().millisecond % 900000);
    _skuController.text = "ART-$randomVal";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _skuController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Registrar Nuevo Artículo",
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.onSurface,
        ),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nameController,
                        label: "Nombre del Artículo",
                        hint: "Ej. Studio Pro Wireless",
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? "Requerido"
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _subtitleController,
                        label: "Descripción / Subtítulo",
                        hint: "Ej. Over-ear active noise cancelling",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _skuController,
                        label: "Código de Barra / SKU",
                        hint: "Ej. ART-123456",
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? "Requerido"
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _minStockController,
                        label: "Stock Mínimo",
                        hint: "1",
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Requerido";
                          }
                          if (int.tryParse(value) == null) {
                            return "Número inválido";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _category.isEmpty ? null : _category,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _category = val);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Categoría",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: widget.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _provider.isEmpty ? null : _provider,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _provider = val);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Proveedor",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: widget.providers.map((prov) {
                          return DropdownMenuItem(
                            value: prov,
                            child: Text(
                              prov,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6.0),
                            child: Text(
                              "Tipo de Producto",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment<String>(
                                  value: "Normal",
                                  label: Text(
                                    "Normal",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  icon: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 16,
                                  ),
                                ),
                                ButtonSegment<String>(
                                  value: "Pesado",
                                  label: Text(
                                    "Pesado",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  icon: Icon(Icons.scale_rounded, size: 16),
                                ),
                              ],
                              selected: {_productType},
                              onSelectionChanged: (newSel) {
                                setState(() => _productType = newSel.first);
                              },
                              showSelectedIcon: false,
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                                side: const WidgetStatePropertyAll(
                                  BorderSide(
                                    color: AppColors.outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
            if (_formKey.currentState?.validate() ?? false) {
              final today = DateTime.now();
              final dateStr =
                  "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year.toString().substring(2)}";
              final newProduct = ProductItem(
                name: _nameController.text.trim(),
                subtitle: _subtitleController.text.trim(),
                sku: _skuController.text.trim(),
                category: _category,
                stock: 0,
                maxStock: 100,
                price: 0.00,
                imageUrl: "",
                lotes: [],
                provider: _provider,
                minStock: int.tryParse(_minStockController.text) ?? 1,
                productType: _productType,
                dateEntered: dateStr,
              );
              Navigator.pop(context, newProduct);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text("Registrar"),
        ),
      ],
    );
  }
}
