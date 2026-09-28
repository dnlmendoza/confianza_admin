import sys

def make_responsive():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        content = f.read()

    start_idx = content.find('  Widget _buildInventoryOrdersView(BuildContext context) {')
    if start_idx == -1:
        return
        
    end_idx = content.find('  @override\n  Widget build(BuildContext context) {', start_idx)

    # I will replace the entire method _buildInventoryOrdersView

    new_method = """  Widget _buildInventoryOrdersView(BuildContext context) {
    final filtered = _filteredPedidos;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        Widget listPanel = Container(
          width: isMobile ? double.infinity : 450,
          decoration: BoxDecoration(
            border: isMobile
                ? null
                : Border(
                    right: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 16.0),
                child: Row(
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.outlineVariant,
                    indent: 0,
                    endIndent: 0,
                  ),
                  itemBuilder: (context, index) {
                    final pedido = filtered[index];
                    final isSelected = _selectedPedido?.id == pedido.id;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          ref.read(inventarioViewModelProvider.notifier).selectPedido(pedido);
                          ref.read(inventarioViewModelProvider.notifier).setSelectedLoteIndex(0);
                          ref.read(inventarioViewModelProvider.notifier).setActiveDetailTab(0);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected && !isMobile
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pedido.nombre,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected && !isMobile
                                          ? Colors.white
                                          : AppColors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pedido.descripcion,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected && !isMobile
                                          ? Colors.white70
                                          : AppColors.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
              ),
            ],
          ),
        );

        Widget detailsPanel = _selectedPedido == null
            ? const Center(
                child: Text(
                  "Seleccione un pedido para ver los detalles.",
                ),
              )
            : _buildPedidoDetailsPanel(context, _selectedPedido!);

        if (isMobile) {
          if (_selectedPedido != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(inventarioViewModelProvider.notifier).unselectPedido();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Volver a la lista"),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: detailsPanel),
              ],
            );
          } else {
            return listPanel;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 0,
                  right: 24,
                  top: 8,
                  bottom: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    listPanel,
                    const SizedBox(width: 24),
                    Expanded(child: detailsPanel),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
"""

    content = content[:start_idx] + new_method + "\n" + content[end_idx:]

    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.write(content)

    print("Success")

make_responsive()
