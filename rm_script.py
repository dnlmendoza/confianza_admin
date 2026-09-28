import sys

def replace_between(filepath, start_str, replacement):
    with open(filepath, 'r') as f:
        content = f.read()
    
    start_idx = content.find(start_str)
    if start_idx == -1:
        print("Start not found")
        return
        
    new_content = content[:start_idx] + replacement
    with open(filepath, 'w') as f:
        f.write(new_content)
    print("Replaced successfully")

replace_between('lib/modulos/inventario/vista_inventario.dart',
    'class InteractiveTaxField extends StatefulWidget {',
    '')
