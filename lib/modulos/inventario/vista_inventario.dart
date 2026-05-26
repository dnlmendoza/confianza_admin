import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:confianza_admin/modulos/inventario/viewmodel_inventario.dart';

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

  // Dynamic lists for catalogs
  final List<String> _categories = [
    "Electrónica",
    "Periféricos",
    "Monitores",
    "Mobiliario",
  ];
  final List<String> _providers = [
    "TechSource Inc.",
    "Global Logistics",
    "Bodega",
  ];
  final List<String> _units = [
    "Unid",
    "Caja",
    "Paquete",
    "Libra",
    "Kg",
    "Litro",
    "Docena",
  ];

  // Lista base del inventario
  final List<ProductItem> _products = [
    ProductItem(
      name: "Studio Pro Wireless",
      subtitle: "Over-ear active noise cancelling",
      sku: "STP-882-BLU",
      category: "Electrónica",
      stock: 156,
      maxStock: 200,
      price: 299.00,
      imageUrl:
          "https://lh3.googleusercontent.com/aida/ADBb0uhDGSJL6EQq__ES4O2BHuQPLhIu-v_4g9dOUZIK7_T_C3IqAudQPDnEnlH7hHQzst4S2rPl3Mts12ht5Y-_SbdPQUu1ub7GUcjjeYWFhomHxPINBqpxAJBKO90Kswd3b-3rivbPXBAgoRs_1GjMw7pxg8GwrO_1Xbaj96ZaNyENfufKBpOtyMNO8himPTyt-B8P8C6IoXm4_AFO45XaoFL_OjYQdCZP053oRa4BQhctwEdru2Sq18tQtzpUlRRrtCpnf1nIIrF_",
      lotes: [
        LoteItem(
          id: "L-8012",
          stock: 80,
          fechaIngreso: "12-04-2026",
          ubicacion: "Estante A1",
        ),
        LoteItem(
          id: "L-8013",
          stock: 76,
          fechaIngreso: "28-04-2026",
          ubicacion: "Estante A2",
        ),
      ],
    ),
    ProductItem(
      name: "Mechanic K1 Keyboard",
      subtitle: "RGB Backlit Mechanical Switches",
      sku: "MK-K1-744",
      category: "Periféricos",
      stock: 12,
      maxStock: 100,
      price: 149.50,
      imageUrl:
          "https://lh3.googleusercontent.com/aida/ADBb0uie9aXo1SLfhg9oUGqFi4nj1R8WsE7bT8hS8vdtDW1ECX8pNL-Rs-qEps1ft0cRqFODMqLGSDXutWEiHblqTxlePbkM7J1ag0U1jYhlT6NzJ91Um7oobtKxw1OsJxhJQ_7_9VfA-LFK1hQHzAgQy9y6yiGGW1MGZGnFnws73dmYfLqbK30MdXcUhAZ1WGfR1gUjpbzN19DA1IAVrbZN_jgFGMYwIMofXIqznfNk3_ib9SomYPmsyKJkn1iqRjorMszaPyTriM1KZQ",
      lotes: [
        LoteItem(
          id: "L-5021",
          stock: 12,
          fechaIngreso: "05-05-2026",
          ubicacion: "Estante B1",
        ),
      ],
    ),
    ProductItem(
      name: "UltraWide 34\" Display",
      subtitle: "IPS Panel 144Hz HDR400",
      sku: "UW-34-DSPL",
      category: "Monitores",
      stock: 45,
      maxStock: 100,
      price: 599.99,
      imageUrl:
          "https://lh3.googleusercontent.com/aida/ADBb0uh4Tj2eAXE_OWkZULpzK2h_Q8kPH-6MKNSC3wbUiSjuIeQFgke68asTEoP-OwydyJR-vHaoOza7-NbITPCUY5rVOcE1mVdRPQtX9q0SG1qsAzcLthOhHL7RXQrKwN5MUn190NZySmD45LzmuuocLrnRLtLizsFeVJg17xPdRcoksECY2NRTFBwqGF1qSGBRE0u6S_sNW2K1Y2G-WbYFAKgssRVf1iBWY9t6Y0HlbB1OPEA5Hd3iBoWqR_H4Vf3RS36pKAheDSSlQg",
      lotes: [
        LoteItem(
          id: "L-1090",
          stock: 30,
          fechaIngreso: "20-04-2026",
          ubicacion: "Estante C1",
        ),
        LoteItem(
          id: "L-1091",
          stock: 15,
          fechaIngreso: "10-05-2026",
          ubicacion: "Estante C2",
        ),
      ],
    ),
    ProductItem(
      name: "ErgoChair X-series",
      subtitle: "Breathable mesh with lumbar support",
      sku: "CH-ERG-881",
      category: "Mobiliario",
      stock: 210,
      maxStock: 250,
      price: 425.00,
      imageUrl:
          "https://lh3.googleusercontent.com/aida/ADBb0uj8I9f53CpSj40cca_fxt6KDo57B4z5FBtDqrwX6YOaNbbsU1WX7mEhu5cunyifZXLih2dswdROV7dw0Js73dJ6-qs5F2VgSeZBUVN4YFIaVu_oLsBL2c-rstYiGoQhE-uY0TM2gcuR09ryDxDAHAGOxRwKRDsshuF-3NnsAIx7hHyVwi16RaRRLlSy9jG1gnABu5nQv53OELiPWAR5XPkb_VxkSsTmeuvRyhFfaZfhzRVU6MflDLaPguo-x9gcLMgro1_ligRf5Q",
      lotes: [
        LoteItem(
          id: "L-3033",
          stock: 110,
          fechaIngreso: "01-04-2026",
          ubicacion: "Pasillo D",
        ),
        LoteItem(
          id: "L-3034",
          stock: 100,
          fechaIngreso: "15-04-2026",
          ubicacion: "Pasillo D",
        ),
      ],
    ),
  ];

  ProductItem? _selectedProduct;
  bool _isDetailsExpanded = false;

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
    if (_products.isNotEmpty) {
      _selectedProduct = _products.first;
    }
    _nameEditController = TextEditingController(
      text: _selectedProduct?.name ?? "",
    );
    _subtitleEditController = TextEditingController(
      text: _selectedProduct?.subtitle ?? "",
    );
    _skuEditController = TextEditingController(
      text: _selectedProduct?.sku ?? "",
    );
    _categoryEditController = TextEditingController(
      text: _selectedProduct?.category ?? "",
    );
    _minStockEditController = TextEditingController(
      text: _selectedProduct?.minStock.toString() ?? "1",
    );
    _providerEditController = TextEditingController(
      text: _selectedProduct?.provider ?? "Bodega",
    );
    _productTypeEditController = TextEditingController(
      text: _selectedProduct?.productType ?? "Normal",
    );
    _dateEnteredEditController = TextEditingController(
      text: _selectedProduct?.dateEntered ?? "19-05-26",
    );

    _nameEditController.addListener(_onFormChanged);
    _subtitleEditController.addListener(_onFormChanged);
    _skuEditController.addListener(_onFormChanged);
    _categoryEditController.addListener(_onFormChanged);
    _minStockEditController.addListener(_onFormChanged);
    _providerEditController.addListener(_onFormChanged);
    _productTypeEditController.addListener(_onFormChanged);
    _dateEnteredEditController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    return _products.fold(0, (sum, item) {
      final activeLot = _getActiveLot(item);
      return sum + (activeLot?.stock ?? 0);
    });
  }

  int get _lowStockCount {
    return _products.where((item) {
      final activeLot = _getActiveLot(item);
      return (activeLot?.stock ?? 0) < 20;
    }).length;
  }

  double get _totalValue {
    return _products.fold(0.0, (sum, item) {
      final activeLot = _getActiveLot(item);
      final price = activeLot?.precioVenta ?? item.price;
      final stock = activeLot?.stock ?? 0;
      return sum + (price * stock);
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

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isActive = _activeTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isActive ? Colors.white : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopWidth = MediaQuery.of(context).size.width >= 1024;

    return AdminLayout(
      activeRoute: '/inventario',
      title: 'Inventario',
      centerWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton(
            0,
            "Gestión de Inventario (PEPS / FIFO)",
            Icons.inventory_2_outlined,
          ),
          const SizedBox(width: 12),
          _buildTabButton(
            1,
            "Mantenimiento de Catálogos",
            Icons.settings_outlined,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección superior fija: KPIs + controles de tabla
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBentoGrid(context),
                const SizedBox(height: 28),

                // Navigation Tabs (Mobile Only fallback)
                if (!isDesktopWidth) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          0,
                          "Gestión de Inventario",
                          Icons.inventory_2_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTabButton(
                          1,
                          "Catálogos",
                          Icons.settings_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

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
              child: SingleChildScrollView(
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
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1100;

    int crossAxisCount = 4;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isMobile ? 3.0 : 1.9,
      children: [
        _buildKpiCard(
          title: "Stock Total",
          value: _totalStock.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => "${m[1]},",
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              "+2.4%",
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _buildKpiCard(
          title: "Bajo Stock",
          value: _lowStockCount.toString(),
          valueColor: const Color(0xFFBA1A1A),
          trailing: const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFBA1A1A),
            size: 24,
          ),
        ),
        _buildKpiCard(
          title: "Valor Inventario",
          value: "L. ${(_totalValue / 1000).toStringAsFixed(1)}k",
          trailing: const Icon(
            Icons.payments_outlined,
            color: AppColors.onSurfaceVariant,
            size: 24,
          ),
        ),
        _buildKpiCard(
          title: "Categorías",
          value: _uniqueCategories.toString(),
          trailing: const Icon(
            Icons.category_outlined,
            color: AppColors.onSurfaceVariant,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    Color valueColor = AppColors.onSurface,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              trailing,
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
          // Tabla con scroll vertical
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(5), // Nombre del Item
                  1: FlexColumnWidth(2), // SKU
                  2: FlexColumnWidth(2), // Categoría
                },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                        ),
                        children: [
                          _buildTableHeaderCell("NOMBRE DEL ITEM"),
                          _buildTableHeaderCell("SKU / BARCODE"),
                          _buildTableHeaderCell("CATEGORÍA"),
                        ],
                      ),
                      if (filtered.isEmpty)
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                ),
                                alignment: Alignment.center,
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 48,
                                      color: AppColors.outlineVariant,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "No se encontraron productos coincidentes",
                                      style: TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(),
                            const SizedBox(),
                          ],
                        )
                      else
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
                              // Nombre del Item + Subtítulo
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => _selectProduct(item),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
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
                              // SKU / BARCODE
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => _selectProduct(item),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      item.sku,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Categoría Badge
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => _selectProduct(item),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: IntrinsicWidth(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          item.category.toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
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

  Widget _buildTableHeaderCell(String label, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Text(
        label,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
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
        side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
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
                      child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      )
                    ],
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      label: "Categoría",
                      controller: _categoryEditController,
                      visible: true,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      label: "Proveedor",
                      controller: _providerEditController,
                      visible: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
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
                    child: _buildFormField(
                      label: "Tipo de Producto",
                      controller: _productTypeEditController,
                      visible: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      label: "Fecha Ingresado",
                      controller: _dateEnteredEditController,
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


  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required bool visible,
    int maxLines = 1,
  }) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 4.0),
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
            decoration: InputDecoration(
              isDense: true,
              hintText: "Ingrese $label",
              hintStyle: const TextStyle(color: AppColors.outlineVariant, fontSize: 13),
              filled: true,
              fillColor: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
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
                                .fold(0, (sum, lot) => sum + lot.stock);
                          });
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
                            "Control de todos los lotes ingresados para este artículo.",
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
          (sum, lot) => sum + lot.stock,
        );
      });
    }
  }


  void _renameCategory(String oldCat, String newCat) {
    setState(() {
      final index = _categories.indexOf(oldCat);
      if (index != -1) {
        _categories[index] = newCat;
      }
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
    setState(() {
      _categories.remove(cat);
      final fallback = _categories.isNotEmpty ? _categories.first : "General";
      if (_categories.isEmpty) {
        _categories.add("General");
      }
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
    setState(() {
      final index = _providers.indexOf(oldProv);
      if (index != -1) {
        _providers[index] = newProv;
      }
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
    setState(() {
      _providers.remove(prov);
      final fallback = _providers.isNotEmpty ? _providers.first : "Bodega";
      if (_providers.isEmpty) {
        _providers.add("Bodega");
      }
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
    setState(() {
      final index = _units.indexOf(oldUnit);
      if (index != -1) {
        _units[index] = newUnit;
      }
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
    setState(() {
      _units.remove(unit);
      final fallback = _units.isNotEmpty ? _units.first : "Unid";
      if (_units.isEmpty) {
        _units.add("Unid");
      }
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

  Widget _buildCatalogMaintenance(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    final childWidgets = [
      _CatalogMaintenanceCard(
        title: "Categorías",
        items: _categories,
        icon: Icons.category_outlined,
        onAdd: (newVal) {
          if (newVal.isNotEmpty && !_categories.contains(newVal)) {
            setState(() => _categories.add(newVal));
          }
        },
        onRename: (oldVal, newVal) => _renameCategory(oldVal, newVal),
        onDelete: (val) => _deleteCategory(val),
      ),
      _CatalogMaintenanceCard(
        title: "Proveedores",
        items: _providers,
        icon: Icons.local_shipping_outlined,
        onAdd: (newVal) {
          if (newVal.isNotEmpty && !_providers.contains(newVal)) {
            setState(() => _providers.add(newVal));
          }
        },
        onRename: (oldVal, newVal) => _renameProvider(oldVal, newVal),
        onDelete: (val) => _deleteProvider(val),
      ),
      _CatalogMaintenanceCard(
        title: "Unidades de Medida",
        items: _units,
        icon: Icons.square_foot_outlined,
        onAdd: (newVal) {
          if (newVal.isNotEmpty && !_units.contains(newVal)) {
            setState(() => _units.add(newVal));
          }
        },
        onRename: (oldVal, newVal) => _renameUnit(oldVal, newVal),
        onDelete: (val) => _deleteUnit(val),
      ),
    ];

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: childWidgets
            .map(
              (w) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: w,
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Column(
        children: childWidgets
            .map(
              (w) =>
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: w),
            )
            .toList(),
      );
    }
  }
}

class _CatalogMaintenanceCard extends StatefulWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String> onAdd;
  final Function(String, String) onRename;
  final ValueChanged<String> onDelete;

  const _CatalogMaintenanceCard({
    required this.title,
    required this.items,
    required this.icon,
    required this.onAdd,
    required this.onRename,
    required this.onDelete,
  });

  @override
  State<_CatalogMaintenanceCard> createState() =>
      _CatalogMaintenanceCardState();
}

class _CatalogMaintenanceCardState extends State<_CatalogMaintenanceCard> {
  final TextEditingController _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Title and Icon
            Row(
              children: [
                Icon(widget.icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  "${widget.title} (${widget.items.length})",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add Input Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _addController,
                    decoration: const InputDecoration(
                      hintText: "Nueva...",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (text) {
                      final val = text.trim();
                      if (val.isNotEmpty) {
                        widget.onAdd(val);
                        _addController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final text = _addController.text.trim();
                    if (text.isNotEmpty) {
                      widget.onAdd(text);
                      _addController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.add, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scrollable List of items
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: widget.items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        "No hay elementos",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      separatorBuilder: (context, index) => Divider(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      ),
                      itemBuilder: (context, index) {
                        final val = widget.items[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            val,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurface,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => _showRenameCatalogDialog(
                                  context,
                                  widget.title,
                                  val,
                                  widget.onRename,
                                ),
                                tooltip: "Renombrar",
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Color(0xFFBA1A1A),
                                ),
                                onPressed: () =>
                                    _showConfirmDeleteCatalogDialog(
                                      context,
                                      widget.title,
                                      val,
                                      widget.onDelete,
                                    ),
                                tooltip: "Eliminar",
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameCatalogDialog(
    BuildContext context,
    String catalogTitle,
    String oldValue,
    Function(String, String) onRename,
  ) {
    final renameController = TextEditingController(text: oldValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Renombrar en $catalogTitle",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.onSurface,
            ),
          ),
          content: TextField(
            controller: renameController,
            decoration: const InputDecoration(
              labelText: "Nuevo Nombre",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = renameController.text.trim();
                if (newValue.isNotEmpty && newValue != oldValue) {
                  onRename(oldValue, newValue);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Renombrar"),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDeleteCatalogDialog(
    BuildContext context,
    String catalogTitle,
    String value,
    ValueChanged<String> onDelete,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Eliminar de $catalogTitle",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.onSurface,
            ),
          ),
          content: Text(
            "¿Está seguro de que desea eliminar '$value'? Si hay productos o lotes utilizándolo, se reasignarán automáticamente.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                onDelete(value);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA1A1A),
                foregroundColor: Colors.white,
              ),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
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
  }

  @override
  void dispose() {
    _stockController.dispose();
    _danadosController.dispose();

    _costoUnitarioController.dispose();
    _precioVentaController.dispose();
    _impuestoCompraController.dispose();
    _impuestoVentaController.dispose();
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
      widget.lote.costoLote = widget.lote.costoUnitario * widget.lote.stock;
      widget.lote.gananciaUnidad =
          widget.lote.precioVenta - widget.lote.costoUnitario;
      widget.lote.gananciaLote = widget.lote.gananciaUnidad * widget.lote.stock;
    });
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 16),
              onPressed: () {
                int val = int.tryParse(controller.text) ?? 0;
                if (val > 0) {
                  controller.text = (val - 1).toString();
                }
              },
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 16),
              onPressed: () {
                int val = int.tryParse(controller.text) ?? 0;
                controller.text = (val + 1).toString();
              },
            ),
          ],
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
            fontSize: 12,
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
            border: const OutlineInputBorder(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
            border: OutlineInputBorder(),
          ),
          items: options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInlineDateField({
    required String label,
    required String dateStr,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: const TextStyle(fontSize: 13)),
                const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasStock = widget.lote.stock > 0;
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
          ListTile(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            leading: Icon(
              Icons.layers_outlined,
              color: widget.isActiveLot
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            title: Row(
              children: [
                Text(
                  widget.lote.id,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                if (widget.isActiveLot)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
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
              ],
            ),
            subtitle: Text(
              "Ingreso: ${widget.lote.fechaIngreso}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${widget.lote.stock} ${widget.lote.unidades}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
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
                      // 3. Fecha ingreso
                      _buildInlineDateField(
                        label: "Fecha Ingreso",
                        dateStr: widget.lote.fechaIngreso,
                        onSelected: (val) {
                          setState(() {
                            widget.lote.fechaIngreso = val;
                          });
                          _onFieldsChanged();
                        },
                      ),
                      // 4. Costo Lote (calculado)
                      _buildFinanceItem(
                        "Costo Lote",
                        "L. ${widget.lote.costoLote.toStringAsFixed(2)}",
                      ),
                      // 5. Costo unitario (móvil)
                      _buildInlineInputField(
                        label: "Costo Unitario",
                        controller: _costoUnitarioController,
                        icon: Icons.payments_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      // 6. Impuesto compra
                      _buildInlineInputField(
                        label: "Impuesto Compra %",
                        controller: _impuestoCompraController,
                        icon: Icons.receipt_long_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      // 7. Precio venta (móvil)
                      _buildInlineInputField(
                        label: "Precio Venta",
                        controller: _precioVentaController,
                        icon: Icons.sell_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      // 8. Impuesto venta
                      _buildInlineInputField(
                        label: "Impuesto Venta %",
                        controller: _impuestoVentaController,
                        icon: Icons.receipt_long_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      // 9. Ganancia Unidad (calculado)
                      _buildFinanceItem(
                        "Ganancia Unidad",
                        "L. ${widget.lote.gananciaUnidad.toStringAsFixed(2)}",
                      ),
                      // 10. Ganancia Lote (calculado)
                      _buildFinanceItem(
                        "Ganancia Lote",
                        "L. ${widget.lote.gananciaLote.toStringAsFixed(2)}",
                      ),
                      // 11. Fecha vencimiento
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
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinanceItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
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

  double _costoLote = 0.0;
  double _gananciaUnidad = 0.0;
  double _gananciaLote = 0.0;

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
    super.dispose();
  }

  void _calculateCostsAndGains() {
    final stock = int.tryParse(_stockController.text) ?? 0;
    final costoUnitario = double.tryParse(_costoUnitarioController.text) ?? 0.0;
    final precioVenta = double.tryParse(_precioVentaController.text) ?? 0.0;

    setState(() {
      _costoLote = costoUnitario * stock;
      _gananciaUnidad = precioVenta - costoUnitario;
      _gananciaLote = _gananciaUnidad * stock;
    });
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
        border: const OutlineInputBorder(),
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
          border: const OutlineInputBorder(),
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
                      child: _buildTextField(
                        controller: _stockController,
                        label: "Cantidad Stock",
                        hint: "1",
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: widget.units.contains(_unidades)
                            ? _unidades
                            : (widget.units.isNotEmpty
                                  ? widget.units.first
                                  : "Unid"),
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
                        items: widget.units
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
                    _buildFinanceItem(
                      "Costo Lote",
                      "L. ${_costoLote.toStringAsFixed(2)}",
                    ),
                    _buildFinanceItem(
                      "Ganancia/Unidad",
                      "L. ${_gananciaUnidad.toStringAsFixed(2)}",
                    ),
                    _buildFinanceItem(
                      "Ganancia Lote",
                      "L. ${_gananciaLote.toStringAsFixed(2)}",
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
                costoLote: _costoLote,
                costoUnitario:
                    double.tryParse(_costoUnitarioController.text) ?? 0.0,
                precioVenta:
                    double.tryParse(_precioVentaController.text) ?? 0.0,
                impuestoCompra:
                    double.tryParse(_impuestoCompraController.text) ?? 15.0,
                impuestoVenta:
                    double.tryParse(_impuestoVentaController.text) ?? 15.0,
                gananciaUnidad: _gananciaUnidad,
                gananciaLote: _gananciaLote,

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

  Widget _buildFinanceItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
