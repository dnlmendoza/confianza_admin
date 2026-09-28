import re
import sys

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # 1. Imports
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'widgets/crear_usuario_dialog.dart';"
    )
    
    # 2. Class definitions
    content = content.replace("extends StatefulWidget", "extends ConsumerStatefulWidget")
    content = content.replace("State<VistaUsuarios>", "ConsumerState<VistaUsuarios>")
    
    # 3. Remove _viewModel field and its manual lifecycle
    content = re.sub(r"  late final ViewModelUsuarios _viewModel;\n", "", content)
    content = re.sub(r"    _viewModel = ViewModelUsuarios\(\);\n", "", content)
    content = re.sub(r"      _viewModel.setSearchQuery\(_searchController.text\);\n", "      ref.read(usuariosViewModelProvider).setSearchQuery(_searchController.text);\n", content)
    content = re.sub(r"    _viewModel.dispose\(\);\n", "", content)
    
    # 4. Modify build method to inject _viewModel and remove ListenableBuilder
    build_start = """  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {"""
    
    build_end = """        );
      },
    );
  }"""
    
    new_build_start = """  @override
  Widget build(BuildContext context) {
    final _viewModel = ref.watch(usuariosViewModelProvider);"""
    
    new_build_end = """        );
  }"""
    
    content = content.replace(build_start, new_build_start)
    content = content.replace(build_end, new_build_end)
    
    # 5. Fix indentation of the build method body (remove 8 spaces)
    # This is tricky because there are many lines. I will let flutter format fix it later.
    
    # 6. Add "Crear Usuario" button next to search bar
    search_bar_end = """                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>("""
                
    crear_button = """                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => showDialog(context: context, builder: (c) => const CrearUsuarioDialog()),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text("Crear Usuario", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>("""
    
    content = content.replace(search_bar_end, crear_button)
    
    # 7. Add _viewModel to helper methods that need it
    # Actually, all helper methods are inside _VistaUsuariosState. 
    # If I just pass _viewModel to the methods or use ref.watch... 
    # Wait, helper methods like _buildDataTableCard don't take _viewModel.
    # To fix this, I can define `_viewModel` as a getter in `_VistaUsuariosState`:
    # `ViewModelUsuarios get _viewModel => ref.watch(usuariosViewModelProvider);`
    # That makes it globally accessible within the state class!
    
    # Let's add the getter right after the color constants.
    getter_code = """
  ViewModelUsuarios get _viewModel => ref.watch(usuariosViewModelProvider);
"""
    content = content.replace("  final TextEditingController _searchController", getter_code + "  final TextEditingController _searchController")
    
    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == "__main__":
    process_file('/Users/dnl/Documents/Dev_Confianza/confianza_admin/lib/modulos/usuarios/vista_usuarios.dart')
