import 'package:flutter/material.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:confianza_admin/core/widgets/sidebar.dart';
import 'package:confianza_admin/core/widgets/header.dart';
import 'package:confianza_admin/core/data/global_notification_store.dart';
import 'package:confianza_admin/main.dart'; // For SidebarState

class AdminLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final String activeRoute;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final Widget? centerWidget;
  final List<String>? notifications;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
    required this.activeRoute,
    this.searchController,
    this.onSearchChanged,
    this.centerWidget,
    this.notifications,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      // Cajón lateral (Drawer) para móviles y tabletas
      drawer: Drawer(
        child: Container(
          color: AppColors.inverseSurface,
          child: Sidebar(
            isDrawer: true,
            activeRoute: widget.activeRoute,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra Lateral (Sidebar) fija en pantallas grandes
              if (isDesktop)
                SizedBox(
                  width: SidebarState.isCollapsed ? 76 : 260,
                  child: Container(
                    color: AppColors.inverseSurface,
                    child: Sidebar(
                      isDrawer: false,
                      activeRoute: widget.activeRoute,
                      onToggleCollapse: () {
                        setState(() {
                          SidebarState.isCollapsed = !SidebarState.isCollapsed;
                        });
                      },
                    ),
                  ),
                ),

              // Área de Contenido Principal
              Expanded(
                child: Column(
                  children: [
                    // Cabecera superior
                    Header(
                      scaffoldKey: _scaffoldKey,
                      isDesktop: isDesktop,
                      title: widget.title,
                      searchController: widget.searchController,
                      onSearchChanged: widget.onSearchChanged,
                      centerWidget: widget.centerWidget,
                      notifications:
                          widget.notifications ??
                          GlobalNotificationStore.defaultMockNotifications,
                    ),

                    // Cuerpo de la Vista
                    Expanded(
                      child: widget.child,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
