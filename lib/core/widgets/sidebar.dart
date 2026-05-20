import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:confianza_admin/main.dart'; // For SidebarState

class Sidebar extends StatelessWidget {
  final bool isDrawer;
  final VoidCallback? onToggleCollapse;
  final String activeRoute;

  const Sidebar({
    super.key,
    required this.isDrawer,
    required this.activeRoute,
    this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabecera de la Marca
        InkWell(
          onTap: () {
            if (isDrawer) Navigator.pop(context);
            if (activeRoute != '/inicio') {
              Navigator.pushReplacementNamed(context, '/inicio');
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SidebarState.isCollapsed && !isDrawer ? 12.0 : 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: SidebarState.isCollapsed && !isDrawer
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  SidebarState.isCollapsed && !isDrawer
                      ? "LC"
                      : "La Confianza admin",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                if (!(SidebarState.isCollapsed && !isDrawer)) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Panel de Control",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Items de Navegación
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.group,
                label: "Usuarios",
                isActive: activeRoute == '/usuarios',
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  if (activeRoute != '/usuarios') {
                    Navigator.pushReplacementNamed(context, '/usuarios');
                  }
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.inventory_outlined,
                label: "Inventario",
                isActive: activeRoute == '/inventario',
                isDisabled: true,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  if (activeRoute != '/inventario') {
                    Navigator.pushReplacementNamed(context, '/inventario');
                  }
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.point_of_sale,
                label: "Cierre de Caja",
                isActive: activeRoute == '/cierre',
                isDisabled: true,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  if (activeRoute != '/cierre') {
                    Navigator.pushReplacementNamed(context, '/cierre');
                  }
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.storage,
                label: "Datos",
                isActive: activeRoute == '/datos',
                isDisabled: true,
                onTap: () {},
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.calendar_view_week_outlined,
                label: "Códigos de Barras",
                isActive: activeRoute == '/generador',
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  if (activeRoute != '/generador') {
                    Navigator.pushReplacementNamed(context, '/generador');
                  }
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
            ],
          ),
        ),

        // Footer del Sidebar
        const Divider(color: AppColors.secondary, height: 1),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: SidebarState.isCollapsed && !isDrawer ? 8.0 : 16.0,
          ),
          child: Column(
            children: [
              if (!isDrawer && onToggleCollapse != null)
                _buildNavItem(
                  context: context,
                  icon: SidebarState.isCollapsed
                      ? Icons.chevron_right
                      : Icons.chevron_left,
                  label: "Retraer",
                  isActive: false,
                  onTap: onToggleCollapse!,
                  isCollapsed: SidebarState.isCollapsed,
                ),
              _buildNavItem(
                context: context,
                icon: Icons.help_outline,
                label: "Soporte",
                isActive: false,
                onTap: () {},
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.logout,
                label: "Cerrar Sesión",
                isActive: false,
                onTap: () async {
                  if (isDrawer) Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isCollapsed = false,
    bool isDisabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Este módulo está en mantenimiento provisionalmente."),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 8.0 : 16.0,
            vertical: 12.0,
          ),
          margin: const EdgeInsets.symmetric(vertical: 2.0),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isDisabled 
                    ? Colors.white.withValues(alpha: 0.2)
                    : (isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6)),
                size: 20,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isDisabled
                        ? Colors.white.withValues(alpha: 0.2)
                        : (isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.8)),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
