import 'package:flutter/material.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';

class BarcodeCreationForm extends StatelessWidget {
  final String creationMode;
  final ValueChanged<String> onCreationModeChanged;
  final TextEditingController nameController;
  final TextEditingController barcodeController;
  final TextEditingController priceController;
  final String currentBarcode;
  final bool showPrice;
  final ValueChanged<bool> onShowPriceChanged;
  final bool isSaving;
  final VoidCallback? onSave;

  const BarcodeCreationForm({
    super.key,
    required this.creationMode,
    required this.onCreationModeChanged,
    required this.nameController,
    required this.barcodeController,
    required this.priceController,
    required this.currentBarcode,
    required this.showPrice,
    required this.onShowPriceChanged,
    required this.isSaving,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Mostrar Precio",
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 28,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Switch(
                            value: showPrice,
                            onChanged: onShowPriceChanged,
                          ),
                        ),
                      ),
                    ],
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
                  selected: {creationMode},
                  onSelectionChanged: (v) {
                    onCreationModeChanged(v.first);
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
                  controller: nameController,
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
                creationMode == 'Generado'
                    ? "Código Generado"
                    : "Ingresar Código de Barras",
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              if (creationMode == 'Generado')
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
                          currentBarcode.isNotEmpty ? currentBarcode : "—",
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: currentBarcode.isNotEmpty
                                ? AppColors.onSurface
                                : AppColors.outlineVariant,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      if (currentBarcode.isNotEmpty)
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
                    controller: barcodeController,
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
                  controller: priceController,
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
                  onPressed: currentBarcode.isNotEmpty && !isSaving
                      ? onSave
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
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_alt, size: 18),
                  label: Text(
                    isSaving ? "Guardando..." : "Guardar y Listar",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
