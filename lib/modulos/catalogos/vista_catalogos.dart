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
  int _activeCatalogTab =
      0; // 0: Categorías, 1: Proveedores, 2: Unidades de Venta
  final TextEditingController _catalogSearchController =
      TextEditingController();
  String? _selectedItem;

  final Map<String, int> _usageCountCache = {};
  final Map<String, List<Map<String, dynamic>>> _usageItemsCache = {};

  late final VMCatalogos _vmCatalogos;

  List<String> get _categories => _vmCatalogos.categorias;
  List<String> get _providers => _vmCatalogos.proveedores;
  List<String> get _units =>
      _vmCatalogos.unidadesData.map((e) => e['nameVal'] as String).toList();

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

  void _deleteUnit(String unit) {
    _vmCatalogos.deleteUnidad(unit);
    setState(() {});
  }

  Future<int> _fetchCatalogUsageCount(String item, int tabIndex) async {
    final cacheKey = '${tabIndex}_$item';
    if (_usageCountCache.containsKey(cacheKey)) {
      return _usageCountCache[cacheKey]!;
    }

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
        final result = count + (snapStr.count ?? 0);
        _usageCountCache[cacheKey] = result;
        return result;
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
        final result = count + (snapStr.count ?? 0);
        _usageCountCache[cacheKey] = result;
        return result;
      } else {
        // Unidades
        final unitData = _vmCatalogos.unidadesData.firstWhere(
          (e) => e['nameVal'] == item,
          orElse: () => <String, dynamic>{},
        );

        final List<String> possibleValues = [item];
        if (unitData.isNotEmpty) {
          if (unitData['id'] != null) {
            possibleValues.add(unitData['id']);
          }
          if (unitData['tipo'] != null) {
            possibleValues.add(unitData['tipo']);
          }
          if (unitData['nombre'] != null) {
            possibleValues.add(unitData['nombre']);
          }
        }

        final lotesRef = await firestore.collectionGroup('lote').get();
        Set<String> invIds = {};

        for (var loteDoc in lotesRef.docs) {
          final data = loteDoc.data();
          final unVal = data['unidades']?.toString().trim();
          final unValMayor = data['unidades_mayor']?.toString().trim();

          bool matched = false;
          if (unVal != null) {
            for (var pv in possibleValues) {
              if (unVal.toLowerCase() == pv.toLowerCase()) {
                matched = true;
                break;
              }
            }
          }
          if (!matched && unValMayor != null) {
            for (var pv in possibleValues) {
              if (unValMayor.toLowerCase() == pv.toLowerCase()) {
                matched = true;
                break;
              }
            }
          }

          if (matched) {
            final parentId = loteDoc.reference.parent.parent?.id;
            if (parentId != null) invIds.add(parentId);
          }
        }

        _usageCountCache[cacheKey] = invIds.length;
        return invIds.length;
      }
    } catch (e) {
      debugPrint("Error fetching usage: $e");
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCatalogUsageItems(
    String item,
    int tabIndex,
  ) async {
    final cacheKey = '${tabIndex}_$item';
    if (_usageItemsCache.containsKey(cacheKey)) {
      return _usageItemsCache[cacheKey]!;
    }

    final List<Map<String, dynamic>> results = [];
    try {
      final firestore = FirebaseFirestore.instance;
      if (tabIndex == 0) {
        // Categorías
        final catSnap = await firestore
            .collection('Categorias')
            .where('Nombre', isEqualTo: item)
            .get();
        final List<String> catIds = catSnap.docs.map((d) => d.id).toList();
        catIds.add(item);

        final invSnap = await firestore
            .collection('Inventario')
            .where('categoria', whereIn: catIds)
            .get();

        for (var doc in invSnap.docs) {
          final data = doc.data();
          results.add({
            'id': doc.id,
            'nombre': data['nombre'] ?? 'Sin Nombre',
            'descripcion': data['descripcion'] ?? '',
            'imagen': data['imagen'] ?? '',
          });
        }
      } else if (tabIndex == 1) {
        // Proveedores
        final provSnap = await firestore
            .collection('Proveedores')
            .where('Nombre', isEqualTo: item)
            .get();
        final List<String> provIds = provSnap.docs.map((d) => d.id).toList();
        provIds.add(item);

        final invSnap = await firestore
            .collection('Inventario')
            .where('proveedor', whereIn: provIds)
            .get();

        for (var doc in invSnap.docs) {
          final data = doc.data();
          results.add({
            'id': doc.id,
            'nombre': data['nombre'] ?? 'Sin Nombre',
            'descripcion': data['descripcion'] ?? '',
            'imagen': data['imagen'] ?? '',
          });
        }
      } else {
        // Unidades
        final unitData = _vmCatalogos.unidadesData.firstWhere(
          (e) => e['nameVal'] == item,
          orElse: () => <String, dynamic>{},
        );

        final List<String> possibleValues = [item];
        if (unitData.isNotEmpty) {
          if (unitData['id'] != null) {
            possibleValues.add(unitData['id']);
          }
          if (unitData['tipo'] != null) {
            possibleValues.add(unitData['tipo']);
          }
          if (unitData['nombre'] != null) {
            possibleValues.add(unitData['nombre']);
          }
        }

        final lotesRef = await firestore.collectionGroup('lote').get();
        Set<String> invIds = {};

        for (var loteDoc in lotesRef.docs) {
          final data = loteDoc.data();
          final unVal = data['unidades']?.toString().trim();
          final unValMayor = data['unidades_mayor']?.toString().trim();

          bool matched = false;
          if (unVal != null) {
            for (var pv in possibleValues) {
              if (unVal.toLowerCase() == pv.toLowerCase()) {
                matched = true;
                break;
              }
            }
          }
          if (!matched && unValMayor != null) {
            for (var pv in possibleValues) {
              if (unValMayor.toLowerCase() == pv.toLowerCase()) {
                matched = true;
                break;
              }
            }
          }

          if (matched) {
            final parentId = loteDoc.reference.parent.parent?.id;
            if (parentId != null) {
              invIds.add(parentId);
            }
          }
        }

        final List<String> invIdsList = invIds.toList();
        if (invIdsList.isNotEmpty) {
          final List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];
          for (var i = 0; i < invIdsList.length; i += 30) {
            final end = (i + 30 < invIdsList.length)
                ? i + 30
                : invIdsList.length;
            final chunk = invIdsList.sublist(i, end);
            futures.add(
              firestore
                  .collection('Inventario')
                  .where(FieldPath.documentId, whereIn: chunk)
                  .get(),
            );
          }

          final snapshots = await Future.wait(futures);
          for (var snap in snapshots) {
            for (var doc in snap.docs) {
              final data = doc.data();
              results.add({
                'id': doc.id,
                'nombre': data['nombre'] ?? 'Sin Nombre',
                'descripcion': data['descripcion'] ?? '',
                'imagen': data['imagen'] ?? '',
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching usage items: $e");
    }
    _usageItemsCache[cacheKey] = results;
    return results;
  }

  void _showAddCatalogDialog(BuildContext context, int tabIndex) {
    final title = tabIndex == 0
        ? "Nueva Categoría"
        : (tabIndex == 1 ? "Nuevo Proveedor" : "Nueva Unidad");
    final label = tabIndex == 0
        ? "Nombre de la Categoría"
        : (tabIndex == 1 ? "Nombre del Proveedor" : "Nombre de la Unidad");

    final nameController = TextEditingController();
    final typeController = TextEditingController(); // Abreviatura
    bool menorMayor = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                title,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: label,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      autofocus: true,
                    ),
                    if (tabIndex == 2) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: typeController,
                        decoration: InputDecoration(
                          labelText: "Abreviatura",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Menor & Mayor",
                              style: GoogleFonts.outfit(fontSize: 14),
                            ),
                            Switch(
                              value: menorMayor,
                              onChanged: (val) {
                                setStateDialog(() {
                                  menorMayor = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
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
                    final val = nameController.text.trim();
                    if (val.isNotEmpty) {
                      if (tabIndex == 0 && !_categories.contains(val)) {
                        _vmCatalogos.addCategoria(val);
                      } else if (tabIndex == 1 && !_providers.contains(val)) {
                        _vmCatalogos.addProveedor(val);
                      } else if (tabIndex == 2 && !_units.contains(val)) {
                        final tipo = typeController.text.trim();
                        _vmCatalogos.addUnidad(val, tipo, menorMayor);
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
        : (tabIndex == 1 ? "Renombrar Proveedor" : "Editar Unidad");

    final nameController = TextEditingController(text: item);
    final typeController = TextEditingController();
    bool menorMayor = false;
    String? unitId;

    if (tabIndex == 2) {
      final unitData = _vmCatalogos.unidadesData.firstWhere(
        (e) => e['nameVal'] == item,
        orElse: () => <String, dynamic>{},
      );
      if (unitData.isNotEmpty) {
        unitId = unitData['id'] as String?;
        nameController.text = unitData['nombre'] as String? ?? item;
        typeController.text = unitData['tipo'] as String? ?? '';
        menorMayor = unitData['mayor'] as bool? ?? false;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: tabIndex == 2 ? "Nombre" : "Nuevo Nombre",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      autofocus: true,
                    ),
                    if (tabIndex == 2) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: typeController,
                        decoration: InputDecoration(
                          labelText: "Abreviado",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Menor & Mayor",
                              style: GoogleFonts.outfit(fontSize: 14),
                            ),
                            Switch(
                              value: menorMayor,
                              onChanged: (val) {
                                setStateDialog(() {
                                  menorMayor = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
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
                    final val = nameController.text.trim();
                    if (val.isNotEmpty) {
                      if (tabIndex == 0 && val != item) {
                        _renameCategory(item, val);
                      } else if (tabIndex == 1 && val != item) {
                        _renameProvider(item, val);
                      } else if (tabIndex == 2 && unitId != null) {
                        final tipo = typeController.text.trim();
                        _vmCatalogos.updateUnidad(
                          unitId,
                          val,
                          tipo,
                          menorMayor,
                        );
                        setState(() {
                          _selectedItem = val;
                        });
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
          _selectedItem = null;
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

  Widget _buildCatalogMaintenance(BuildContext context) {
    final tabs = ["Categorías", "Proveedores", "Unidades"];
    final icons = [
      Icons.category_outlined,
      Icons.local_shipping_outlined,
      Icons.square_foot_outlined,
    ];

    List<String> currentList;
    if (_activeCatalogTab == 0) {
      currentList = ["Sin Asignar", ..._categories];
    } else if (_activeCatalogTab == 1) {
      currentList = ["Sin Asignar", ..._providers];
    } else {
      currentList = ["Sin Asignar", ..._units];
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

        // Data Table & Details Panel
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
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
                                  hintText: _activeCatalogTab == 0
                                      ? "Buscar categorías..."
                                      : _activeCatalogTab == 1
                                      ? "Buscar proveedores..."
                                      : "Buscar unidades...",
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
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text("Editar"),
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.surfaceContainerLow,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed:
                                  _selectedItem == null ||
                                      _selectedItem == "Sin Asignar"
                                  ? null
                                  : () => _showRenameCatalogDialog(
                                      context,
                                      _selectedItem!,
                                      _activeCatalogTab,
                                    ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text("Eliminar"),
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.surfaceContainerLow,
                                foregroundColor: AppColors.error,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed:
                                  _selectedItem == null ||
                                      _selectedItem == "Sin Asignar"
                                  ? null
                                  : () => _confirmDeleteCatalog(
                                      context,
                                      _selectedItem!,
                                      _activeCatalogTab,
                                    ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add, size: 16),
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
                              onPressed: () => _showAddCatalogDialog(
                                context,
                                _activeCatalogTab,
                              ),
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
                        color: AppColors.surfaceContainerLow.withValues(
                          alpha: 0.3,
                        ),
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
                            if (_activeCatalogTab == 2) ...[
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "ABREVIADO",
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
                                  "MENOR & MAYOR",
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                            Expanded(
                              flex: 2,
                              child: Text(
                                "ARTÍCULOS",
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
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

                                      String abreviado = "-";
                                      String menorMayor = "-";
                                      if (_activeCatalogTab == 2) {
                                        try {
                                          final unitData = _vmCatalogos
                                              .unidadesData
                                              .firstWhere(
                                                (e) => e['nameVal'] == item,
                                                orElse: () =>
                                                    <String, dynamic>{},
                                              );
                                          if (unitData.isNotEmpty) {
                                            abreviado = unitData['tipo'] ?? "-";
                                            if (abreviado.isEmpty) {
                                              abreviado = "-";
                                            }

                                            final bool isMayor =
                                                unitData['mayor'] == true ||
                                                unitData['menor_mayor'] == true;
                                            menorMayor = isMayor ? "Sí" : "-";
                                          }
                                        } catch (_) {}
                                      }

                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedItem = item;
                                          });
                                        },
                                        child: Container(
                                          color: _selectedItem == item
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.05,
                                                )
                                              : Colors.transparent,
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
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            _selectedItem ==
                                                                item
                                                            ? FontWeight.bold
                                                            : FontWeight.w600,
                                                        color:
                                                            _selectedItem ==
                                                                item
                                                            ? AppColors.primary
                                                            : AppColors
                                                                  .onSurface,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (_activeCatalogTab == 2) ...[
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    abreviado,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.onSurface,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    menorMayor,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.onSurface,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              Expanded(
                                                flex: 2,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isLoading
                                                          ? Colors.transparent
                                                          : (usage > 0
                                                                ? AppColors
                                                                      .primary
                                                                      .withValues(
                                                                        alpha:
                                                                            0.1,
                                                                      )
                                                                : AppColors
                                                                      .surfaceContainerLow),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: isLoading
                                                        ? const SizedBox(
                                                            width: 12,
                                                            height: 12,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          )
                                                        : Text(
                                                            usage > 0
                                                                ? "$usage asociados"
                                                                : "Sin uso",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: usage > 0
                                                                  ? AppColors
                                                                        .primary
                                                                  : AppColors
                                                                        .onSurfaceVariant,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
              const SizedBox(width: 24),
              // Right Panel (Placeholder for articles)
              Expanded(
                flex: 4,
                child: Card(
                  color: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.05),
                  child: _buildRightPanel(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    if (_selectedItem == null) {
      return Center(
        child: Text(
          "Selecciona un elemento para ver sus artículos",
          style: GoogleFonts.outfit(
            color: AppColors.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Artículos de '$_selectedItem'",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.onSurfaceVariant,
                onPressed: () {
                  setState(() {
                    _selectedItem = null;
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // List
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchCatalogUsageItems(_selectedItem!, _activeCatalogTab),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error al cargar artículos",
                    style: TextStyle(color: Colors.red[300]),
                  ),
                );
              }

              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: AppColors.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No hay artículos asociados",
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final data = items[index];
                  final imageUrl = data['imagen'] as String;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.inventory_2_outlined,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                  )
                                : const Icon(
                                    Icons.inventory_2_outlined,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['nombre'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${data['descripcion']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
