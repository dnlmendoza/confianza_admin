import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';

class VistaInicio extends StatefulWidget {
  const VistaInicio({super.key});

  @override
  State<VistaInicio> createState() => _VistaInicioState();
}

class _VistaInicioState extends State<VistaInicio> {
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      activeRoute: '/inicio',
      title: 'Inicio',
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction_rounded,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  "Módulo en Desarrollo",
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Por favor, seleccione otros módulos en el menú lateral para continuar.",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
