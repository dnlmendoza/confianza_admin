import 'package:flutter/material.dart';
import 'package:confianza_admin/main.dart';

/// Modelo de datos para representar un artículo del inventario de manera interactiva
class ProductItem {
  String name;
  String subtitle;
  String sku;
  String category;
  int stock;
  int maxStock;
  double price;
  String imageUrl;

  ProductItem({
    required this.name,
    required this.subtitle,
    required this.sku,
    required this.category,
    required this.stock,
    required this.maxStock,
    required this.price,
    required this.imageUrl,
  });
}

class VistaInventario extends StatefulWidget {
  const VistaInventario({super.key});

  @override
  State<VistaInventario> createState() => _VistaInventarioState();
}

class _VistaInventarioState extends State<VistaInventario> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Paleta de colores consistente de la marca
  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorPrimaryContainer = Color(0xFF3498db);
  static const Color colorBackground = Color(0xFFF7F9FF);
  static const Color colorOnSurface = Color(0xFF181C20);
  static const Color colorOnSurfaceVariant = Color(0xFF3F4850);
  static const Color colorInverseSurface = Color(0xFF2D3135);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);
  static const Color colorSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color colorSurfaceContainerLow = Color(0xFFF1F4FA);
  static const Color colorSurfaceContainerHigh = Color(0xFFE5E8EE);

  // Controladores y estados reactivos
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "Todas las Categorías";
  String _selectedProvider = "Todos los Proveedores";

  // Lista base del inventario (con los productos exactos de la captura)
  final List<ProductItem> _products = [
    ProductItem(
      name: "Studio Pro Wireless",
      subtitle: "Over-ear active noise cancelling",
      sku: "STP-882-BLU",
      category: "Electrónica",
      stock: 156,
      maxStock: 200,
      price: 299.00,
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uhDGSJL6EQq__ES4O2BHuQPLhIu-v_4g9dOUZIK7_T_C3IqAudQPDnEnlH7hHQzst4S2rPl3Mts12ht5Y-_SbdPQUu1ub7GUcjjeYWFhomHxPINBqpxAJBKO90Kswd3b-3rivbPXBAgoRs_1GjMw7pxg8GwrO_1Xbaj96ZaNyENfufKBpOtyMNO8himPTyt-B8P8C6IoXm4_AFO45XaoFL_OjYQdCZP053oRa4BQhctwEdru2Sq18tQtzpUlRRrtCpnf1nIIrF_",
    ),
    ProductItem(
      name: "Mechanic K1 Keyboard",
      subtitle: "RGB Backlit Mechanical Switches",
      sku: "MK-K1-744",
      category: "Periféricos",
      stock: 12,
      maxStock: 100,
      price: 149.50,
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uie9aXo1SLfhg9oUGqFi4nj1R8WsE7bT8hS8vdtDW1ECX8pNL-Rs-qEps1ft0cRqFODMqLGSDXutWEiHblqTxlePbkM7J1ag0U1jYhlT6NzJ91Um7oobtKxw1OsJxhJQ_7_9VfA-LFK1hQHzAgQy9y6yiGGW1MGZGnFnws73dmYfLqbK30MdXcUhAZ1WGfR1gUjpbzN19DA1IAVrbZN_jgFGMYwIMofXIqznfNk3_ib9SomYPmsyKJkn1iqRjorMszaPyTriM1KZQ",
    ),
    ProductItem(
      name: "UltraWide 34\" Display",
      subtitle: "IPS Panel 144Hz HDR400",
      sku: "UW-34-DSPL",
      category: "Monitores",
      stock: 45,
      maxStock: 100,
      price: 599.99,
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uh4Tj2eAXE_OWkZULpzK2h_Q8kPH-6MKNSC3wbUiSjuIeQFgke68asTEoP-OwydyJR-vHaoOza7-NbITPCUY5rVOcE1mVdRPQtX9q0SG1qsAzcLthOhHL7RXQrKwN5MUn190NZySmD45LzmuuocLrnRLtLizsFeVJg17xPdRcoksECY2NRTFBwqGF1qSGBRE0u6S_sNW2K1Y2G-WbYFAKgssRVf1iBWY9t6Y0HlbB1OPEA5Hd3iBoWqR_H4Vf3RS36pKAheDSSlQg",
    ),
    ProductItem(
      name: "ErgoChair X-series",
      subtitle: "Breathable mesh with lumbar support",
      sku: "CH-ERG-881",
      category: "Mobiliario",
      stock: 210,
      maxStock: 250,
      price: 425.00,
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uj8I9f53CpSj40cca_fxt6KDo57B4z5FBtDqrwX6YOaNbbsU1WX7mEhu5cunyifZXLih2dswdROV7dw0Js73dJ6-qs5F2VgSeZBUVN4YFIaVu_oLsBL2c-rstYiGoQhE-uY0TM2gcuR09ryDxDAHAGOxRwKRDsshuF-3NnsAIx7hHyVwi16RaRRLlSy9jG1gnABu5nQv53OELiPWAR5XPkb_VxkSsTmeuvRyhFfaZfhzRVU6MflDLaPguo-x9gcLMgro1_ligRf5Q",
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtrado reactivo de productos basado en búsqueda y dropdowns
  List<ProductItem> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((item) {
      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == "Todas las Categorías" ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // KPI calculations
  int get _totalStock => _products.fold(0, (sum, item) => sum + item.stock);
  int get _lowStockCount => _products.where((item) => item.stock < 20).length;
  double get _totalValue => _products.fold(0.0, (sum, item) => sum + (item.price * item.stock));
  int get _uniqueCategories => _products.map((item) => item.category).toSet().length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorBackground,
      drawer: Drawer(
        child: Container(
          color: colorInverseSurface,
          child: const _SidebarContent(isDrawer: true),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra Lateral (Sidebar) fija en pantallas grandes
              if (isDesktop)
                SizedBox(
                  width: SidebarState.isCollapsed ? 76 : 260,
                  child: Container(
                    color: colorInverseSurface,
                    child: _SidebarContent(
                      isDrawer: false,
                      onToggleCollapse: () {
                        setState(() {
                          SidebarState.isCollapsed = !SidebarState.isCollapsed;
                        });
                      },
                    ),
                  ),
                ),

              // Área de Contenido Principal
              Expanded(
                child: Column(
                  children: [
                    // Cabecera superior
                    _Header(
                      scaffoldKey: _scaffoldKey,
                      isDesktop: isDesktop,
                      searchController: _searchController,
                      onSearchChanged: (val) {
                        setState(() {});
                      },
                    ),

                    // Cuerpo de Inventario con Scroll
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bento-Grid de Tarjetas KPI
                            _buildBentoGrid(context),
                            const SizedBox(height: 28),

                            // Controles de Filtrado e Inserción de Artículos
                            _buildTableControls(context),
                            const SizedBox(height: 20),

                            // Tabla Robust de Inventario
                            _buildInventoryTableCard(context),
                            const SizedBox(height: 24),

                            // Banner contextual de Ayuda / Estado
                            _buildHelpBanner(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 1. Bento-Grid de Tarjetas KPI
  Widget _buildBentoGrid(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1100;

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
          value: _totalStock.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},"),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              "+2.4%",
              style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        _buildKpiCard(
          title: "Bajo Stock",
          value: _lowStockCount.toString(),
          valueColor: const Color(0xFFBA1A1A),
          trailing: const Icon(Icons.warning_amber_rounded, color: Color(0xFFBA1A1A), size: 24),
        ),
        _buildKpiCard(
          title: "Valor Inventario",
          value: "\$${(_totalValue / 1000).toStringAsFixed(1)}k",
          trailing: const Icon(Icons.payments_outlined, color: colorOnSurfaceVariant, size: 24),
        ),
        _buildKpiCard(
          title: "Categorías",
          value: _uniqueCategories.toString(),
          trailing: const Icon(Icons.category_outlined, color: colorOnSurfaceVariant, size: 24),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    Color valueColor = colorOnSurface,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
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
            style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(color: valueColor, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -1),
              ),
              trailing,
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Controles de Filtrado e Inserción de Artículos
  Widget _buildTableControls(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown Categorías
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorSurfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorOutlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  icon: const Icon(Icons.expand_more, color: colorOnSurfaceVariant),
                  style: const TextStyle(color: colorOnSurface, fontWeight: FontWeight.w500, fontSize: 14),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  items: <String>[
                    "Todas las Categorías",
                    "Electrónica",
                    "Periféricos",
                    "Monitores",
                    "Mobiliario",
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Dropdown Proveedores
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorSurfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorOutlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedProvider,
                  icon: const Icon(Icons.expand_more, color: colorOnSurfaceVariant),
                  style: const TextStyle(color: colorOnSurface, fontWeight: FontWeight.w500, fontSize: 14),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedProvider = newValue;
                      });
                    }
                  },
                  items: <String>[
                    "Todos los Proveedores",
                    "TechSource Inc.",
                    "Global Logistics",
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),

        // Botón "+ Nuevo Item"
        ElevatedButton.icon(
          onPressed: () => _showProductDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 1,
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Nuevo Item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  /// 3. Tabla de Inventario Completa
  Widget _buildInventoryTableCard(BuildContext context) {
    final filtered = _filteredProducts;

    return Container(
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.7)),
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
          // Header de la tabla responsiva
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 900),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(80),   // Imagen
                  1: FlexColumnWidth(3),     // Nombre del Item
                  2: FlexColumnWidth(1.5),   // SKU
                  3: FlexColumnWidth(1.5),   // Categoría
                  4: FlexColumnWidth(2),     // Stock
                  5: FlexColumnWidth(1.5),   // Precio
                  6: FixedColumnWidth(120),  // Acciones
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: colorSurfaceContainerLow,
                      border: Border(bottom: BorderSide(color: colorOutlineVariant, width: 1)),
                    ),
                    children: [
                      _buildTableHeaderCell("IMAGEN"),
                      _buildTableHeaderCell("NOMBRE DEL ITEM"),
                      _buildTableHeaderCell("SKU / BARCODE"),
                      _buildTableHeaderCell("CATEGORÍA"),
                      _buildTableHeaderCell("STOCK"),
                      _buildTableHeaderCell("PRECIO VENTA"),
                      _buildTableHeaderCell("ACCIONES", alignRight: true),
                    ],
                  ),
                  if (filtered.isEmpty)
                    TableRow(
                      children: [
                        const SizedBox(),
                        TableCell(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48, color: colorOutlineVariant),
                                SizedBox(height: 12),
                                Text(
                                  "No se encontraron productos coincidentes",
                                  style: TextStyle(color: colorOnSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                      ],
                    )
                  else
                    ...filtered.map((item) {
                      final isLowStock = item.stock < 20;

                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: colorOutlineVariant, width: 0.5)),
                        ),
                        children: [
                          // Imagen Thumbnail
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: colorSurfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image, size: 20, color: colorOutlineVariant);
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Nombre del Item + Subtítulo
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(color: colorOnSurface, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // SKU / BARCODE
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                item.sku,
                                style: const TextStyle(fontFamily: 'monospace', color: colorOnSurfaceVariant, fontSize: 13),
                              ),
                            ),
                          ),
                          // Categoría Badge
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colorPrimary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.category.toUpperCase(),
                                    style: const TextStyle(color: colorPrimary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Stock con Barra de Progreso Lineal
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: colorSurfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: (item.stock / item.maxStock).clamp(0.0, 1.0),
                                      child: Container(
                                        color: isLowStock ? const Color(0xFFBA1A1A) : colorPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${item.stock} units",
                                    style: TextStyle(
                                      color: isLowStock ? const Color(0xFFBA1A1A) : colorOnSurface,
                                      fontSize: 13,
                                      fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Precio de Venta
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                "\$${item.price.toStringAsFixed(2)}",
                                style: const TextStyle(color: colorPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          // Botones de Acciones
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18, color: colorPrimary),
                                    hoverColor: colorPrimary.withValues(alpha: 0.08),
                                    onPressed: () => _showProductDialog(context, item: item),
                                    tooltip: "Modificar",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)),
                                    hoverColor: const Color(0xFFBA1A1A).withValues(alpha: 0.08),
                                    onPressed: () => _deleteProduct(item),
                                    tooltip: "Eliminar",
                                  ),
                                ],
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

          // Paginador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: colorSurfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mostrando 1 a ${filtered.length} de ${_products.length} productos",
                  style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 13),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPageButton(Icons.chevron_left, isEnabled: false),
                    const SizedBox(width: 4),
                    _buildPageButtonNumber("1", isActive: true),
                    const SizedBox(width: 4),
                    _buildPageButtonNumber("2"),
                    const SizedBox(width: 4),
                    _buildPageButtonNumber("3"),
                    const SizedBox(width: 4),
                    _buildPageButton(Icons.chevron_right),
                  ],
                ),
              ],
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
          color: colorOnSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPageButton(IconData icon, {bool isEnabled = true}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isEnabled ? colorSurfaceContainerLowest : Colors.transparent,
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: isEnabled ? colorOnSurface : colorOutlineVariant),
    );
  }

  Widget _buildPageButtonNumber(String label, {bool isActive = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? colorPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : colorOnSurface,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  /// 4. Banner Contextual de Ayuda
  Widget _buildHelpBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorPrimary.withValues(alpha: 0.05),
        border: Border.all(color: colorPrimary.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: colorPrimary, size: 20),
              SizedBox(width: 12),
              Text(
                "Los niveles de stock se actualizan automáticamente cada 5 minutos.",
                style: TextStyle(color: colorOnSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Ver reporte completo",
              style: TextStyle(color: colorPrimary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Diálogo Interactiva para Crear / Modificar Artículos
  void _showProductDialog(BuildContext context, {ProductItem? item}) {
    final isEdit = item != null;
    final nameController = TextEditingController(text: isEdit ? item.name : "");
    final subtitleController = TextEditingController(text: isEdit ? item.subtitle : "");
    final skuController = TextEditingController(text: isEdit ? item.sku : "");
    final stockController = TextEditingController(text: isEdit ? item.stock.toString() : "");
    final maxStockController = TextEditingController(text: isEdit ? item.maxStock.toString() : "100");
    final priceController = TextEditingController(text: isEdit ? item.price.toString() : "");
    String cat = isEdit ? item.category : "Electrónica";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorSurfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEdit ? "Modificar Artículo" : "Agregar Nuevo Artículo",
                style: const TextStyle(color: colorOnSurface, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nombre
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Nombre del Producto",
                          labelStyle: TextStyle(color: colorOnSurfaceVariant),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtítulo
                      TextField(
                        controller: subtitleController,
                        decoration: const InputDecoration(
                          labelText: "Especificación/Subtítulo",
                          labelStyle: TextStyle(color: colorOnSurfaceVariant),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // SKU
                      TextField(
                        controller: skuController,
                        decoration: const InputDecoration(
                          labelText: "SKU / Barcode",
                          labelStyle: TextStyle(color: colorOnSurfaceVariant),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Dropdown Categoría
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Categoría:", style: TextStyle(color: colorOnSurfaceVariant, fontWeight: FontWeight.w500)),
                          DropdownButton<String>(
                            value: cat,
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  cat = val;
                                });
                              }
                            },
                            items: ["Electrónica", "Periféricos", "Monitores", "Mobiliario"]
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Stock actual",
                                labelStyle: TextStyle(color: colorOnSurfaceVariant),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: maxStockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Stock máximo",
                                labelStyle: TextStyle(color: colorOnSurfaceVariant),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Precio de Venta (\$)",
                          labelStyle: TextStyle(color: colorOnSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: colorOnSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final subtitle = subtitleController.text.trim();
                    final sku = skuController.text.trim();
                    final stock = int.tryParse(stockController.text) ?? 0;
                    final maxStock = int.tryParse(maxStockController.text) ?? 100;
                    final price = double.tryParse(priceController.text) ?? 0.0;

                    if (name.isNotEmpty && sku.isNotEmpty) {
                      setState(() {
                        if (isEdit) {
                          item.name = name;
                          item.subtitle = subtitle;
                          item.sku = sku;
                          item.category = cat;
                          item.stock = stock;
                          item.maxStock = maxStock;
                          item.price = price;
                        } else {
                          _products.add(ProductItem(
                            name: name,
                            subtitle: subtitle,
                            sku: sku,
                            category: cat,
                            stock: stock,
                            maxStock: maxStock,
                            price: price,
                            imageUrl: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200",
                          ));
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEdit ? "Guardar" : "Agregar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteProduct(ProductItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorSurfaceContainerLowest,
          title: const Text("Eliminar Artículo"),
          content: Text("¿Está seguro de que desea eliminar el producto '${item.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _products.remove(item);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), foregroundColor: Colors.white),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }
}

/// 6. Cabecera superior (Búsqueda, perfil y acciones)
class _Header extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isDesktop;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _Header({
    required this.scaffoldKey,
    required this.isDesktop,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: _VistaInventarioState.colorSurfaceContainerLowest,
        border: Border(bottom: BorderSide(color: _VistaInventarioState.colorOutlineVariant, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop) ...[
                IconButton(
                  icon: const Icon(Icons.menu, color: _VistaInventarioState.colorOnSurface),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              const Text(
                "RetailAdmin Pro",
                style: TextStyle(color: _VistaInventarioState.colorPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 32),
              if (isDesktop)
                Container(
                  width: 320,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _VistaInventarioState.colorSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: "Buscar productos por nombre o SKU...",
                      hintStyle: TextStyle(color: _VistaInventarioState.colorOnSurfaceVariant, fontSize: 13),
                      prefixIcon: Icon(Icons.search, size: 18, color: _VistaInventarioState.colorOnSurfaceVariant),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 22, color: _VistaInventarioState.colorOnSurfaceVariant),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22, color: _VistaInventarioState.colorOnSurfaceVariant),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _VistaInventarioState.colorPrimaryContainer, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida/ADBb0uj8I9f53CpSj40cca_fxt6KDo57B4z5FBtDqrwX6YOaNbbsU1WX7mEhu5cunyifZXLih2dswdROV7dw0Js73dJ6-qs5F2VgSeZBUVN4YFIaVu_oLsBL2c-rstYiGoQhE-uY0TM2gcuR09ryDxDAHAGOxRwKRDsshuF-3NnsAIx7hHyVwi16RaRRLlSy9jG1gnABu5nQv53OELiPWAR5XPkb_VxkSsTmeuvRyhFfaZfhzRVU6MflDLaPguo-x9gcLMgro1_ligRf5Q',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _VistaInventarioState.colorPrimary,
                      child: const Icon(Icons.person, color: Colors.white, size: 18),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 7. Contenido de la Barra Lateral (Sidebar)
class _SidebarContent extends StatelessWidget {
  final bool isDrawer;
  final VoidCallback? onToggleCollapse;

  const _SidebarContent({required this.isDrawer, this.onToggleCollapse});

  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabecera del Sidebar
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SidebarState.isCollapsed && !isDrawer ? 12.0 : 24.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: SidebarState.isCollapsed && !isDrawer ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                SidebarState.isCollapsed && !isDrawer ? "LC" : "La Confianza admin",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (!(SidebarState.isCollapsed && !isDrawer)) ...[
                const SizedBox(height: 4),
                const Text(
                  "PANEL DE CONTROL",
                  style: TextStyle(color: colorOutlineVariant, fontSize: 11),
                ),
              ],
            ],
          ),
        ),

        // Items de Navegación del Sidebar
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            children: [
              _buildNavItem(
                icon: Icons.dashboard,
                label: "Inicio",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/inicio');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.group,
                label: "Usuarios",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/usuarios');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.inventory_2,
                label: "Inventario",
                isActive: true,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.point_of_sale,
                label: "Cierre de Caja",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/cierre');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.storage,
                label: "Datos",
                isActive: false,
                onTap: () {},
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.view_week,
                label: "Códigos de Barras",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/generador');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
            ],
          ),
        ),

        const Divider(color: Color(0xFF4E6073), height: 1),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: SidebarState.isCollapsed && !isDrawer ? 8.0 : 16.0,
          ),
          child: Column(
            children: [
              if (!isDrawer && onToggleCollapse != null)
                _buildNavItem(
                  icon: SidebarState.isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                  label: "Retraer",
                  isActive: false,
                  onTap: onToggleCollapse!,
                  isCollapsed: SidebarState.isCollapsed,
                ),
              _buildNavItem(
                icon: Icons.help_outline,
                label: "Soporte",
                isActive: false,
                onTap: () {},
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.logout,
                label: "Cerrar Sesión",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isCollapsed = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: isActive ? colorPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 8.0 : 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : colorOutlineVariant,
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : colorOutlineVariant,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
