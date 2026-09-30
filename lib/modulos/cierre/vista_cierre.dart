import 'package:flutter/material.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';

class VistaCierre extends StatefulWidget {
  const VistaCierre({super.key});

  @override
  State<VistaCierre> createState() => _VistaCierreState();
}

class _VistaCierreState extends State<VistaCierre> {
  int _activeTab = 0;

  Widget _buildTabButton(int index, String label) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListPanel() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton(0, "Ingresos")),
                Expanded(child: _buildTabButton(1, "Egresos")),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: 8,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.outlineVariant,
                indent: 0,
                endIndent: 0,
              ),
              itemBuilder: (context, index) {
                // Divisores de la lista vacíos, sin texto
                return const SizedBox(
                  height: 60, 
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    return Card(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: const SizedBox.shrink(), // Tarjeta derecha totalmente vacía
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      activeRoute: '/cierre',
      title: 'Cierre de Caja',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          
          if (isMobile) {
            return Column(
              children: [
                Expanded(child: _buildListPanel()),
                Expanded(flex: 2, child: _buildDetailsPanel()),
              ],
            );
          }
          
          return Padding(
            padding: const EdgeInsets.only(left: 0, right: 24, top: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.3 < 350 ? 350 : constraints.maxWidth * 0.3,
                  child: _buildListPanel(),
                ),
                const SizedBox(width: 24),
                Expanded(child: _buildDetailsPanel()),
              ],
            ),
          );
        },
      ),
    );
  }
}
