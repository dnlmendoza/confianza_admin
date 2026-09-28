import 'package:flutter/material.dart';

List<Widget> buildBarcodeLinesFromCode(String code) {
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
