import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventario_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:confianza_admin/modulos/catalogos/vm_catalogos.dart';

import 'modelos_inventario.dart';

import 'widgets/inventory_tab_articles.dart';
import 'widgets/inventory_tab_lote.dart';

// --- CLASE VISTA PRINCIPAL ---

class VistaInventario extends ConsumerStatefulWidget {
  const VistaInventario({super.key});

  @override
  ConsumerState<VistaInventario> createState() => _VistaInventarioState();
}

class _VistaInventarioState extends ConsumerState<VistaInventario> {
  // Dynamic lists for catalogs (vinculados al ViewModel)
  late final VMCatalogos _vmCatalogos;


  // State for Inventory Orders Tab (Local state only, no Firestore stream)
  PedidoInventario? get _selectedPedido => ref.watch(inventarioViewModelProvider).selectedPedido;
  int get _activeDetailTab => ref.watch(inventarioViewModelProvider).activeDetailTab;
  int get _selectedLoteIndex => ref.watch(inventarioViewModelProvider).selectedLoteIndex;
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
    _searchController.addListener(() {
      ref.read(inventarioViewModelProvider.notifier).setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _vmCatalogos.dispose();
    super.dispose();
  }

  // --- FILTRADO ---

  List<PedidoInventario> get _filteredPedidos => ref.watch(inventarioViewModelProvider.notifier).filteredPedidos;

  // --- DIÁLOGOS Y ACCIONES INTERACTIVAS DE PEDIDOS ---


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


  // --- CONSTRUCCIÓN DE WIDGETS ---

  Widget _buildMetadataItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                            ref.read(inventarioViewModelProvider.notifier).setSelectedLoteIndex(index);
                            ref.read(inventarioViewModelProvider.notifier).setActiveDetailTab(1); // Ir a Contabilidad
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.layers_outlined,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      lote.codigo,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (index == 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6.0),
                                      child: Container(
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
                                          "FIFO Activo",
                                          style: GoogleFonts.outfit(
                                            color: Colors.green[700],
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                    "Costo: L. ${lote.costoLote.toStringAsFixed(2)}",
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
          ref.read(inventarioViewModelProvider.notifier).setActiveDetailTab(index);
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



  Widget _buildProductosYTotalesSection(PedidoInventario pedido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailTabButton(
                0,
                "Identificacion",
                Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailTabButton(
                1,
                "Datos Lote",
                Icons.layers_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailTabButton(
                2,
                "Contabilidad",
                Icons.calculate_outlined,
              ),
            ),
          ],
        ),
        Expanded(
          child: _activeDetailTab == 0
              ? InventoryTabArticles(
                  pedido: pedido,
                  categorias: _vmCatalogos.categoriasMap,
                  proveedores: _vmCatalogos.proveedoresMap,
                  onUpdate: () => setState(() {}),
                )
              : _activeDetailTab == 1
              ? InventoryTabLote(
                  pedido: pedido,
                  selectedLoteIndex: _selectedLoteIndex,
                  unidades: _vmCatalogos.unidadesMap,
                  unidadesMayor: _vmCatalogos.unidadesMayorMap,
                  onUpdate: () => setState(() {}),
                  onSave: (lote) {
                    ref.read(inventarioViewModelProvider.notifier).updateLote(pedido, lote);
                  },
                )
              : const SizedBox.shrink(),
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
                      pedido.productos.isNotEmpty ? pedido.productos.first.codigoBarra : "N/A",
                      Icons.calendar_view_week_rounded,
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
                      pedido.productos.isNotEmpty ? pedido.productos.first.fechaIngresado : "N/A",
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
                      pedido.productos.isNotEmpty 
                          ? _vmCatalogos.categoriasMap[pedido.productos.first.categoria] ?? pedido.productos.first.categoria 
                          : "N/A",
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
                      pedido.productos.isNotEmpty 
                          ? _vmCatalogos.proveedoresMap[pedido.productos.first.proveedor] ?? pedido.productos.first.proveedor 
                          : "N/A",
                      Icons.local_shipping_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        Widget listPanel = Container(
          decoration: BoxDecoration(
            border: isMobile
                ? null
                : Border(
                    right: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "Buscar por Nombre, Codigo de Barras",
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
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close, size: 16),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (val) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            // Logic for new article
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(
                            "Nuevo Articulo",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.category_outlined, size: 16, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text("Categoria", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 80),
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text("Proveedor", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
                          ref.read(inventarioViewModelProvider.notifier).selectPedido(pedido);
                          ref.read(inventarioViewModelProvider.notifier).setSelectedLoteIndex(0);
                          ref.read(inventarioViewModelProvider.notifier).setActiveDetailTab(0);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected && !isMobile
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pedido.nombre,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected && !isMobile
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
                                      color: isSelected && !isMobile
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
        );

        Widget detailsPanel = _selectedPedido == null
            ? const Center(
                child: Text(
                  "Seleccione un pedido para ver los detalles.",
                ),
              )
            : _buildPedidoDetailsPanel(context, _selectedPedido!);

        if (isMobile) {
          if (_selectedPedido != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(inventarioViewModelProvider.notifier).unselectPedido();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Volver a la lista"),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: detailsPanel),
              ],
            );
          } else {
            return listPanel;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    SizedBox(
                      width: constraints.maxWidth * 0.3 < 350
                          ? 350
                          : constraints.maxWidth * 0.3,
                      child: listPanel,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: detailsPanel,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
