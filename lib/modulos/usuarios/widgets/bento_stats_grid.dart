import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel_usuarios.dart';

class BentoStatsGrid extends ConsumerWidget {
  final BoxConstraints constraints;

  const BentoStatsGrid({super.key, required this.constraints});

  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorOnSurface = Color(0xFF181C20);
  static const Color colorOnSurfaceVariant = Color(0xFF3F4850);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);
  static const Color colorSurfaceContainerLowest = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _ = ref.watch(usuariosViewModelProvider);
    final viewModel = ref.read(usuariosViewModelProvider.notifier);
    final isMobile = constraints.maxWidth < 600;

    if (isMobile) {
      return Column(
        children: [
          _buildBentoStatCard(
            title: "Total Usuarios",
            value: "${viewModel.users.length}",
            subtitle: "Registrados",
            icon: Icons.group,
            iconColor: colorPrimary,
            iconBgColor: const Color(0xFFCCE5FF),
            subtitleColor: const Color(0xFF10B981),
            isTrend: true,
          ),
          const SizedBox(height: 12),
          _buildBentoStatCard(
            title: "Sesiones Activas",
            value: "0",
            subtitle: "Tiempo real",
            icon: Icons.bolt,
            iconColor: const Color(0xFF4E6073),
            iconBgColor: const Color(0xFFD1E4FB),
            subtitleColor: colorOnSurfaceVariant,
          ),

          const SizedBox(height: 12),
          _buildSecurityAuditCard(context),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildBentoStatCard(
              title: "Total Usuarios",
              value: "${viewModel.users.length}",
              subtitle: "Registrados",
              icon: Icons.group,
              iconColor: colorPrimary,
              iconBgColor: const Color(0xFFCCE5FF),
              subtitleColor: const Color(0xFF10B981),
              isTrend: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBentoStatCard(
              title: "Sesiones Activas",
              value: "0",
              subtitle: "Tiempo real",
              icon: Icons.bolt,
              iconColor: const Color(0xFF4E6073),
              iconBgColor: const Color(0xFFD1E4FB),
              subtitleColor: colorOnSurfaceVariant,
            ),
          ),

          const SizedBox(width: 16),
          Expanded(child: _buildSecurityAuditCard(context)),
        ],
      ),
    );
  }

  Widget _buildBentoStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color subtitleColor,
    bool isTrend = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: colorOnSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: colorOnSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (isTrend) ...[
                    Icon(Icons.trending_up, color: subtitleColor, size: 14),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSecurityAuditCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorPrimary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.shield_outlined,
              color: Colors.white.withValues(alpha: 0.08),
              size: 80,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Auditoría",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Historial de accesos",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  minimumSize: const Size(0, 32),
                ),
                child: const Center(
                  child: Text(
                    "Ver Logs",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
