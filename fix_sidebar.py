import sys

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    if "package:go_router/go_router.dart" not in content:
        content = content.replace(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';\nimport 'package:go_router/go_router.dart';"
        )
    
    content = content.replace("Navigator.pushReplacementNamed(context, ", "context.go(")
    
    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == "__main__":
    process_file('/Users/dnl/Documents/Dev_Confianza/confianza_admin/lib/core/widgets/sidebar.dart')
