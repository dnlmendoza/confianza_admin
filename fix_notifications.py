import sys

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    target = """    // Escuchamos el estado general y dejamos la estructura intacta
    final pendingCount = _viewModel.users.where((u) => u.status == "Pendiente" || u.status == "Aprobado").length;
        final notifications = pendingCount > 0
            ? [
                pendingCount == 1
                    ? "Nueva solicitud de usuario pendiente"
                    : "$pendingCount nuevas solicitudes pendientes",
              ]
            : <String>[];

        return AdminLayout(
          title: "Gestión de Usuarios",
          activeRoute: '/usuarios',
          notifications: notifications,"""

    replacement = """    return AdminLayout(
          title: "Gestión de Usuarios",
          activeRoute: '/usuarios',
          notifications: const [],"""

    if target in content:
        content = content.replace(target, replacement)
        with open(filepath, 'w') as f:
            f.write(content)
        print("Replaced successfully!")
    else:
        print("Target not found!")

if __name__ == "__main__":
    process_file('/Users/dnl/Documents/Dev_Confianza/confianza_admin/lib/modulos/usuarios/vista_usuarios.dart')
