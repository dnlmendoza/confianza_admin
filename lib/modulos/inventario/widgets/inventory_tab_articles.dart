import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import '../modelos_inventario.dart';
import 'inventory_form_fields.dart';

class InventoryTabArticles extends StatefulWidget {
  final ArticuloInventario articulo;
  final Map<String, String> categorias;
  final Map<String, String> proveedores;
  final VoidCallback onUpdate;

  final Future<void> Function(ArticuloInventario)? onSave;
  final VoidCallback? onNext;

  const InventoryTabArticles({
    super.key,
    required this.articulo,
    required this.categorias,
    required this.proveedores,
    required this.onUpdate,
    this.onSave,
    this.onNext,
  });

  @override
  State<InventoryTabArticles> createState() => _InventoryTabArticlesState();
}

class _InventoryTabArticlesState extends State<InventoryTabArticles> {
  String? _originalStateStr;

  @override
  void initState() {
    super.initState();
    _captureOriginalState();
  }

  @override
  void didUpdateWidget(InventoryTabArticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.articulo.id != oldWidget.articulo.id) {
      _captureOriginalState();
    }
  }

  void _captureOriginalState() {
    if (widget.articulo.productos.isNotEmpty) {
      final prod = widget.articulo.productos.first;
      _originalStateStr = "${prod.nombre}|${prod.descripcion}|${prod.codigoBarra}|${prod.fechaIngresado}|${prod.pesado}|${prod.tipoVenta}|${prod.cantidadMinima}|${prod.categoria}|${prod.proveedor}|${prod.estado}";
    }
  }

  bool get isDirty {
    if (widget.articulo.productos.isEmpty) return false;
    final prod = widget.articulo.productos.first;
    final currentStr = "${prod.nombre}|${prod.descripcion}|${prod.codigoBarra}|${prod.fechaIngresado}|${prod.pesado}|${prod.tipoVenta}|${prod.cantidadMinima}|${prod.categoria}|${prod.proveedor}|${prod.estado}";
    return currentStr != _originalStateStr;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articulo.productos.isEmpty) {
      return Center(
        child: Text(
          "No hay productos en este pedido.",
          style: GoogleFonts.outfit(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    final prod = widget.articulo.productos.first;
    final keyPrefix = "${widget.articulo.id}-${prod.sku}";

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(right: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 130,
                height: 136,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: prod.imagen.isNotEmpty
                    ? Image.network(
                        prod.imagen,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    DetailFormTextField(
                      label: "Nombre de Articulo",
                      initialValue: prod.nombre,
                      fieldKey: ValueKey('$keyPrefix-nombre'),
                      prefixIcon: Icons.label_outlined,
                      onChanged: (val) {
                        setState(() {
                          prod.nombre = val;
                        });
                        widget.onUpdate();
                      },
                    ),
                    const SizedBox(height: 12),
                    DetailFormTextField(
                      label: "Descripción del Articulo",
                      initialValue: prod.descripcion,
                      fieldKey: ValueKey('$keyPrefix-desc'),
                      prefixIcon: Icons.subject_outlined,
                      onChanged: (val) {
                        setState(() {
                          prod.descripcion = val;
                        });
                        widget.onUpdate();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = (width - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: DetailFormTextField(
                      label: "Código de Barra",
                      initialValue: prod.codigoBarra,
                      fieldKey: ValueKey('$keyPrefix-barcode'),
                      suffixIcon: Icons.calendar_view_week_rounded,
                      readOnly: widget.articulo.id != 'nuevo_articulo',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (val) {
                        setState(() {
                          prod.codigoBarra = val;
                        });
                        widget.onUpdate();
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: DetailFormTextField(
                      label: "Fecha Ingreso",
                      initialValue: prod.fechaIngresado,
                      fieldKey: ValueKey('$keyPrefix-date'),
                      suffixIcon: Icons.calendar_month,
                      readOnly: true,
                      onChanged: (val) {
                        setState(() {
                          prod.fechaIngresado = val;
                        });
                        widget.onUpdate();
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.scale_outlined, size: 14, color: AppColors.onSurfaceVariant.withValues(alpha: 0.9)),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Pesado",
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    prod.pesado = !prod.pesado;
                                  });
                                  widget.onUpdate();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: !prod.pesado 
                                        ? AppColors.surfaceContainerLow.withValues(alpha: 0.3)
                                        : AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: !prod.pesado 
                                          ? AppColors.outlineVariant.withValues(alpha: 0.4)
                                          : AppColors.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: Stack(
                                    children: [
                                      AnimatedAlign(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        alignment: !prod.pesado ? Alignment.centerLeft : Alignment.centerRight,
                                        child: FractionallySizedBox(
                                          widthFactor: 0.5,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            decoration: BoxDecoration(
                                              color: !prod.pesado 
                                                  ? AppColors.outlineVariant.withValues(alpha: 0.8) 
                                                  : AppColors.primary,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warehouse_outlined, size: 14, color: AppColors.onSurfaceVariant.withValues(alpha: 0.9)),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Menor & Mayor",
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    prod.tipoVenta = (prod.tipoVenta == "Ambos") ? "Menor" : "Ambos";
                                  });
                                  widget.onUpdate();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: prod.tipoVenta == "Menor" 
                                        ? AppColors.surfaceContainerLow.withValues(alpha: 0.3)
                                        : AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: prod.tipoVenta == "Menor" 
                                          ? AppColors.outlineVariant.withValues(alpha: 0.4)
                                          : AppColors.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: Stack(
                                    children: [
                                      AnimatedAlign(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        alignment: prod.tipoVenta == "Menor" ? Alignment.centerLeft : Alignment.centerRight,
                                        child: FractionallySizedBox(
                                          widthFactor: 0.5,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            decoration: BoxDecoration(
                                              color: prod.tipoVenta == "Menor" 
                                                  ? AppColors.outlineVariant.withValues(alpha: 0.8) 
                                                  : AppColors.primary,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [

                            Text(
                              "Cantidad Mínima",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 38,
                          child: _QuantityCounter(
                            initialValue: prod.cantidadMinima,
                            onChanged: (newVal) {
                              prod.cantidadMinima = newVal;
                              widget.onUpdate();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: MapDropdownFormField(
                      label: "Categoría",
                      currentValue: prod.categoria,
                      itemsMap: widget.categorias,
                      prefixIcon: Icons.category_outlined,
                      onSelected: (val) {
                        setState(() {
                          prod.categoria = val;
                        });
                        widget.onUpdate();
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: MapDropdownFormField(
                      label: "Proveedor",
                      currentValue: prod.proveedor,
                      itemsMap: widget.proveedores,
                      prefixIcon: Icons.local_shipping_outlined,
                      onSelected: (val) {
                        setState(() {
                          prod.proveedor = val;
                        });
                        widget.onUpdate();
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: DropdownFormField(
                      label: "Estado",
                      currentValue: widget.articulo.id == 'nuevo_articulo' ? "Activo" : prod.estado,
                      items: const ["Activo", "Inactivo"],
                      prefixIcon: Icons.info_outline,
                      readOnly: widget.articulo.id == 'nuevo_articulo',
                      onSelected: (val) {
                        setState(() {
                          prod.estado = val;
                        });
                        widget.onUpdate();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
    ),
    const SizedBox(height: 8),
    Divider(color: AppColors.outlineVariant.withValues(alpha: 0.8), height: 2, thickness: 2),
    const SizedBox(height: 8),
    SizedBox(
      height: 48,
      child: widget.articulo.id == 'nuevo_articulo'
          ? Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (widget.onNext != null) widget.onNext!();
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text("Siguiente (Faltan datos de lote)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
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
                          await widget.onSave!(widget.articulo);
                          if (!context.mounted) return;
                          setState(() {
                            _captureOriginalState();
                          });
                        } catch (e) {
                          // Parent handles error UI
                        }
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text("Actualizar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                )
              : null),
    ),
  ],
);
  }
  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 36,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
      ),
    );
  }
}

class _QuantityCounter extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  const _QuantityCounter({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_QuantityCounter> createState() => _QuantityCounterState();
}

class _QuantityCounterState extends State<_QuantityCounter> {
  late TextEditingController _controller;
  int _currentValue = 1;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: _currentValue.toString());
  }

  @override
  void didUpdateWidget(covariant _QuantityCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _currentValue) {
      _currentValue = widget.initialValue;
      _controller.text = _currentValue.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _currentValue++;
      _controller.text = _currentValue.toString();
    });
    widget.onChanged(_currentValue);
  }

  void _decrement() {
    if (_currentValue > 1) {
      setState(() {
        _currentValue--;
        _controller.text = _currentValue.toString();
      });
      widget.onChanged(_currentValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (val) {
        final parsed = int.tryParse(val) ?? 1;
        _currentValue = parsed;
        widget.onChanged(parsed);
      },
      style: GoogleFonts.outfit(
        fontSize: 13,
        color: AppColors.onSurface,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        prefixIcon: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _decrement,
          child: Icon(
            Icons.remove,
            size: 16,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        suffixIcon: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _increment,
          child: Icon(
            Icons.add,
            size: 16,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 38,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 38,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 0,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
