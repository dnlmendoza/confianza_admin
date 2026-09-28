import sys

def remove_method():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        lines = f.readlines()
    
    start_idx = -1
    for i, line in enumerate(lines):
        if 'Widget _buildDatosArticulosTab(PedidoInventario pedido)' in line:
            start_idx = i
            break
            
    if start_idx == -1:
        print("Not found")
        return
        
    end_idx = -1
    for i in range(start_idx, len(lines)):
        # Wait, how to find the end safely?
        # The next method is _buildContabilidadTab
        if 'Widget _buildContabilidadTab' in lines[i]:
            end_idx = i
            break
            
    if end_idx == -1:
        print("End not found")
        return
        
    new_lines = lines[:start_idx] + lines[end_idx:]
    
    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.writelines(new_lines)
        
    print("Removed successfully")

remove_method()
