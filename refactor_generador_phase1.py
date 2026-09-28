import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Imports
    if "flutter_riverpod.dart" not in content:
        content = content.replace(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'viewmodel_generador.dart';"
        )

    # 2. Stateful -> ConsumerStateful
    content = content.replace("extends StatefulWidget", "extends ConsumerStatefulWidget")
    content = content.replace("State<VistaGenerador>", "ConsumerState<VistaGenerador>")

    # 3. Add _viewModel getter and property getters
    getters = """  ViewModelGenerador get _viewModel => ref.watch(generadorViewModelProvider);
  List<BarcodeEntry> get _generatedCodes => _viewModel.generatedCodes;
  List<BarcodeEntry> get _reprintCodes => _viewModel.reprintCodes;
  List<BarcodeEntry> get _printQueue => _viewModel.printQueue;
"""
    # Insert after TabController declaration
    content = re.sub(r'  late TabController _tabController;\n', getters + '  late TabController _tabController;\n', content)

    # 4. Remove old field declarations
    content = re.sub(r'  StreamSubscription<List<BarcodeEntry>>\? _codigosSub;\n', '', content)
    content = re.sub(r'  final List<BarcodeEntry> _generatedCodes = \[\];\n', '', content)
    content = re.sub(r'  final List<BarcodeEntry> _reprintCodes = \[\];\n', '', content)
    content = re.sub(r'  final List<BarcodeEntry> _printQueue = \[\];\n', '', content)

    # 5. Remove _codigosSub initialization from initState
    init_state_sub = r'    _codigosSub = _servicioGenerador\.listenToCodigos\(\)\.listen\(\(codigos\) \{.*?\n    \}\);\n'
    content = re.sub(init_state_sub, '', content, flags=re.DOTALL)
    
    # In case the regex missed it because it's multiple lines
    # The subscription is like:
    # _codigosSub = _servicioGenerador.listenToCodigos().listen((codigos) {
    #   if (!mounted) return;
    #   setState(() {
    #     _generatedCodes.clear();
    #     ...
    #   });
    # });
    
    # We can just match it specifically:
    sub_code = """    _codigosSub = _servicioGenerador.listenToCodigos().listen((codigos) {
      if (!mounted) return;
      setState(() {
        _generatedCodes.clear();
        _reprintCodes.clear();
        for (var c in codigos) {
          if (c.hasOriginalCode) {
            _reprintCodes.add(c);
          } else {
            _generatedCodes.add(c);
          }
        }
      });
    });"""
    content = content.replace(sub_code, "")

    # 6. Remove cancel from dispose
    content = content.replace("    _codigosSub?.cancel();\n", "")

    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == "__main__":
    process_file('/Users/dnl/Documents/Dev_Confianza/confianza_admin/lib/modulos/generador/vista_generador.dart')
