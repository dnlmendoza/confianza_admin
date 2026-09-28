import sys

def modify_fifo():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        content = f.read()

    old_row = """                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Lote #${idx + 1}",
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isSelectedLote
                                                  ? Colors.white
                                                  : AppColors.onSurface,
                                            ),
                                          ),
                                          if (idx == 0) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                  6,
                                                ),
                                              ),
                                              child: Text(
                                                "FIFO Activo",
                                                style: GoogleFonts.outfit(
                                                  color: Colors.blue[800],
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          "Activo",
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),"""

    new_row = """                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Lote #${idx + 1}",
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isSelectedLote
                                              ? Colors.white
                                              : AppColors.onSurface,
                                        ),
                                      ),
                                      if (idx == 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "FIFO Activo",
                                            style: GoogleFonts.outfit(
                                              color: Colors.green[700],
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),"""

    content = content.replace(old_row, new_row)

    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.write(content)

modify_fifo()
