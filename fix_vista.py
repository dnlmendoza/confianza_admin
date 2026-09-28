import sys

with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
    content = f.read()
    
# Remove duplicate _selectedPedido
dup = """  PedidoInventario? get _selectedPedido => ref.watch(inventarioViewModelProvider).selectedPedido;
  PedidoInventario? get _selectedPedido => ref.watch(inventarioViewModelProvider).selectedPedido;"""
content = content.replace(dup, "  PedidoInventario? get _selectedPedido => ref.watch(inventarioViewModelProvider).selectedPedido;")

# Remove _buildDropdownField
start_idx = content.find('  Widget _buildDropdownField({')
end_idx = content.find('  }', start_idx) + 3 # approx
# Wait, a safer way to remove it is just replacing it entirely by looking at it line by line
lines = content.split('\n')
new_lines = []
skip = False
for line in lines:
    if 'Widget _buildDropdownField({' in line:
        skip = True
    if skip and '  Widget _buildContabilidadTab' in line:
        skip = False
    
    if not skip:
        new_lines.append(line)

with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
    f.write('\n'.join(new_lines))
    
print("Fixed successfully")

