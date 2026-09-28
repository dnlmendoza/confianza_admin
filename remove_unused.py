import sys

def remove_unused():
    with open('lib/modulos/inventario/vista_inventario.dart', 'r') as f:
        content = f.read()

    methods_to_remove = [
        "Widget _buildDetailFormTextField",
        "Widget _buildCantidadField",
        "Widget _buildInteractiveTaxField",
        "Widget _buildUnidadesDropdown",
        "Widget _buildInteractiveNumberField", # just in case this is also unused now
    ]

    for method in methods_to_remove:
        start_idx = content.find(method)
        if start_idx != -1:
            brace_count = 0
            end_idx = start_idx
            found_first_brace = False
            for i in range(start_idx, len(content)):
                if content[i] == '{':
                    brace_count += 1
                    found_first_brace = True
                elif content[i] == '}':
                    brace_count -= 1
                if found_first_brace and brace_count == 0:
                    end_idx = i
                    break
            
            # Remove the method block
            content = content[:start_idx] + content[end_idx+1:]
    
    with open('lib/modulos/inventario/vista_inventario.dart', 'w') as f:
        f.write(content)

remove_unused()
