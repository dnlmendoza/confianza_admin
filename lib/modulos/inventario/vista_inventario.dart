import 'package:flutter/material.dart';

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
    return AdminLayout(
      activeRoute: '/inventario',
      title: 'Inventario',
      searchController: _searchController,
      onSearchChanged: (val) {
        setState(() {});
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bento-Grid de Tarjetas KPI
                            _buildBentoGrid(context),
                            SizedBox(height: 28),

                            // Controles de Filtrado e Inserción de Artículos
                            _buildTableControls(context),
                            SizedBox(height: 20),

                            // Tabla Robust de Inventario
                            _buildInventoryTableCard(context),
                            SizedBox(height: 24),

                            // Banner contextual de Ayuda / Estado
                            _buildHelpBanner(context),
                          ],
                        ),
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
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              "+2.4%",
              style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        _buildKpiCard(
          title: "Bajo Stock",
          value: _lowStockCount.toString(),
          valueColor: Color(0xFFBA1A1A),
          trailing: Icon(Icons.warning_amber_rounded, color: Color(0xFFBA1A1A), size: 24),
        ),
        _buildKpiCard(
          title: "Valor Inventario",
          value: "L. ${(_totalValue / 1000).toStringAsFixed(1)}k",
          trailing: Icon(Icons.payments_outlined, color: AppColors.onSurfaceVariant, size: 24),
        ),
        _buildKpiCard(
          title: "Categorías",
          value: _uniqueCategories.toString(),
          trailing: Icon(Icons.category_outlined, color: AppColors.onSurfaceVariant, size: 24),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
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
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
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
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  icon: Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
                  style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w500, fontSize: 14),
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
            SizedBox(width: 12),
            // Dropdown Proveedores
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedProvider,
                  icon: Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
                  style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w500, fontSize: 14),
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 1,
          ),
          icon: Icon(Icons.add, size: 18),
          label: Text("Nuevo Item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  /// 3. Tabla de Inventario Completa
  Widget _buildInventoryTableCard(BuildContext context) {
    final filtered = _filteredProducts;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.7)),
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
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
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
                        SizedBox(),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.outlineVariant),
                                SizedBox(height: 12),
                                Text(
                                  "No se encontraron productos coincidentes",
                                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(),
                        SizedBox(),
                        SizedBox(),
                        SizedBox(),
                        SizedBox(),
                      ],
                    )
                  else
                    ...filtered.map((item) {
                      final isLowStock = item.stock < 20;

                      return TableRow(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
                        ),
                        children: [
                          // Imagen Thumbnail
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image, size: 20, color: AppColors.outlineVariant);
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Nombre del Item + Subtítulo
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(color: AppColors.onSurface, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
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
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                item.sku,
                                style: TextStyle(fontFamily: 'monospace', color: AppColors.onSurfaceVariant, fontSize: 13),
                              ),
                            ),
                          ),
                          // Categoría Badge
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: IntrinsicWidth(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.category.toUpperCase(),
                                    style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Stock con Barra de Progreso Lineal
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: (item.stock / item.maxStock).clamp(0.0, 1.0),
                                      child: Container(
                                        color: isLowStock ? Color(0xFFBA1A1A) : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "${item.stock} units",
                                    style: TextStyle(
                                      color: isLowStock ? Color(0xFFBA1A1A) : AppColors.onSurface,
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
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                "L. ${item.price.toStringAsFixed(2)}",
                                style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          // Botones de Acciones
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 18, color: AppColors.primary),
                                    hoverColor: AppColors.primary.withValues(alpha: 0.08),
                                    onPressed: () => _showProductDialog(context, item: item),
                                    tooltip: "Modificar",
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)),
                                    hoverColor: Color(0xFFBA1A1A).withValues(alpha: 0.08),
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
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: AppColors.surfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mostrando 1 a ${filtered.length} de ${_products.length} productos",
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPageButton(Icons.chevron_left, isEnabled: false),
                    SizedBox(width: 4),
                    _buildPageButtonNumber("1", isActive: true),
                    SizedBox(width: 4),
                    _buildPageButtonNumber("2"),
                    SizedBox(width: 4),
                    _buildPageButtonNumber("3"),
                    SizedBox(width: 4),
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
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Text(
        label,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: AppColors.onSurfaceVariant,
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
        color: isEnabled ? AppColors.surfaceContainerLowest : Colors.transparent,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: isEnabled ? AppColors.onSurface : AppColors.outlineVariant),
    );
  }

  Widget _buildPageButtonNumber(String label, {bool isActive = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  /// 4. Banner Contextual de Ayuda
  Widget _buildHelpBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 12),
              Text(
                "Los niveles de stock se actualizan automáticamente cada 5 minutos.",
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Ver reporte completo",
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
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
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEdit ? "Modificar Artículo" : "Agregar Nuevo Artículo",
                style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
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
                          labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Subtítulo
                      TextField(
                        controller: subtitleController,
                        decoration: const InputDecoration(
                          labelText: "Especificación/Subtítulo",
                          labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                        ),
                      ),
                      SizedBox(height: 12),
                      // SKU
                      TextField(
                        controller: skuController,
                        decoration: const InputDecoration(
                          labelText: "SKU / Barcode",
                          labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Dropdown Categoría
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Categoría:", style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
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
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Stock actual",
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: maxStockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Stock máximo",
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Precio de Venta (L.)",
                          labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar", style: TextStyle(color: AppColors.onSurfaceVariant)),
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
                    backgroundColor: AppColors.primary,
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
          backgroundColor: AppColors.surfaceContainerLowest,
          title: Text("Eliminar Artículo"),
          content: Text("¿Está seguro de que desea eliminar el producto '${item.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _products.remove(item);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFBA1A1A), foregroundColor: Colors.white),
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }
}

