import sys

def update_search():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        content = f.read()
    
    old_block = """                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Buscar...",
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.filter_list, size: 18),
                        onPressed: () {},
                      ),
                    ),
                  ],"""

    new_block = """                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Buscar por Nombre, Codigo de Barras",
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined, size: 18, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: 2),
                          Text("Categoria", style: GoogleFonts.outfit(fontSize: 10, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: 2),
                          Text("Proveedor", style: GoogleFonts.outfit(fontSize: 10, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],"""

    content = content.replace(old_block, new_block)

    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.write(content)

update_search()
