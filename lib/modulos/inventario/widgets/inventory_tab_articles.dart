import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import '../modelos_inventario.dart';
import 'inventory_form_fields.dart';

class InventoryTabArticles extends StatefulWidget {
  final PedidoInventario pedido;
  final Map<String, String> categorias;
  final Map<String, String> proveedores;
  final VoidCallback onUpdate;

  const InventoryTabArticles({
    super.key,
    required this.pedido,
    required this.categorias,
    required this.proveedores,
    required this.onUpdate,
  });

  @override
  State<InventoryTabArticles> createState() => _InventoryTabArticlesState();
}

class _InventoryTabArticlesState extends State<InventoryTabArticles> {
  @override
  Widget build(BuildContext context) {
    if (widget.pedido.productos.isEmpty) {
      return Center(
        child: Text(
          "No hay productos en este pedido.",
          style: GoogleFonts.outfit(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    final prod = widget.pedido.productos.first;
    final keyPrefix = "${widget.pedido.id}-${prod.sku}";

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
                      fieldKey: ValueKey('$keyPrefix-nombre-${prod.nombre}'),
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
                      fieldKey: ValueKey('$keyPrefix-desc-${prod.descripcion}'),
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
                      fieldKey: ValueKey('$keyPrefix-barcode-${prod.codigoBarra}'),
                      suffixIcon: Icons.calendar_view_week_rounded,
                      readOnly: true,
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
                      fieldKey: ValueKey('$keyPrefix-date-${prod.fechaIngresado}'),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tipo de Articulo",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                                  ),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => prod.tipoProducto = "Normal");
                                          widget.onUpdate();
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            color: prod.tipoProducto == "Normal" ? AppColors.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.inventory_2_outlined, size: 14, color: prod.tipoProducto == "Normal" ? Colors.white : AppColors.onSurfaceVariant),
                                              const SizedBox(width: 4),
                                              Text("Normal", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: prod.tipoProducto == "Normal" ? Colors.white : AppColors.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => prod.tipoProducto = "Pesado");
                                          widget.onUpdate();
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            color: prod.tipoProducto == "Pesado" ? AppColors.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.scale_outlined, size: 14, color: prod.tipoProducto == "Pesado" ? Colors.white : AppColors.onSurfaceVariant),
                                              const SizedBox(width: 4),
                                              Text("Pesado", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: prod.tipoProducto == "Pesado" ? Colors.white : AppColors.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                                  ),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => prod.tipoVenta = "Menor");
                                          widget.onUpdate();
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            color: (prod.tipoVenta == "Menor" || prod.tipoVenta == "Ambos") ? AppColors.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.storefront_outlined, size: 14, color: (prod.tipoVenta == "Menor" || prod.tipoVenta == "Ambos") ? Colors.white : AppColors.onSurfaceVariant),
                                              const SizedBox(width: 4),
                                              Text("Menor", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: (prod.tipoVenta == "Menor" || prod.tipoVenta == "Ambos") ? Colors.white : AppColors.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => prod.tipoVenta = (prod.tipoVenta == "Ambos") ? "Menor" : "Ambos");
                                          widget.onUpdate();
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            color: prod.tipoVenta == "Ambos" ? AppColors.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.warehouse_outlined, size: 14, color: prod.tipoVenta == "Ambos" ? Colors.white : AppColors.onSurfaceVariant),
                                              const SizedBox(width: 4),
                                              Text("& Mayor", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: prod.tipoVenta == "Ambos" ? Colors.white : AppColors.onSurfaceVariant)),
                                            ],
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
                      ],
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cantidad Mínima",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 38,
                          child: TextFormField(
                            key: ValueKey('$keyPrefix-minQty-${prod.cantidadMinima}'),
                            initialValue: prod.cantidadMinima.toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (val) {
                              final parsed = int.tryParse(val) ?? 1;
                              prod.cantidadMinima = parsed;
                              widget.onUpdate();
                            },
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (prod.cantidadMinima > 1) {
                                    setState(() {
                                      prod.cantidadMinima--;
                                    });
                                    widget.onUpdate();
                                  }
                                },
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                              ),
                              suffixIcon: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    prod.cantidadMinima++;
                                  });
                                  widget.onUpdate();
                                },
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
                      currentValue: prod.estado,
                      items: const ["Activo", "Inactivo"],
                      prefixIcon: Icons.info_outline,
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
      child: Container(),
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
