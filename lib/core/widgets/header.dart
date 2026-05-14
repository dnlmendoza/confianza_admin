import 'package:flutter/material.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';

class Header extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isDesktop;
  final String title;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final Widget? centerWidget;
  final List<String>? notifications;

  const Header({
    super.key,
    required this.scaffoldKey,
    required this.isDesktop,
    required this.title,
    this.searchController,
    this.onSearchChanged,
    this.centerWidget,
    this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // IZQUIERDA: Título
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDesktop) ...[
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.onSurface),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // CENTRO: Opciones Dinámicas + Buscador (Flexible y escalable)
          if (isDesktop)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (centerWidget != null) ...[
                          centerWidget!,
                          const SizedBox(width: 20),
                        ],
                        if (searchController != null)
                          SizedBox(
                            width: 280,
                            height: 38,
                            child: TextField(
                              controller: searchController,
                              onChanged: onSearchChanged,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: "Buscar...",
                                hintStyle: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 18,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                filled: true,
                                fillColor: AppColors.surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // DERECHA: Perfil y Notificaciones
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (notifications == null || notifications!.isEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    size: 22,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: () {},
                )
              else
                PopupMenuButton<String>(
                  offset: const Offset(0, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  icon: Badge(
                    backgroundColor: AppColors.error,
                    smallSize: 10,
                    child: const Icon(
                      Icons.notifications_none,
                      size: 22,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  tooltip: "Notificaciones",
                  itemBuilder: (BuildContext context) {
                    return notifications!.map((n) {
                      return PopupMenuItem<String>(
                        value: n,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                n,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),

              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 32,
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  if (isDesktop)
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Admin User",
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "SUPER ADMIN",
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryContainer,
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida/ADBb0uj8I9f53CpSj40cca_fxt6KDo57B4z5FBtDqrwX6YOaNbbsU1WX7mEhu5cunyifZXLih2dswdROV7dw0Js73dJ6-qs5F2VgSeZBUVN4YFIaVu_oLsBL2c-rstYiGoQhE-uY0TM2gcuR09ryDxDAHAGOxRwKRDsshuF-3NnsAIx7hHyVwi16RaRRLlSy9jG1gnABu5nQv53OELiPWAR5XPkb_VxkSsTmeuvRyhFfaZfhzRVU6MflDLaPguo-x9gcLMgro1_ligRf5Q',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
