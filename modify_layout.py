import sys

def modify_layout():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        content = f.read()

    # Remove fixed width from listPanel
    old_list_panel = """        Widget listPanel = Container(
          width: isMobile ? double.infinity : 450,
          decoration: BoxDecoration("""
    new_list_panel = """        Widget listPanel = Container(
          decoration: BoxDecoration("""
    content = content.replace(old_list_panel, new_list_panel)

    # Wrap listPanel with Expanded(flex: 3) and detailsPanel with Expanded(flex: 7)
    old_row = """                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    listPanel,
                    const SizedBox(width: 24),
                    Expanded(child: detailsPanel),
                  ],
                ),"""
    new_row = """                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: listPanel,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 7,
                      child: detailsPanel,
                    ),
                  ],
                ),"""
    content = content.replace(old_row, new_row)

    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.write(content)

modify_layout()
