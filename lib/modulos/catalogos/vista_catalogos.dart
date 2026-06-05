import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:confianza_admin/modulos/catalogos/vm_catalogos.dart';

class VistaCatalogos extends StatefulWidget {
  const VistaCatalogos({super.key});

  @override
  State<VistaCatalogos> createState() => _VistaCatalogosState();
}

class _VistaCatalogosState extends State<VistaCatalogos> {
  int _activeCatalogTab = 0; // 0: Categorías, 1: Proveedores, 2: Unidades de Venta
  final TextEditingController _catalogSearchController = TextEditingController();

  late final VMCatalogos _vmCatalogos;

  List<String> get _categories => _vmCatalogos.categorias;
  List<String> get _providers => _vmCatalogos.proveedores;
  List<String> get _units => _vmCatalogos.unidades;

  @override
  void initState() {
    super.initState();
    _vmCatalogos = VMCatalogos()
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _catalogSearchController.dispose();
    _vmCatalogos.dispose();
    super.dispose();
  }

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
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              style: GoogleFonts.outfit(
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
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
      activeRoute: '/catalogos',
      title: 'Catálogos',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: _buildCatalogMaintenance(context),
      ),
    );
  }
}
