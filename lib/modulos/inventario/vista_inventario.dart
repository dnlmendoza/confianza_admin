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
  ArticuloInventario? get _selectedArticulo =>
      ref.watch(inventarioViewModelProvider).selectedArticulo;
  int get _activeDetailTab =>
      ref.watch(inventarioViewModelProvider).activeDetailTab;
  int get _selectedLoteIndex =>
      ref.watch(inventarioViewModelProvider).selectedLoteIndex;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategoria;
  String? _selectedProveedor;

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
      ref
          .read(inventarioViewModelProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _vmCatalogos.dispose();
    super.dispose();
  }

  // --- FILTRADO ---

  List<ArticuloInventario> get _filteredArticulos {
    final baseList = ref
        .watch(inventarioViewModelProvider.notifier)
        .filteredArticulos;
    return baseList.where((p) {
      if (_selectedCategoria != null && p.productos.isNotEmpty) {
        final catRaw = p.productos.first.categoria;
        final catName = _vmCatalogos.categoriasMap[_selectedCategoria];
        if (catRaw != _selectedCategoria && catRaw != catName) return false;
      }
      if (_selectedProveedor != null && p.productos.isNotEmpty) {
        final provRaw = p.productos.first.proveedor;
        final provName = _vmCatalogos.proveedoresMap[_selectedProveedor];
        if (provRaw != _selectedProveedor && provRaw != provName) return false;
      }
      return true;
    }).toList();
  }

  Map<String, int> get _categoriaCounts {
    final baseList = ref
        .watch(inventarioViewModelProvider.notifier)
        .filteredArticulos;
    final counts = <String, int>{};
    for (var p in baseList) {
      if (p.productos.isNotEmpty) {
        final provRaw = p.productos.first.proveedor;
        final provName = _selectedProveedor != null
            ? _vmCatalogos.proveedoresMap[_selectedProveedor]
            : null;
        if (_selectedProveedor != null &&
            provRaw != _selectedProveedor &&
            provRaw != provName) {
          continue;
        }

        final catRaw = p.productos.first.categoria;
        String catId = catRaw;
        if (!_vmCatalogos.categoriasMap.containsKey(catRaw)) {
          final entry = _vmCatalogos.categoriasMap.entries
              .where((e) => e.value == catRaw)
              .firstOrNull;
          if (entry != null) catId = entry.key;
        }
        counts[catId] = (counts[catId] ?? 0) + 1;
      }
    }
    return counts;
  }

  Map<String, int> get _proveedorCounts {
    final baseList = ref
        .watch(inventarioViewModelProvider.notifier)
        .filteredArticulos;
    final counts = <String, int>{};
    for (var p in baseList) {
      if (p.productos.isNotEmpty) {
        final catRaw = p.productos.first.categoria;
        final catName = _selectedCategoria != null
            ? _vmCatalogos.categoriasMap[_selectedCategoria]
            : null;
        if (_selectedCategoria != null &&
            catRaw != _selectedCategoria &&
            catRaw != catName) {
          continue;
        }

        final provRaw = p.productos.first.proveedor;
        String provId = provRaw;
        if (!_vmCatalogos.proveedoresMap.containsKey(provRaw)) {
          final entry = _vmCatalogos.proveedoresMap.entries
              .where((e) => e.value == provRaw)
              .firstOrNull;
          if (entry != null) provId = entry.key;
        }
        counts[provId] = (counts[provId] ?? 0) + 1;
      }
    }
    return counts;
  }

  // --- DIÁLOGOS Y ACCIONES INTERACTIVAS DE PEDIDOS ---

  void _showEditStockDialog(
    ProductoArticulo prod,
    int prodIndex,
    ArticuloInventario articulo,
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

  Widget _buildDropdownFilter({
    required IconData icon,
    required String label,
    required Map<String, String> items,
    required Map<String, int> itemCounts,
    required String? selectedValue,
    required Function(String) onSelected,
    required VoidCallback onClear,
  }) {
    final displayLabel =
        selectedValue != null && items.containsKey(selectedValue)
        ? items[selectedValue]!
        : label;

    final isActive = selectedValue != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        // Restamos 200px (aprox la altura del header) para que ocupe todo el espacio sobrante hacia abajo.
        // Si restamos menos (ej. 150), Flutter detecta que "no cabe" y lo voltea hacia arriba.
        final safeMaxHeight = screenHeight - 200;

        return PopupMenuButton<String>(
          onSelected: onSelected,
          color: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          offset: const Offset(
            0,
            32,
          ), // Exactamente 32px (la altura del botón) para que nazca pegado sin espacios
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
            maxHeight: safeMaxHeight,
          ),
          itemBuilder: (BuildContext context) {
            return items.entries.map((entry) {
              return PopupMenuItem<String>(
                value: entry.key,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.value,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: selectedValue == entry.key
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selectedValue == entry.key
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "(${itemCounts[entry.key] ?? 0})",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isActive) ...[
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
    ProductoArticulo prod,
    int index,
    ArticuloInventario articulo,
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
                  onPressed: () => _showEditStockDialog(prod, index, articulo),
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
                articulo.productos.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLotesSection(ArticuloInventario articulo) {
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
              onPressed: () {
                ref
                    .read(inventarioViewModelProvider.notifier)
                    .setSelectedLoteIndex(-1);
                ref
                    .read(inventarioViewModelProvider.notifier)
                    .setActiveDetailTab(1);
              },
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
          child: articulo.lotes.isEmpty
              ? Center(
                  child: Text(
                    "No hay lotes registrados.",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 158, 162, 166),
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: articulo.lotes.length,
                  itemBuilder: (context, index) {
                    final lote = articulo.lotes[index];
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
                            ref
                                .read(inventarioViewModelProvider.notifier)
                                .setSelectedLoteIndex(index);
                            ref
                                .read(inventarioViewModelProvider.notifier)
                                .setActiveDetailTab(1); // Ir a Contabilidad
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
                                  Builder(
                                    builder: (context) {
                                      String text;
                                      Color color;
                                      if (lote.codigo ==
                                          articulo.activeFifoLotId) {
                                        text = "FIFO Activo";
                                        color = Colors.green;
                                      } else if (lote.stock <= 0) {
                                        text = "Agotado";
                                        color = Colors.grey;
                                      } else {
                                        text = "En Espera";
                                        color = Colors.blueGrey;
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          left: 6.0,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            text,
                                            style: GoogleFonts.outfit(
                                              color: color,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
          ref
              .read(inventarioViewModelProvider.notifier)
              .setActiveDetailTab(index);
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

  Widget _buildProductosYTotalesSection(ArticuloInventario articulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailTabButton(
                0,
                "Identificacion",
                Icons.badge_outlined,
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
                  articulo: articulo,
                  categorias: _vmCatalogos.categoriasMap,
                  proveedores: _vmCatalogos.proveedoresMap,
                  onUpdate: () => setState(() {}),
                  onSave: (updatedArticulo) async {
                    await ref
                        .read(inventarioViewModelProvider.notifier)
                        .updateArticulo(updatedArticulo);
                  },
                  onNext: () {
                    ref
                        .read(inventarioViewModelProvider.notifier)
                        .setActiveDetailTab(1);
                  },
                )
              : _activeDetailTab == 1
              ? InventoryTabLote(
                  articulo: articulo,
                  selectedLoteIndex: _selectedLoteIndex,
                  unidades: _vmCatalogos.unidadesMap,
                  unidadesMayor: _vmCatalogos.unidadesMayorMap,
                  onUpdate: () => setState(() {}),
                  onSave: (lote) async {
                    if (articulo.id == 'nuevo_articulo') {
                      await ref
                          .read(inventarioViewModelProvider.notifier)
                          .createNuevoArticulo(articulo, lote);
                    } else {
                      await ref
                          .read(inventarioViewModelProvider.notifier)
                          .updateLote(articulo, lote);
                    }
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildArticuloDetailsPanel(
    BuildContext context,
    ArticuloInventario articulo,
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
                      articulo.productos.isNotEmpty
                          ? articulo.productos.first.codigoBarra
                          : "N/A",
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
                      articulo.productos.isNotEmpty
                          ? articulo.productos.first.fechaIngresado
                          : "N/A",
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
                      articulo.productos.isNotEmpty
                          ? _vmCatalogos.categoriasMap[articulo
                                    .productos
                                    .first
                                    .categoria] ??
                                articulo.productos.first.categoria
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
                      articulo.productos.isNotEmpty
                          ? _vmCatalogos.proveedoresMap[articulo
                                    .productos
                                    .first
                                    .proveedor] ??
                                articulo.productos.first.proveedor
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
                  Expanded(flex: 1, child: _buildLotesSection(articulo)),
                  Container(
                    width: 1,
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  // 2/3: Productos y Totales
                  Expanded(
                    flex: 2,
                    child: _buildProductosYTotalesSection(articulo),
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
    final filtered = _filteredArticulos;

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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "Nombre, Codigo de Barras",
                              hintStyle: TextStyle(
                                color: AppColors.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 18),
                              filled: true,
                              fillColor: AppColors.surfaceContainerLow,
                              isDense: true,
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
                            final nowStr =
                                "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}";
                            final newDraft = ArticuloInventario(
                              id: 'nuevo_articulo',
                              nombre: '',
                              descripcion: '',
                              proveedor: '',
                              fecha: nowStr,
                              pagadoPor: '',
                              referencia: '',
                              descuento: 0,
                              impuesto: 0,
                              envio: 0,
                              productos: [
                                ProductoArticulo(
                                  nombre: '',
                                  sku: '',
                                  costo: 0,
                                  bodegas: [],
                                  categoria: '',
                                  proveedor: '',
                                  cantidadMinima: 0,
                                  tipoProducto: 'Normal',
                                  tipoVenta: 'Menor',
                                  fechaIngresado: nowStr,
                                  estado: 'Activo',
                                ),
                              ],
                              lotes: [],
                            );
                            ref
                                .read(inventarioViewModelProvider.notifier)
                                .selectArticulo(newDraft);
                            ref
                                .read(inventarioViewModelProvider.notifier)
                                .setSelectedLoteIndex(0);
                            ref
                                .read(inventarioViewModelProvider.notifier)
                                .setActiveDetailTab(0);
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(
                            "Nuevo Articulo",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
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
                      children: [
                        Expanded(
                          child: _buildDropdownFilter(
                            icon: Icons.category_outlined,
                            label: "Categoria",
                            items: _vmCatalogos.categoriasMap,
                            itemCounts: _categoriaCounts,
                            selectedValue: _selectedCategoria,
                            onSelected: (val) {
                              setState(() {
                                _selectedCategoria = val;
                              });
                            },
                            onClear: () {
                              setState(() {
                                _selectedCategoria = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDropdownFilter(
                            icon: Icons.local_shipping_outlined,
                            label: "Proveedor",
                            items: _vmCatalogos.proveedoresMap,
                            itemCounts: _proveedorCounts,
                            selectedValue: _selectedProveedor,
                            onSelected: (val) {
                              setState(() {
                                _selectedProveedor = val;
                              });
                            },
                            onClear: () {
                              setState(() {
                                _selectedProveedor = null;
                              });
                            },
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
                    final articulo = filtered[index];
                    final isSelected = _selectedArticulo?.id == articulo.id;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          ref
                              .read(inventarioViewModelProvider.notifier)
                              .selectArticulo(articulo);
                          ref
                              .read(inventarioViewModelProvider.notifier)
                              .setSelectedLoteIndex(0);
                          ref
                              .read(inventarioViewModelProvider.notifier)
                              .setActiveDetailTab(0);
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
                                    articulo.nombre,
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
                                    articulo.descripcion,
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

        Widget detailsPanel = _selectedArticulo == null
            ? const Center(
                child: Text("Seleccione un articulo para ver los detalles."),
              )
            : _buildArticuloDetailsPanel(context, _selectedArticulo!);

        if (isMobile) {
          if (_selectedArticulo != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      ref
                          .read(inventarioViewModelProvider.notifier)
                          .unselectArticulo();
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
                    Expanded(child: detailsPanel),
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
