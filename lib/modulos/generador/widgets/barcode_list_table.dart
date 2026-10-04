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
              : (selectedFilter == 'Pendiente'
                  ? !e.enInventario
                  : (selectedFilter == 'Original'
                        ? e.hasOriginalCode
                        : !e.hasOriginalCode));
          final matchesText =
              query.isEmpty ||
              e.name.toLowerCase().contains(query) ||
              e.barcode.toLowerCase().contains(query);
          return matchesType && matchesText;
        }).toList();

        final selectedEntries = filteredCodes
            .where((e) => e.selectedForPrint)
            .toList();
        final totalSelected = selectedEntries.length;
        final allSelected =
            filteredCodes.isNotEmpty && totalSelected == filteredCodes.length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isBounded = constraints.maxHeight != double.infinity;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                          ? onAddSelectedToPrintQueue
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
                        "Agregar a Cola",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                isBounded
                    ? Expanded(
                        child: _buildCodesTable(
                          filteredCodes,
                          allSelected,
                          isBounded,
                          totalSelected,
                          selectedEntries,
                        ),
                      )
                    : _buildCodesTable(
                        filteredCodes,
                        allSelected,
                        isBounded,
                        totalSelected,
                        selectedEntries,
                      ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCodesTable(
    List<BarcodeEntry> entries,
    bool selectAllValue,
    bool isBounded,
    int totalSelected,
    List<BarcodeEntry> selectedEntries,
  ) {
    final headerRow = Container(
      height: 100,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 56,
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
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: searchQueryController,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: "Buscar nombre o codigo ...",
                          hintStyle: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.2,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 40,
                            minHeight: 38,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            top: 0,
                            bottom: 0,
                            right: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: OutlinedButton.icon(
                    onPressed: totalSelected == 1
                        ? () => onEditBarcode(selectedEntries.first)
                        : null,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text("Editar"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: totalSelected == 1
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildGmailTab(
                title: 'Todos',
                icon: Icons.all_inclusive,
                isSelected: selectedFilter == 'Todos',
                onTap: () => onFilterChanged('Todos'),
              ),
              _buildGmailTab(
                title: 'Generado',
                icon: Icons.add_box,
                isSelected: selectedFilter == 'Generado',
                onTap: () => onFilterChanged('Generado'),
              ),
              _buildGmailTab(
                title: 'Original',
                icon: Icons.verified_user,
                isSelected: selectedFilter == 'Original',
                onTap: () => onFilterChanged('Original'),
              ),
              _buildGmailTab(
                title: 'Pendiente',
                icon: Icons.hourglass_bottom,
                isSelected: selectedFilter == 'Pendiente',
                onTap: () => onFilterChanged('Pendiente'),
              ),
            ],
          ),
        ],
      ),
    );

    final sliverList = SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final entry = entries[index];
        return Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Checkbox(
                  value: entry.selectedForPrint,
                  activeColor: AppColors.primary,
                  onChanged: (v) => onSelectEntry(entry, v ?? false),
                ),
              ),
              Expanded(
                flex: 3,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
              SizedBox(
                width: 120,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Builder(
                    builder: (context) {
                      String formattedPrice = entry.price;
                      final numPrice = double.tryParse(entry.price);
                      if (numPrice != null) {
                        formattedPrice = numPrice.toStringAsFixed(2);
                      }
                      return Text(
                        "L. $formattedPrice",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  ),
                ),
              ),
              SizedBox(
                width: 120,
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
              const Spacer(flex: 1),
              SizedBox(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.enInventario
                            ? Icons.check_circle
                            : Icons.hourglass_bottom,
                        color: entry.enInventario
                            ? const Color(0xFF10B981)
                            : AppColors.outlineVariant,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.enInventario ? "En Inventario" : "Pendiente",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: entry.enInventario
                              ? const Color(0xFF10B981)
                              : AppColors.outlineVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }, childCount: entries.length),
    );

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth > 500
            ? constraints.maxWidth
            : 500;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: width,
              minHeight: isBounded ? constraints.maxHeight : 0,
              maxHeight: isBounded ? constraints.maxHeight : double.infinity,
            ),
            child: SizedBox(
              width: width,
              child: RawScrollbar(
                padding: const EdgeInsets.only(top: 100),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: SelectionArea(
                    child: CustomScrollView(
                      physics: isBounded
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      shrinkWrap: !isBounded,
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _StickyHeaderDelegate(
                            child: headerRow,
                            height: 100,
                          ),
                        ),
                        if (entries.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 48,
                                    color: AppColors.outlineVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No hay Artículos",
                                    style: TextStyle(
                                      color: AppColors.outlineVariant,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          sliverList,
                      ],
                    ),
                  ),
                ),
              ),
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
        children: [isBounded ? Expanded(child: content) : content],
      ),
    );
  }

  Widget _buildGmailTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.onSurface.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
