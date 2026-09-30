import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'viewmodel_generador.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'servicio_generador.dart';
import 'modelos_generador.dart';

import 'widgets/barcode_creation_form.dart';
import 'widgets/barcode_preview_card.dart';
import 'widgets/barcode_list_table.dart';
import 'widgets/print_queue_panel.dart';
import 'widgets/barcode_utils.dart';

class VistaGenerador extends ConsumerStatefulWidget {
  const VistaGenerador({super.key});
  @override
  ConsumerState<VistaGenerador> createState() => _VistaGeneradorState();
}

class _VistaGeneradorState extends ConsumerState<VistaGenerador>
    with SingleTickerProviderStateMixin {
  ViewModelGenerador get _viewModel => ref.read(generadorViewModelProvider.notifier);
  List<BarcodeEntry> get _generatedCodes => _viewModel.generatedCodes;
  List<BarcodeEntry> get _reprintCodes => _viewModel.reprintCodes;
  List<BarcodeEntry> get _printQueue => _viewModel.printQueue;
  late TabController _tabController;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  String _currentBarcode = '';
  bool _showPrice = true;
  int _idCounter = 1;
  String _selectedFilter = 'Todos';
  String _creationMode = 'Generado';
  late final TextEditingController _barcodeController;
  late final TextEditingController _searchQueryController;

  final ServicioGenerador _servicioGenerador = ServicioGenerador();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController();
    _priceController = TextEditingController(text: "0.00");
    _barcodeController = TextEditingController();
    _searchQueryController = TextEditingController();
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    _searchQueryController.addListener(() {
      setState(() {});
    });
    _nameController.addListener(_onNameChanged);
    _priceController.addListener(() => setState(() {}));
    _barcodeController.addListener(() {
      if (_creationMode == 'Original') {
        setState(() {
          _currentBarcode = _barcodeController.text.trim();
        });
      }
    });
  }

  void _onNameChanged() {
    if (_creationMode != 'Generado') return;
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      _currentBarcode = _generateUniqueBarcode(name);
    } else {
      _currentBarcode = '';
    }
    setState(() {});
  }

  String _generateUniqueBarcode(String name) {
    int attempt = 0;
    while (attempt < 100) {
      final hash = (name.toLowerCase().hashCode.abs() + attempt * 7919);
      final body = (hash % 1000000000).toString().padLeft(9, '0');
      final raw = "750$body";
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        final digit = int.parse(raw[i]);
        sum += (i % 2 == 0) ? digit : digit * 3;
      }
      final check = (10 - (sum % 10)) % 10;
      final barcode = "$raw$check";
      if (!_generatedCodes.any((e) => e.barcode == barcode)) return barcode;
      attempt++;
    }
    return "750${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 9)}0";
  }

  Future<void> _saveNewBarcode() async {
    final name = _nameController.text.trim();
    final barcode = _currentBarcode.trim();

    if (name.isEmpty) return;
    if (barcode.isEmpty) return;

    final allExisting = [..._generatedCodes, ..._reprintCodes];

    // Verificación de Nombre Único
    if (allExisting.any(
      (e) => e.name.trim().toLowerCase() == name.toLowerCase(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Ya existe un registro con este NOMBRE.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // Verificación de Código de Barras Único
    if (allExisting.any((e) => e.barcode.trim() == barcode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              const Icon(Icons.qr_code_scanner, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "El CÓDIGO '$barcode' ya está registrado.",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final isOriginal = _creationMode == 'Original';
    _idCounter++;
    final newEntry = BarcodeEntry(
      id: "${isOriginal ? 'r_' : ''}$_idCounter",
      name: name,
      barcode: _currentBarcode,
      price: _priceController.text,
      createdAt: DateTime.now(),
      hasOriginalCode: isOriginal,
    );

    setState(() => _isSaving = true);

    try {
      await _servicioGenerador.guardarCodigo(newEntry);

      _nameController.clear();
      _barcodeController.clear();
      _priceController.text = "0.00";
      _currentBarcode = '';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  "Código guardado para '$name'",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.toString().replaceAll("Exception: ", ""),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addSelectedToPrintQueue() {
    final selected = [
      ..._generatedCodes.where((e) => e.selectedForPrint),
      ..._reprintCodes.where((e) => e.selectedForPrint),
    ];
    if (selected.isEmpty) return;
    for (final entry in selected) {
      if (!_printQueue.any((e) => e.barcode == entry.barcode)) {
        _printQueue.add(
          BarcodeEntry(
            id: entry.id,
            name: entry.name,
            barcode: entry.barcode,
            price: entry.price,
            createdAt: entry.createdAt,
            hasOriginalCode: entry.hasOriginalCode,
          ),
        );
      }
      entry.selectedForPrint = false;
    }

    _tabController.animateTo(1);
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    _searchQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ = ref.watch(generadorViewModelProvider);
    
    return AdminLayout(
      activeRoute: '/generador',
      title: 'Códigos de Barras',
      centerWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCustomTab(0, "Generar Código"),
          const SizedBox(width: 12),
          _buildCustomTab(1, "Cola de Impresión"),
        ],
      ),
      child: TabBarView(
        controller: _tabController,
        children: [_buildGenerateTab(), _buildPrintQueueTab()],
      ),
    );
  }

  Widget _buildCustomTab(int index, String label, {Widget? badge}) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.5,
              ),
              child: Text(label),
            ),
            if (badge != null) ...[const SizedBox(width: 8), badge],
          ],
        ),
      ),
    );
  }

  void _showEditBarcodeDialog(BarcodeEntry entry) {
    final nameController = TextEditingController(text: entry.name);
    final priceController = TextEditingController(text: entry.price);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Editar Código de Barras",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Código: ${entry.barcode}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Nombre del Producto",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: "Precio (L.)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              backgroundColor: AppColors.surfaceContainerLowest,
                              title: const Text("Eliminar Código"),
                              content: Text(
                                "¿Estás seguro de que deseas eliminar el código ${entry.barcode}? Esta acción no se puede deshacer.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text("Cancelar"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Eliminar"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            setStateDialog(() => isSaving = true);
                            try {
                              await _servicioGenerador.eliminarCodigo(
                                entry.barcode,
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Código eliminado exitosamente",
                                  ),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            } catch (e) {
                              setStateDialog(() => isSaving = false);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error al eliminar: $e"),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text("Eliminar"),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) return;
                          setStateDialog(() => isSaving = true);
                          try {
                            final updated = BarcodeEntry(
                              id: entry.id,
                              name: nameController.text.trim(),
                              barcode: entry.barcode,
                              price: priceController.text.trim().isEmpty
                                  ? "0.00"
                                  : priceController.text.trim(),
                              createdAt: entry.createdAt,
                              hasOriginalCode: entry.hasOriginalCode,
                              selectedForPrint: entry.selectedForPrint,
                            );
                            await _servicioGenerador.actualizarCodigo(updated);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Código actualizado exitosamente",
                                ),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          } catch (e) {
                            setStateDialog(() => isSaving = false);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error al actualizar: $e"),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── TAB 1: GENERAR CÓDIGO ─────────────────────────────────
  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth >= 950) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLivePreviewCanvas(),
                          const SizedBox(height: 24),
                          _buildConfigForm(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(flex: 7, child: _buildGeneratedCodesSection()),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLivePreviewCanvas(),
                  const SizedBox(height: 24),
                  _buildConfigForm(),
                  const SizedBox(height: 28),
                  _buildGeneratedCodesSection(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConfigForm() {
    return BarcodeCreationForm(
      creationMode: _creationMode,
      onCreationModeChanged: (mode) {
        setState(() {
          _creationMode = mode;
          if (_creationMode == 'Generado') {
            _onNameChanged();
          } else {
            _currentBarcode = _barcodeController.text.trim();
          }
        });
      },
      nameController: _nameController,
      barcodeController: _barcodeController,
      priceController: _priceController,
      currentBarcode: _currentBarcode,
      isSaving: _isSaving,
      onSave: _saveNewBarcode,
    );
  }

  Widget _buildLivePreviewCanvas() {
    return BarcodePreviewCard(
      nameController: _nameController,
      priceController: _priceController,
      currentBarcode: _currentBarcode,
      creationMode: _creationMode,
      showPrice: _showPrice,
      onShowPriceChanged: (val) {
        setState(() {
          _showPrice = val;
        });
      },
    );
  }

  // ─── SECCIÓN: LISTADO UNIFICADO DE CÓDIGOS ──────────────────
  Widget _buildGeneratedCodesSection() {
    final allCodesRaw = [..._generatedCodes, ..._reprintCodes];
    return BarcodeListTable(
      allCodesRaw: allCodesRaw,
      searchQueryController: _searchQueryController,
      selectedFilter: _selectedFilter,
      onFilterChanged: (newFilter) {
        setState(() {
          _selectedFilter = newFilter;
        });
      },
      onAddSelectedToPrintQueue: _addSelectedToPrintQueue,
      onSelectAll: (v) {
        setState(() {});
      },
      onSelectEntry: (entry, v) {
        setState(() {
          entry.selectedForPrint = v;
        });
      },
      onEditBarcode: _showEditBarcodeDialog,
    );
  }

  // ─── TAB 3: COLA DE IMPRESIÓN ──────────────────────────────
  Widget _buildPrintQueueTab() {
    return PrintQueuePanel(
      printQueue: _printQueue,
      onClearQueue: () {
        setState(() => _printQueue.clear());
      },
      onDownloadPdf: _downloadPdf,
      onPreviewPdf: _showPdfPreviewDialog,
      onRemoveFromQueue: (index) {
        setState(() => _printQueue.removeAt(index));
      },
    );
  }

  // ─── DIÁLOGO PREVISUALIZACIÓN PDF ──────────────────────────
  void _showPdfPreviewDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 750, maxHeight: 900),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header del diálogo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Previsualización de Impresión",
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _printPdf();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.print, size: 16),
                            label: const Text(
                              "Imprimir",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Página PDF
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Builder(
                      builder: (context) {
                        final queueChunks = <List<BarcodeEntry>>[];
                        for (var i = 0; i < _printQueue.length; i += 36) {
                          queueChunks.add(
                            _printQueue.sublist(
                              i,
                              i + 36 > _printQueue.length ? _printQueue.length : i + 36,
                            ),
                          );
                        }
                        if (queueChunks.isEmpty) {
                          queueChunks.add([]);
                        }

                        return Column(
                          children: queueChunks.asMap().entries.map((entry) {
                            final pageIndex = entry.key;
                            final chunk = entry.value;
                            return Container(
                              width: 595,
                              height: 842,
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  // Cabecera de página
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "CONFIANZA - Etiquetas de Códigos de Barras",
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Página ${pageIndex + 1} de ${queueChunks.length}  •  ${_printQueue.length} etiquetas",
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 1,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  const SizedBox(height: 12),
                                  // Grid de etiquetas
                                  Expanded(
                                    child: GridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        mainAxisSpacing: 6,
                                        crossAxisSpacing: 8,
                                        childAspectRatio: 440 / 264,
                                      ),
                                      itemCount: chunk.length,
                                      itemBuilder: (ctx, i) =>
                                          _buildMiniLabel(chunk[i]),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniLabel(BarcodeEntry entry) {
    final now = entry.createdAt;
    final dateStr =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    final modeStr = entry.hasOriginalCode ? 'ORIGINAL' : 'GENERADO';
    final pVal = double.tryParse(entry.price.replaceAll(',', '')) ?? 0;
    final hasPrice = pVal > 0;

    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        width: 440,
        height: 264,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.name.split(" - ").first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                if (_showPrice && hasPrice) ...[
                  const SizedBox(width: 8),
                  Text(
                    "L. ${entry.price}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: buildBarcodeLinesFromCode(entry.barcode),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.barcode,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "SISTEMA LA CONFIANZA\nCÓDIGO $modeStr",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.black, fontSize: 8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<pw.Document> _generatePdfDocument() async {
    final pdf = pw.Document();

    // Agrupar la cola en páginas de 36 etiquetas (4 columnas x 9 filas)
    final queueChunks = <List<BarcodeEntry>>[];
    for (var i = 0; i < _printQueue.length; i += 36) {
      queueChunks.add(
        _printQueue.sublist(
          i,
          i + 36 > _printQueue.length ? _printQueue.length : i + 36,
        ),
      );
    }

    for (var pageIndex = 0; pageIndex < queueChunks.length; pageIndex++) {
      final chunk = queueChunks[pageIndex];

      // Agrupar los elementos de esta página en filas de 4 columnas
      final rows = <List<BarcodeEntry>>[];
      for (var i = 0; i < chunk.length; i += 4) {
        rows.add(chunk.sublist(i, i + 4 > chunk.length ? chunk.length : i + 4));
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabecera de la página (estilo previsualización)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "CONFIANZA - Etiquetas de Códigos de Barras",
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#64748B'),
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      "Página ${pageIndex + 1} de ${queueChunks.length}  •  ${_printQueue.length} etiquetas",
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#94A3B8'),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Container(height: 1, color: PdfColor.fromHex('#E2E8F0')),
                pw.SizedBox(height: 12),

                // Filas de etiquetas
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: rows.map((rowItems) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          ...rowItems.map((entry) {
                            final now = entry.createdAt;
                            final dateStr =
                                "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
                            final modeStr = entry.hasOriginalCode
                                ? 'ORIGINAL'
                                : 'GENERADO';
                            final pVal =
                                double.tryParse(
                                  entry.price.replaceAll(',', ''),
                                ) ??
                                0;
                            final hasPrice = pVal > 0;

                            return pw.Container(
                              width: 130.8,
                              height: 78.5,
                              padding: const pw.EdgeInsets.all(7),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 0.5,
                                ),
                              ),
                              child: pw.Column(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Text(
                                          entry.name.split(" - ").first,
                                          maxLines: 1,
                                          overflow: pw.TextOverflow.clip,
                                          style: pw.TextStyle(
                                            color: PdfColors.black,
                                            fontSize: 5.5,
                                            fontWeight: pw.FontWeight.bold,
                                            letterSpacing: -0.15,
                                          ),
                                        ),
                                      ),
                                      if (_showPrice && hasPrice) ...[
                                        pw.SizedBox(width: 4),
                                        pw.Text(
                                          "L. ${entry.price}",
                                          style: pw.TextStyle(
                                            color: PdfColors.black,
                                            fontSize: 6.0,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    children: [
                                      pw.SizedBox(
                                        height: 26,
                                        width: 65,
                                        child: pw.BarcodeWidget(
                                          barcode: pw.Barcode.code128(),
                                          data: entry.barcode,
                                          drawText: false,
                                        ),
                                      ),
                                      pw.SizedBox(height: 2.5),
                                      pw.Text(
                                        entry.barcode,
                                        style: pw.TextStyle(
                                          color: PdfColors.black,
                                          fontSize: 4.2,
                                          fontWeight: pw.FontWeight.bold,
                                          letterSpacing: 2.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.only(top: 3.5),
                                    decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                        top: pw.BorderSide(
                                          color: PdfColors.black,
                                          width: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          "SISTEMA LA CONFIANZA\nCÓDIGO $modeStr",
                                          style: pw.TextStyle(
                                            color: PdfColors.black,
                                            fontSize: 2.4,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Text(
                                          dateStr,
                                          style: const pw.TextStyle(
                                            color: PdfColors.black,
                                            fontSize: 2.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          // Rellenar espacios vacíos si la fila no está completa para mantener la alineación
                          if (rowItems.length < 4)
                            ...List.generate(
                              4 - rowItems.length,
                              (_) => pw.SizedBox(width: 130.8, height: 78.5),
                            ),
                        ].expand((w) => [w, pw.SizedBox(width: 8)]).take(7).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );
    }
    return pdf;
  }

  Future<void> _downloadPdf() async {
    if (_printQueue.isEmpty) return;

    // Mostrar SnackBar de inicio
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            SizedBox(width: 12),
            Text("Generando PDF de etiquetas..."),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final pdf = await _generatePdfDocument();
      final pdfBytes = await pdf.save();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'etiquetas_codigos_barras_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("PDF descargado exitosamente"),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("DEBUG: ERROR al descargar PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al descargar el PDF: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _printPdf() async {
    if (_printQueue.isEmpty) return;

    try {
      final pdf = await _generatePdfDocument();
      final pdfBytes = await pdf.save();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'etiquetas_codigos_barras',
      );
    } catch (e) {
      debugPrint("DEBUG: ERROR al imprimir PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al iniciar impresión: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
