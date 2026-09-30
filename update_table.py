import re

with open('lib/modulos/generador/widgets/barcode_list_table.dart', 'r') as f:
    content = f.read()

# Find the start of _buildCodesTable
start_idx = content.find('  Widget _buildCodesTable')
# Find the start of _tHeader
end_idx = content.find('  TableCell _tHeader')

new_func = """  Widget _buildCodesTable(List<BarcodeEntry> entries, bool selectAllValue, bool isBounded) {
    const colWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(56),
      1: FlexColumnWidth(),
      2: FixedColumnWidth(120),
      3: FixedColumnWidth(120),
    };

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final headerRow = TableRow(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        fontSize: 10,
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
        );

        final bodyRows = entries.map(
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
                    vertical: 4,
                  ),
                  child: Checkbox(
                    value: entry.selectedForPrint,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      onSelectEntry(entry, v ?? false);
                    },
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.barcode,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    "L. ${entry.price}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
        ).toList();

        Widget bodyWidget = Table(
          columnWidths: colWidths,
          children: bodyRows,
        );

        if (isBounded) {
          bodyWidget = Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: bodyWidget,
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth > 500 ? constraints.maxWidth : 500,
              minHeight: isBounded ? constraints.maxHeight : 0,
              maxHeight: isBounded ? constraints.maxHeight : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Table(
                  columnWidths: colWidths,
                  children: [headerRow],
                ),
                bodyWidget,
              ],
            ),
          ),
        );
      },
    );

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
          isBounded ? Expanded(child: content) : content,
        ],
      ),
    );
  }

"""

new_content = content[:start_idx] + new_func + content[end_idx:]

with open('lib/modulos/generador/widgets/barcode_list_table.dart', 'w') as f:
    f.write(new_content)

print("Updated!")
