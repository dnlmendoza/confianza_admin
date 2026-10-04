import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../modelos_inventario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'inventory_form_fields.dart';

class InventoryTabLote extends StatefulWidget {
  final ArticuloInventario articulo;
  final int selectedLoteIndex;
  final VoidCallback onUpdate;
  final Future<void> Function(LoteArticulo)? onSave;
  final Map<String, String> unidades;
  final Map<String, String> unidadesMayor;

  const InventoryTabLote({
    super.key,
    required this.articulo,
    required this.selectedLoteIndex,
    required this.unidades,
    required this.unidadesMayor,
    required this.onUpdate,
    this.onSave,
  });

  @override
  State<InventoryTabLote> createState() => _InventoryTabLoteState();
}

class _InventoryTabLoteState extends State<InventoryTabLote> {
  String? _originalLoteStr;

  LoteArticulo? _draftLote;

  @override
  void initState() {
    super.initState();
    _initializeDraftIfNeeded();
    _captureOriginalState();
  }

  @override
  void didUpdateWidget(covariant InventoryTabLote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.articulo.id != widget.articulo.id ||
        oldWidget.selectedLoteIndex != widget.selectedLoteIndex ||
        oldWidget.articulo.lotes.length != widget.articulo.lotes.length) {
      _initializeDraftIfNeeded();
      _captureOriginalState();
    }
  }

  void _initializeDraftIfNeeded() {
    if (widget.selectedLoteIndex == -1 || 
        (widget.articulo.lotes.isEmpty && widget.articulo.id == 'nuevo_articulo')) {
      _draftLote ??= LoteArticulo(
        codigo: FirebaseFirestore.instance.collection('lote').doc().id,
        stock: 0,
        fechaIngreso:
            "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}",
        fechaVencimiento: '',
        costo: 0,
        precioVenta: 0,
      );
    } else {
      _draftLote = null;
    }
  }

  void _captureOriginalState() {
    if (_draftLote != null) {
      _originalLoteStr = jsonEncode(_draftLote!.toMap());
    } else if (widget.articulo.lotes.isNotEmpty) {
      final int index = widget.selectedLoteIndex.clamp(
        0,
        widget.articulo.lotes.length - 1,
      );
      _originalLoteStr = jsonEncode(widget.articulo.lotes[index].toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articulo.lotes.isEmpty && _draftLote == null) {
      return Center(
        child: Text(
          "No hay lotes en este articulo.",
          style: GoogleFonts.outfit(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    
    final lote = _draftLote ?? widget.articulo.lotes[widget.selectedLoteIndex.clamp(0, widget.articulo.lotes.length - 1)];

    // Check if dirty
    final currentStr = jsonEncode(lote.toMap());
    final isDirty = _originalLoteStr != currentStr;
    final bool showMayor =
        widget.articulo.productos.isNotEmpty &&
        widget.articulo.productos.first.tipoVenta == 'Ambos';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(right: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header box (Lote ID & Costo Lote)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.layers_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lote.codigo,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    "Ingreso: ${lote.fechaIngreso.isNotEmpty ? lote.fechaIngreso : 'N/A'}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Costo Lote",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurfaceVariant.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                width: 140,
                                height: 28,
                                child: MonetaryAmountField(
                                  value: lote.costoLote,
                                  prefixIcon: Icons.calculate_outlined,
                                  prefixText: "L. ",
                                  onChanged: (val) {
                                    lote.costoLote = val;
                                    widget.onUpdate();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: "Fecha Vencimiento",
                              value: lote.fechaVencimiento,
                              onChanged: (val) {
                                lote.fechaVencimiento = val;
                                widget.onUpdate();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInteractiveTaxField(
                              label: "Impuesto Compra",
                              value: lote.impuestoCompra,
                              onChanged: (val) {
                                lote.impuestoCompra = val;
                                widget.onUpdate();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInteractiveTaxField(
                              label: "Impuesto Venta",
                              value: lote.impuestoVenta,
                              onChanged: (val) {
                                lote.impuestoVenta = val;
                                widget.onUpdate();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Retail Container
                _buildFormContainer(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InteractiveTaxField(
                            label: "Cantidad",
                            value: lote.stock.toDouble(),
                            keyPrefix: widget.articulo.id,
                            fieldKey: '${widget.articulo.id}-stock',
                            showPercentage: false,
                            onChanged: (val) {
                              lote.stock = val.toInt();
                              widget.onUpdate();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMapDropdown(
                            label: "Unidades",
                            value: lote.unidades,
                            itemsMap: widget.unidades,
                            onChanged: (val) {
                              lote.unidades = val;
                              widget.onUpdate();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAmountField(
                            label: "Costo Unitario",
                            value: lote.costo,
                            icon: Icons.payments_outlined,
                            onChanged: (val) {
                              lote.costo = val;
                              widget.onUpdate();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAmountField(
                            label: "Precio Venta",
                            value: lote.precioVenta,
                            icon: Icons.sell_outlined,
                            onChanged: (val) {
                              lote.precioVenta = val;
                              widget.onUpdate();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildGananciaCard(
                      gananciaUnidad: lote.precioVenta - lote.costo,
                      gananciaLote:
                          (lote.precioVenta - lote.costo) * lote.stock,
                      costo: lote.costo,
                    ),
                  ],
                ),
                // Wholesale Container
                if (showMayor) ...[
                  const SizedBox(height: 8),
                  _buildFormContainer(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InteractiveTaxField(
                              label: "Cantidad al Mayor",
                              value: lote.stockMayor.toDouble(),
                              keyPrefix: widget.articulo.id,
                              fieldKey: '${widget.articulo.id}-stockMayor',
                              showPercentage: false,
                              onChanged: (val) {
                                lote.stockMayor = val.toInt();
                                widget.onUpdate();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMapDropdown(
                              label: "Unidades al Mayor",
                              value: lote.unidadesMayor,
                              itemsMap: widget.unidadesMayor,
                              onChanged: (val) {
                                lote.unidadesMayor = val;
                                widget.onUpdate();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAmountField(
                              label: "Costo Unitario al Mayor",
                              value: lote.costoMayor,
                              icon: Icons.payments_outlined,
                              onChanged: (val) {
                                lote.costoMayor = val;
                                widget.onUpdate();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAmountField(
                              label: "Precio Venta al Mayor",
                              value: lote.precioVentaMayor,
                              icon: Icons.sell_outlined,
                              onChanged: (val) {
                                lote.precioVentaMayor = val;
                                widget.onUpdate();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildGananciaCard(
                        gananciaUnidad: lote.precioVentaMayor - lote.costoMayor,
                        gananciaLote:
                            (lote.precioVentaMayor - lote.costoMayor) *
                            lote.stockMayor,
                        costo: lote.costoMayor,
                        isMayor: true,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          color: AppColors.outlineVariant.withValues(alpha: 0.8),
          height: 2,
          thickness: 2,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: widget.articulo.id == 'nuevo_articulo'
              ? Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (widget.onSave != null) {
                        try {
                          await widget.onSave!(lote);
                        } catch (e) {
                          // Parent handles error UI
                        }
                      }
                    },
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text("Guardar Artículo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : (isDirty
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (widget.onSave != null) {
                              try {
                                await widget.onSave!(lote);
                                if (!context.mounted) return;
                                setState(() {
                                  _captureOriginalState();
                                });
                              } catch (e) {
                                // Parent handles error UI
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: const Text("Actualizar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            textStyle: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : null),
        ),
      ],
    );
  }

  Widget _buildFormContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildAmountField({
    required String label,
    required double value,
    required IconData icon,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 0),
        SizedBox(
          height: 38,
          child: MonetaryAmountField(
            value: value,
            prefixIcon: icon,
            prefixText: "L.    ",
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMapDropdown({
    required String label,
    required String value,
    required Map<String, String> itemsMap,
    required Function(String) onChanged,
  }) {
    // Prevent crash if value is not in map
    final effectiveMap = Map<String, String>.from(itemsMap);
    if (value.isNotEmpty && !effectiveMap.containsKey(value)) {
      effectiveMap[value] = "Dato no encontrado ($value)";
    }

    // Use null if value is empty to show hint
    final effectiveValue = value.isEmpty ? null : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 0),
        SizedBox(
          height: 38,
          child: DropdownButtonFormField<String>(
            initialValue: effectiveValue,
            hint: Text(
              "Seleccione...",
              style: GoogleFonts.outfit(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (value.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => onChanged(''),
                    splashRadius: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, left: 4.0),
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.only(left: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            items: effectiveMap.entries
                .map(
                  (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 0),
        SizedBox(
          height: 38,
          child: TextFormField(
            key: ValueKey(value),
            initialValue: value,
            readOnly: true,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              suffixIcon: const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                final str =
                    "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
                onChanged(str);
              }
            },
          ),
        ),
      ],
    );
  }



  Widget _buildInteractiveTaxField({
    required String label,
    required double value,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 0),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => onChanged(value > 0 ? value - 1 : 0),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
                child: Container(
                  width: 38,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.remove,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toInt().toString(),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      " %",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => onChanged(value + 1),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(10),
                ),
                child: Container(
                  width: 38,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGananciaCard({
    required double gananciaUnidad,
    required double gananciaLote,
    required double costo,
    bool isMayor = false,
  }) {
    double margen = costo > 0 ? (gananciaUnidad / costo) * 100 : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ganancia Unidad${isMayor ? ' al Mayor' : ''}",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 0),
                Row(
                  children: [
                    Text(
                      "L. ${gananciaUnidad.toStringAsFixed(2)}",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.trending_up, size: 14, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      "${margen.toStringAsFixed(1)}%",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: Colors.green.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ganancia Lote${isMayor ? ' al Mayor' : ''}",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 0),
                Row(
                  children: [
                    Text(
                      "L. ${gananciaLote.toStringAsFixed(2)}",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.trending_up, size: 14, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      "${margen.toStringAsFixed(1)}%",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
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
