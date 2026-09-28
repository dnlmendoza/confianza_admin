import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';

class DetailFormTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  final ValueKey? fieldKey;
  final Function(String) onChanged;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final bool readOnly;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final TextAlign textAlign;
  final String? prefixText;

  const DetailFormTextField({
    super.key,
    required this.label,
    required this.initialValue,
    this.fieldKey,
    required this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
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
          child: TextFormField(
            key: fieldKey,
            initialValue: initialValue,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onTap: onTap,
            onChanged: onChanged,
            textAlign: textAlign,
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              prefixText: prefixText,
              prefixStyle: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 16,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      size: 16,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
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
    );
  }
}

class QuantitySelectorField extends StatelessWidget {
  final int stock;
  final ValueChanged<int> onStockChanged;
  final ValueKey? fieldKey;

  const QuantitySelectorField({
    super.key,
    required this.stock,
    required this.onStockChanged,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cantidad (Stock)",
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
            key: fieldKey,
            initialValue: stock.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) {
              final newStock = int.tryParse(val) ?? 0;
              onStockChanged(newStock);
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
                  if (stock > 1) {
                    onStockChanged(stock - 1);
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
                  onStockChanged(stock + 1);
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
    );
  }
}

class DropdownFormField extends StatelessWidget {
  final String label;
  final String currentValue;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final IconData? prefixIcon;

  const DropdownFormField({
    super.key,
    required this.label,
    required this.currentValue,
    required this.items,
    required this.onSelected,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final list = List<String>.from(items);
    if (currentValue.isNotEmpty && !list.contains(currentValue)) {
      list.insert(0, currentValue);
    }
    if (list.isEmpty) {
      list.add('General');
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
        PopupMenuButton<String>(
          onSelected: onSelected,
          itemBuilder: (BuildContext context) {
            return list.map((String val) {
              return PopupMenuItem<String>(
                value: val,
                child: Text(val, style: GoogleFonts.outfit(fontSize: 13)),
              );
            }).toList();
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    size: 16,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    currentValue.isEmpty ? 'General' : currentValue,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentValue.isNotEmpty && currentValue != 'General')
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => onSelected(''),
                        splashRadius: 16,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InteractiveTaxField extends StatefulWidget {
  final String label;
  final double value;
  final String keyPrefix;
  final String fieldKey;
  final Function(double) onChanged;

  const InteractiveTaxField({
    super.key,
    required this.label,
    required this.value,
    required this.keyPrefix,
    required this.fieldKey,
    required this.onChanged,
  });

  @override
  State<InteractiveTaxField> createState() => _InteractiveTaxFieldState();
}

class _InteractiveTaxFieldState extends State<InteractiveTaxField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller = TextEditingController(text: widget.value.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(covariant InteractiveTaxField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final currentTextVal = double.tryParse(_controller.text) ?? 0.0;
      if (currentTextVal != widget.value) {
        _controller.text = widget.value.toStringAsFixed(0);
      }
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textLength = _controller.text.length;
    final fieldWidth = (textLength * 8.0 + 8.0).clamp(20.0, 50.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary
                  : AppColors.outlineVariant.withValues(alpha: 0.4),
              width: _isFocused ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.value > 0) {
                    widget.onChanged(widget.value - 1);
                  }
                },
                child: SizedBox(
                  width: 36,
                  height: 38,
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        focusNode: _focusNode,
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (val) {
                          final parsed = double.tryParse(val) ?? 0.0;
                          widget.onChanged(parsed);
                        },
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    Text(
                      "%",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onChanged(widget.value + 1);
                },
                child: SizedBox(
                  width: 36,
                  height: 38,
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
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
            initialValue: currentValue.isEmpty ? "" : (effectiveMap.containsKey(currentValue) ? currentValue : effectiveMap.keys.first),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (currentValue.isNotEmpty && currentValue != 'General')
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => onSelected(''),
                    splashRadius: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 4.0),
                  child: Icon(Icons.expand_more, size: 20, color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                ),
              ],
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
            dropdownColor: AppColors.surfaceContainerLowest,
            items: [
              if (currentValue.isEmpty)
                DropdownMenuItem<String>(
                  value: "",
                  child: Text(
                    "Seleccione...",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ...effectiveMap.entries.map((entry) {
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
              })
            ],
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
