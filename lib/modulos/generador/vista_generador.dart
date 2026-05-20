import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'servicio_generador.dart';

class BarcodeEntry {
  final String id;
  final String name;
  final String barcode;
  final String price;
  final DateTime createdAt;
  final bool hasOriginalCode;
  bool selectedForPrint;
  BarcodeEntry({
    required this.id,
    required this.name,
    required this.barcode,
    this.price = "0.00",
    required this.createdAt,
    this.hasOriginalCode = false,
    this.selectedForPrint = false,
  });
}

class VistaGenerador extends StatefulWidget {
  const VistaGenerador({super.key});
  @override
  State<VistaGenerador> createState() => _VistaGeneradorState();
}

class _VistaGeneradorState extends State<VistaGenerador>
    with SingleTickerProviderStateMixin {
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
  StreamSubscription<List<BarcodeEntry>>? _codigosSub;

  final List<BarcodeEntry> _generatedCodes = [];
  final List<BarcodeEntry> _reprintCodes = [];
  final List<BarcodeEntry> _printQueue = [];

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

    _codigosSub = _servicioGenerador.listenToCodigos().listen((codigos) {
      if (!mounted) return;
      setState(() {
        _generatedCodes.clear();
        _reprintCodes.clear();
        for (var c in codigos) {
          if (c.hasOriginalCode) {
            _reprintCodes.add(c);
          } else {
            _generatedCodes.add(c);
          }
        }
      });
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
    if (allExisting.any((e) => e.name.trim().toLowerCase() == name.toLowerCase())) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    _codigosSub?.cancel();
    _tabController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    _searchQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      activeRoute: '/generador',
      title: 'Códigos de Barras',
      searchController: _searchQueryController,
      onSearchChanged: (v) => setState(() {}),
      centerWidget: SegmentedButton<int>(
        segments: [
          ButtonSegment<int>(
            value: 0,
            icon: const Icon(Icons.calendar_view_week_outlined, size: 18),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Generar Código",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    "${_generatedCodes.length + _reprintCodes.length}",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ButtonSegment<int>(
            value: 1,
            icon: const Icon(Icons.print, size: 18),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Cola de Impresión",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                if (_printQueue.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      "${_printQueue.length}",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        selected: {_tabController.index},
        onSelectionChanged: (v) {
          _tabController.animateTo(v.first);
        },
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
      ),
      child: TabBarView(
        controller: _tabController,
        children: [_buildGenerateTab(), _buildPrintQueueTab()],
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                "Editar Código de Barras",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Código: ${entry.barcode}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
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
                              content: Text("¿Estás seguro de que deseas eliminar el código ${entry.barcode}? Esta acción no se puede deshacer."),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar")),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                  child: const Text("Eliminar"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            setStateDialog(() => isSaving = true);
                            try {
                              await _servicioGenerador.eliminarCodigo(entry.barcode);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Código eliminado exitosamente"), backgroundColor: Color(0xFF10B981)),
                              );
                            } catch (e) {
                              setStateDialog(() => isSaving = false);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error al eliminar: $e"), backgroundColor: AppColors.error),
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
                              price: priceController.text.trim().isEmpty ? "0.00" : priceController.text.trim(),
                              createdAt: entry.createdAt,
                              hasOriginalCode: entry.hasOriginalCode,
                              selectedForPrint: entry.selectedForPrint,
                            );
                            await _servicioGenerador.actualizarCodigo(updated);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Código actualizado exitosamente"),
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  if (c.maxWidth >= 950) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildConfigForm()),
                        const SizedBox(width: 24),
                        Expanded(flex: 7, child: _buildLivePreviewCanvas()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildLivePreviewCanvas(),
                      const SizedBox(height: 24),
                      _buildConfigForm(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              _buildGeneratedCodesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigForm() {
    return Column(
      children: [
        // Card Nuevo Código
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_view_week_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Nuevo Código de Barras",
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Tipo de Código",
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'Generado',
                      label: Text('Generado'),
                      icon: Icon(Icons.add_box, size: 16),
                    ),
                    ButtonSegment<String>(
                      value: 'Original',
                      label: Text('Original'),
                      icon: Icon(Icons.verified_user, size: 16),
                    ),
                  ],
                  selected: {_creationMode},
                  onSelectionChanged: (v) {
                    setState(() {
                      _creationMode = v.first;
                      if (_creationMode == 'Generado') {
                        _onNameChanged();
                      } else {
                        _currentBarcode = _barcodeController.text.trim();
                      }
                    });
                  },
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  showSelectedIcon: false,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Nombre del Producto",
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Ingrese el nombre del producto",
                    hintStyle: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _creationMode == 'Generado'
                    ? "Código Generado"
                    : "Ingresar Código de Barras",
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              if (_creationMode == 'Generado')
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentBarcode.isNotEmpty ? _currentBarcode : "—",
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: _currentBarcode.isNotEmpty
                                ? AppColors.onSurface
                                : AppColors.outlineVariant,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      if (_currentBarcode.isNotEmpty)
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _barcodeController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      hintText: "Escanee o digite el código",
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'sans-serif',
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                "Precio (L.)",
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12, right: 4),
                      child: Text(
                        "L.",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _currentBarcode.isNotEmpty && !_isSaving
                      ? _saveNewBarcode
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.outlineVariant
                        .withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1,
                  ),
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_alt, size: 18),
                  label: Text(
                    _isSaving ? "Guardando..." : "Guardar y Listar",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLivePreviewCanvas() {
    final displayName = _nameController.text.isNotEmpty
        ? _nameController.text
        : "Nombre del Producto";
    final displayCode = _currentBarcode.isNotEmpty
        ? _currentBarcode
        : "0000000000000";
    final now = DateTime.now();
    final dateStr =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    final displayPrice = _priceController.text.isNotEmpty
        ? _priceController.text
        : "0.00";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "PREVISUALIZACIÓN EN VIVO (ESCALA 1:1)",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 440,
                  height: 264,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName.split(" - ").first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_showPrice) ...[
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "L. $displayPrice",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: _buildBarcodeLinesFromCode(
                                      displayCode,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                displayCode,
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
                          border: Border(
                            top: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "SISTEMA LA CONFIANZA\nCÓDIGO ${_creationMode.toUpperCase()}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.tune, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Opciones de Visualización",
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Define qué campos se muestran en la etiqueta",
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _showPrice,

                onChanged: (val) {
                  setState(() {
                    _showPrice = val;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text(
                "Mostrar Precio",
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBarcodeLinesFromCode(String code) {
    final List<int> pattern = [];
    for (int i = 0; i < code.length && i < 13; i++) {
      final d = int.tryParse(code[i]) ?? 0;
      pattern.addAll([(d % 3) + 1, 0]);
      if (d % 4 == 0 && i < 12) pattern.addAll([(d % 2) + 1, 0]);
    }
    return pattern
        .map(
          (w) => w == 0
              ? const SizedBox(width: 4)
              : Container(width: w.toDouble() * 4, color: Colors.black),
        )
        .toList();
  }

  // ─── SECCIÓN: LISTADO UNIFICADO DE CÓDIGOS ──────────────────
  Widget _buildGeneratedCodesSection() {
    final allCodesRaw = [..._generatedCodes, ..._reprintCodes];
    final query = _searchQueryController.text.toLowerCase().trim();
    final filteredCodes = allCodesRaw.where((e) {
      final matchesType = _selectedFilter == 'Todos'
          ? true
          : (_selectedFilter == 'Original'
                ? e.hasOriginalCode
                : !e.hasOriginalCode);
      final matchesText =
          query.isEmpty ||
          e.name.toLowerCase().contains(query) ||
          e.barcode.toLowerCase().contains(query);
      return matchesType && matchesText;
    }).toList();

    final totalSelected = filteredCodes.where((e) => e.selectedForPrint).length;
    final allSelected =
        filteredCodes.isNotEmpty &&
        filteredCodes.every((e) => e.selectedForPrint);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Listado de Códigos de Barras",
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${filteredCodes.length} códigos mostrados (${allCodesRaw.length} total)",
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'Todos',
                      label: Text('Todos'),
                      icon: Icon(Icons.all_inclusive, size: 16),
                    ),
                    ButtonSegment<String>(
                      value: 'Original',
                      label: Text('Original'),
                      icon: Icon(Icons.verified_user, size: 16),
                    ),
                    ButtonSegment<String>(
                      value: 'Generado',
                      label: Text('Generado'),
                      icon: Icon(Icons.add_box, size: 16),
                    ),
                  ],
                  selected: {_selectedFilter},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedFilter = newSelection.first;
                    });
                  },
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  showSelectedIcon: false,
                ),
                const SizedBox(width: 20),
                if (totalSelected > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      "$totalSelected seleccionados",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: totalSelected > 0
                      ? _addSelectedToPrintQueue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.outlineVariant
                        .withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 1,
                  ),
                  icon: const Icon(Icons.print, size: 16),
                  label: const Text(
                    "Agregar a Cola de Impresión",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildCodesTable(
          filteredCodes,
          allSelected,
          (v) {
            setState(() {
              for (final e in filteredCodes) {
                e.selectedForPrint = v;
              }
            });
          },
          (entry, v) {
            setState(() {
              entry.selectedForPrint = v;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCodesTable(
    List<BarcodeEntry> entries,
    bool selectAllValue,
    ValueChanged<bool> onSelectAll,
    void Function(BarcodeEntry, bool) onSelectEntry,
  ) {
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
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth > 900
                        ? constraints.maxWidth
                        : 900,
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(56),
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(180),
                      3: FixedColumnWidth(120),
                      4: FixedColumnWidth(120),
                      5: FixedColumnWidth(120),
                      6: FixedColumnWidth(80),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          border: const Border(
                            bottom: BorderSide(
                              color: AppColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            child: Checkbox(
                              value: selectAllValue,
                              activeColor: AppColors.primary,
                              onChanged: (v) => onSelectAll(v ?? false),
                            ),
                          ),
                          _tHeader("NOMBRE"),
                          _tHeader("CÓDIGO DE BARRAS"),
                          _tHeader("PRECIO", align: TextAlign.center),
                          _tHeader("FECHA", align: TextAlign.center),
                          _tHeader("TIPO", align: TextAlign.center),
                          _tHeader("ACCIÓN", align: TextAlign.center),
                        ],
                      ),
                      ...entries.map(
                        (entry) => TableRow(
                          decoration: BoxDecoration(
                            color: entry.selectedForPrint
                                ? AppColors.primary.withValues(alpha: 0.04)
                                : null,
                            border: const Border(
                              bottom: BorderSide(
                                color: AppColors.outlineVariant,
                                width: 0.5,
                              ),
                            ),
                          ),
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Checkbox(
                                  value: entry.selectedForPrint,
                                  activeColor: AppColors.primary,
                                  onChanged: (v) =>
                                      onSelectEntry(entry, v ?? false),
                                ),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Text(
                                  entry.name,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    entry.barcode,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 12,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  "L. ${entry.price}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  "${entry.createdAt.day.toString().padLeft(2, '0')}/${entry.createdAt.month.toString().padLeft(2, '0')}/${entry.createdAt.year}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: entry.hasOriginalCode
                                          ? const Color(0xFFFFF7ED)
                                          : const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      entry.hasOriginalCode
                                          ? "Original"
                                          : "Generado",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: entry.hasOriginalCode
                                            ? const Color(0xFFEA580C)
                                            : const Color(0xFF10B981),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                    onPressed: () => _showEditBarcodeDialog(entry),
                                    tooltip: "Editar",
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                              ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: AppColors.surfaceContainerLow,
            child: Text(
              "Mostrando ${entries.length} de ${entries.length} códigos",
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _tHeader(String label, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ─── TAB 3: COLA DE IMPRESIÓN ──────────────────────────────
  Widget _buildPrintQueueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Cola de Impresión",
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _printQueue.isEmpty
                            ? "No hay etiquetas en cola"
                            : "${_printQueue.length} etiquetas listas para imprimir",
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_printQueue.isNotEmpty) ...[
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _printQueue.clear());
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.delete_sweep, size: 16),
                          label: const Text(
                            "Limpiar Cola",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _downloadPdf,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF0F172A,
                            ), // Dark Slate
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.file_download, size: 16),
                          label: const Text(
                            "Descargar PDF",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showPdfPreviewDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 1,
                          ),
                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                          label: const Text(
                            "Previsualizar PDF",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_printQueue.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.print_disabled,
                          size: 56,
                          color: AppColors.outlineVariant,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Cola de impresión vacía",
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Seleccione códigos en la pestaña \"Códigos Generados\" para agregar aquí",
                          style: TextStyle(
                            color: AppColors.outlineVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...List.generate(_printQueue.length, (i) {
                  final entry = _printQueue[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${i + 1}",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.name,
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.barcode,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "L. ${entry.price}",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.error,
                          ),
                          tooltip: "Quitar de cola",
                          onPressed: () {
                            setState(() => _printQueue.removeAt(i));
                          },
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
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
                    child: Center(
                      child: Container(
                        width: 595,
                        height: 842,
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
                                  "Página 1 de 1  •  ${_printQueue.length} etiquetas",
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
                            // Grid de etiquetas: 4 columnas x 6 filas = 24 máx
                            Expanded(
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 440 / 264,
                                    ),
                                itemCount: _printQueue.length > 24
                                    ? 24
                                    : _printQueue.length,
                                itemBuilder: (ctx, i) =>
                                    _buildMiniLabel(_printQueue[i]),
                              ),
                            ),
                          ],
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
  }

  Widget _buildMiniLabel(BarcodeEntry entry) {
    final now = entry.createdAt;
    final dateStr =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
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
                          children: _buildBarcodeLinesFromCode(entry.barcode),
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
    
    // Agrupar la cola en páginas de 24 etiquetas (4 columnas x 6 filas)
    final queueChunks = <List<BarcodeEntry>>[];
    for (var i = 0; i < _printQueue.length; i += 24) {
      queueChunks.add(
        _printQueue.sublist(
          i,
          i + 24 > _printQueue.length ? _printQueue.length : i + 24,
        ),
      );
    }

    for (var pageIndex = 0; pageIndex < queueChunks.length; pageIndex++) {
      final chunk = queueChunks[pageIndex];

      // Agrupar los elementos de esta página en filas de 4 columnas
      final rows = <List<BarcodeEntry>>[];
      for (var i = 0; i < chunk.length; i += 4) {
        rows.add(
          chunk.sublist(
            i,
            i + 4 > chunk.length ? chunk.length : i + 4,
          ),
        );
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
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
                pw.Container(
                  height: 1,
                  color: PdfColor.fromHex('#E2E8F0'),
                ),
                pw.SizedBox(height: 12),
                
                // Filas de etiquetas
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: rows.map((rowItems) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          ...rowItems.map((entry) {
                            final now = entry.createdAt;
                            final dateStr =
                                "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
                            final modeStr = entry.hasOriginalCode ? 'ORIGINAL' : 'GENERADO';
                            final pVal = double.tryParse(entry.price.replaceAll(',', '')) ?? 0;
                            final hasPrice = pVal > 0;

                            return pw.Container(
                              width: 130.8,
                              height: 78.5,
                              padding: const pw.EdgeInsets.all(7),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                border: pw.Border.all(color: PdfColors.black, width: 0.5),
                              ),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                                    mainAxisAlignment: pw.MainAxisAlignment.center,
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
                                        top: pw.BorderSide(color: PdfColors.black, width: 0.3),
                                      ),
                                    ),
                                    child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
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
        filename: 'etiquetas_codigos_barras_${DateTime.now().millisecondsSinceEpoch}.pdf',
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
