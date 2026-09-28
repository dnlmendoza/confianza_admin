import sys
import re

def modify_toggles():
    with open('lib/modulos/inventario/widgets/inventory_tab_articles.dart', 'r') as f:
        content = f.read()

    # The current container for Tipo de Articulo starts at:
    # Container(
    #   height: 38,
    #   decoration: BoxDecoration(
    #     color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
    # ... up to the end of that Container

    # I will construct the new Row with both toggles.
    # To do this safely, I will replace the exact lines from "Container(" after "const SizedBox(height: 6),"
    # down to its closing tag.

    old_block = """                        const SizedBox(height: 6),
                        Container(
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
                                    setState(() {
                                      prod.tipoProducto = "Normal";
                                    });
                                    widget.onUpdate();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: prod.tipoProducto == "Normal"
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 15,
                                          color: prod.tipoProducto == "Normal"
                                              ? Colors.white
                                              : AppColors.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Normal",
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: prod.tipoProducto == "Normal"
                                                ? Colors.white
                                                : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      prod.tipoProducto = "Pesado";
                                    });
                                    widget.onUpdate();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: prod.tipoProducto == "Pesado"
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.scale_outlined,
                                          size: 15,
                                          color: prod.tipoProducto == "Pesado"
                                              ? Colors.white
                                              : AppColors.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Pesado",
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: prod.tipoProducto == "Pesado"
                                                ? Colors.white
                                                : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),"""

    new_block = """                        const SizedBox(height: 6),
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
                                            color: prod.tipoVenta == "Menor" ? AppColors.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.shopping_basket_outlined, size: 14, color: prod.tipoVenta == "Menor" ? Colors.white : AppColors.onSurfaceVariant),
                                              const SizedBox(width: 4),
                                              Text("Menor", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: prod.tipoVenta == "Menor" ? Colors.white : AppColors.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => prod.tipoVenta = "Mayor");
                                          widget.onUpdate();
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            color: prod.tipoVenta == "Mayor" ? AppColors.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.local_shipping_outlined, size: 14, color: prod.tipoVenta == "Mayor" ? Colors.white : AppColors.onSurfaceVariant),
                                              const SizedBox(width: 4),
                                              Text("& Mayor", style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: prod.tipoVenta == "Mayor" ? Colors.white : AppColors.onSurfaceVariant)),
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
                        ),"""

    content = content.replace(old_block, new_block)

    with open('lib/modulos/inventario/widgets/inventory_tab_articles.dart', 'w') as f:
        f.write(content)

modify_toggles()
