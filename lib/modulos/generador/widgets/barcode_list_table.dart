import 'package:flutter/material.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import '../modelos_generador.dart';

class BarcodeListTable extends StatelessWidget {
  final List<BarcodeEntry> allCodesRaw;
  final TextEditingController searchQueryController;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onAddSelectedToPrintQueue;
  final ValueChanged<bool> onSelectAll;
  final void Function(BarcodeEntry, bool) onSelectEntry;
  final ValueChanged<BarcodeEntry> onEditBarcode;

  const BarcodeListTable({
    super.key,
    required this.allCodesRaw,
    required this.searchQueryController,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onAddSelectedToPrintQueue,
    required this.onSelectAll,
    required this.onSelectEntry,
    required this.onEditBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: searchQueryController,
      builder: (context, _) {
        final query = searchQueryController.text.toLowerCase().trim();
        final filteredCodes = allCodesRaw.where((e) {
          final matchesType = selectedFilter == 'Todos'
              ? true
              : (selectedFilter == 'Original'
                  ? e.hasOriginalCode
                  : !e.hasOriginalCode);
          final matchesText = query.isEmpty ||
              e.name.toLowerCase().contains(query) ||
              e.barcode.toLowerCase().contains(query);
          return matchesType && matchesText;
        }).toList();

        final selectedEntries = filteredCodes.where((e) => e.selectedForPrint).toList();
        final totalSelected = selectedEntries.length;
        final allSelected = filteredCodes.isNotEmpty && totalSelected == filteredCodes.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: searchQueryController,
                      decoration: const InputDecoration(
                        hintText: "Buscar códigos de barra o productos...",
                        hintStyle: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                  onPressed: totalSelected > 0 ? onAddSelectedToPrintQueue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.outlineVariant.withValues(alpha: 0.3),
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
                    "Agregar a Cola",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: totalSelected == 1 ? () => onEditBarcode(selectedEntries.first) : null,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text("Editar"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: totalSelected == 1 ? AppColors.primary : AppColors.outlineVariant,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                  selected: {selectedFilter},
                  onSelectionChanged: (newSelection) => onFilterChanged(newSelection.first),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  showSelectedIcon: false,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCodesTable(filteredCodes, allSelected),
          ],
        );
      },
    );
  }

  Widget _buildCodesTable(List<BarcodeEntry> entries, bool selectAllValue) {
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
                    minWidth: constraints.maxWidth > 500 ? constraints.maxWidth : 500,
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(56),
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(120),
                      3: FixedColumnWidth(120),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                        ),
                        children: [
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Checkbox(
                                value: selectAllValue,
                                activeColor: AppColors.primary,
                                onChanged: (v) {
                                  final newVal = v ?? false;
                                  for (final entry in entries) {
                                    entry.selectedForPrint = newVal;
                                  }
                                  onSelectAll(newVal);
                                },
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "ARTÍCULO Y CÓDIGO",
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "(${entries.length} de ${allCodesRaw.length})",
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _tHeader("PRECIO", align: TextAlign.center),
                          _tHeader("FECHA / TIPO", align: TextAlign.center),
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
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Checkbox(
                                  value: entry.selectedForPrint,
                                  activeColor: AppColors.primary,
                                  onChanged: (v) => onSelectEntry(entry, v ?? false),
                                ),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.name,
                                      style: const TextStyle(
                                        color: AppColors.onSurface,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
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
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
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
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
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
                                        entry.hasOriginalCode ? "Original" : "Generado",
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
                                    const SizedBox(height: 6),
                                    Text(
                                      "${entry.createdAt.day.toString().padLeft(2, '0')}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.year}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
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

  TableCell _tHeader(String label, {TextAlign align = TextAlign.left}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
    );
  }
}
