import sys

def add_map_dropdown():
    with open('lib/modulos/inventario/widgets/inventory_form_fields.dart', 'r') as f:
        content = f.read()
    
    map_dropdown = """
class MapDropdownFormField extends StatelessWidget {
  final String label;
  final String currentValue; // The ID
  final Map<String, String> itemsMap; // ID -> Name
  final ValueChanged<String> onSelected;
  final IconData? prefixIcon;

  const MapDropdownFormField({
    super.key,
    required this.label,
    required this.currentValue,
    required this.itemsMap,
    required this.onSelected,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the selected item. If currentValue doesn't exist in map, add it.
    final effectiveMap = Map<String, String>.from(itemsMap);
    if (currentValue.isNotEmpty && !effectiveMap.containsKey(currentValue)) {
      effectiveMap[currentValue] = currentValue; // Display ID if name not found
    }
    if (effectiveMap.isEmpty) {
      effectiveMap['General'] = 'General';
    }

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
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: DropdownButtonFormField<String>(
            value: effectiveMap.containsKey(currentValue) ? currentValue : effectiveMap.keys.first,
            icon: Icon(
              Icons.expand_more,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 16,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
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
            dropdownColor: AppColors.surfaceContainer,
            items: effectiveMap.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                onSelected(val);
              }
            },
          ),
        ),
      ],
    );
  }
}
"""
    if 'class MapDropdownFormField' not in content:
        content += map_dropdown
        with open('lib/modulos/inventario/widgets/inventory_form_fields.dart', 'w') as f:
            f.write(content)

add_map_dropdown()
