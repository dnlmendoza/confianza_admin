import 'package:flutter/material.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'modelos_usuarios.dart';
import 'viewmodel_usuarios.dart';
import 'package:confianza_admin/core/config/role_constants.dart';

class VistaUsuarios extends StatefulWidget {
  const VistaUsuarios({super.key});

  @override
  State<VistaUsuarios> createState() => _VistaUsuariosState();
}

class _VistaUsuariosState extends State<VistaUsuarios> {
  // Paleta de colores consistente de la marca
  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorOnSurface = Color(0xFF181C20);
  static const Color colorOnSurfaceVariant = Color(0xFF3F4850);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);
  static const Color colorSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color colorSurfaceContainerLow = Color(0xFFF1F4FA);

  late final ViewModelUsuarios _viewModel;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _profileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelUsuarios();
    _searchController.addListener(() {
      _viewModel.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _profileNameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final pendingCount = _viewModel.users.where((u) => u.status == "Pendiente" || u.status == "Aprobado").length;
        final notifications = pendingCount > 0
            ? [
                pendingCount == 1
                    ? "Nueva solicitud de usuario pendiente"
                    : "$pendingCount nuevas solicitudes pendientes",
              ]
            : <String>[];

        return AdminLayout(
          activeRoute: '/usuarios',
          title: 'Usuarios',
          notifications: notifications,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1024;
              return SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bento Grid de Métricas
                    _buildBentoStatsGrid(context),
                    const SizedBox(height: 24),

                    // Tabla de Datos Principal
                    _buildDataTableCard(context),
                    const SizedBox(height: 24),

                    // Sección de Roles y Permisos Inferior
                    _buildPermissionsGuideCard(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBentoStatsGrid(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GridView.count(
      crossAxisCount: isMobile ? 1 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isMobile ? 3.2 : 1.45,
      children: [
        _buildBentoStatCard(
          title: "Total Usuarios",
          value: "${_viewModel.users.length}",
          subtitle: "Nuevos este mes",
          icon: Icons.group,
          iconColor: colorPrimary,
          iconBgColor: const Color(0xFFCCE5FF),
          subtitleColor: const Color(0xFF10B981),
          isTrend: true,
        ),
        _buildBentoStatCard(
          title: "Sesiones Activas",
          value: "0",
          subtitle: "Tiempo real",
          icon: Icons.bolt,
          iconColor: const Color(0xFF4E6073),
          iconBgColor: const Color(0xFFD1E4FB),
          subtitleColor: colorOnSurfaceVariant,
        ),
        _buildBentoStatCard(
          title: "Solicitudes",
          value: "${_viewModel.users.where((u) => u.status == 'Pendiente' || u.status == 'Aprobado').length}",
          subtitle: "Pendientes de aprobación",
          icon: Icons.person_add_alt_1,
          iconColor: const Color(0xFF8E6A00),
          iconBgColor: const Color(0xFFFFEDC8),
          subtitleColor: colorOnSurfaceVariant,
        ),
        _buildSecurityAuditCard(context),
      ],
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
      padding: const EdgeInsets.all(18),
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

  Widget _buildDataTableCard(BuildContext context) {
    final allFiltered = _viewModel.filteredUsers;
    final totalPages = (allFiltered.length / _viewModel.itemsPerPage).ceil() == 0 ? 1 : (allFiltered.length / _viewModel.itemsPerPage).ceil();

    final int startIndex = _viewModel.currentPage * _viewModel.itemsPerPage;
    final int endIndex = (startIndex + _viewModel.itemsPerPage < allFiltered.length) ? startIndex + _viewModel.itemsPerPage : allFiltered.length;
    final filtered = allFiltered.isEmpty ? <UserModel>[] : allFiltered.sublist(startIndex, endIndex);

    return Container(
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorSurfaceContainerLow.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                  color: colorOutlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTableTabItem(
                    "Usuarios Activos",
                    0,
                    _viewModel.users.where((u) => u.status == 'Activo').length,
                  ),
                ),
                Expanded(
                  child: _buildTableTabItem(
                    "Solicitudes de Acceso",
                    1,
                    _viewModel.users.where((u) => u.status == 'Pendiente' || u.status == 'Aprobado').length,
                  ),
                ),
                Expanded(
                  child: _buildTableTabItem(
                    "Usuarios Suspendidos",
                    2,
                    _viewModel.users.where((u) => u.status == 'suspendido').length,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Buscar por nombre o correo...",
                        hintStyle: TextStyle(color: colorOnSurfaceVariant, fontSize: 13),
                        prefixIcon: Icon(Icons.search, size: 18, color: colorOnSurfaceVariant),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  tooltip: "Filtrar por Rol",
                  onSelected: (val) => _viewModel.setRoleFilter(val),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "Todos", child: Text("Todos los Roles")),
                    ..._viewModel.profiles.map((p) => PopupMenuItem(value: p.id, child: Text(p.name))),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorOutlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_list, size: 16, color: colorOnSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          _viewModel.selectedRoleFilter == "Todos" 
                              ? "Filtrar" 
                              : _viewModel.getRoleName(_viewModel.selectedRoleFilter),
                          style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth > 850.0 ? constraints.maxWidth : 850.0;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2.5),
                          1: FlexColumnWidth(1.4),
                          2: FlexColumnWidth(1.2),
                          3: FlexColumnWidth(1.5),
                          4: FlexColumnWidth(2.1),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              color: colorSurfaceContainerLow,
                              border: Border(bottom: BorderSide(color: colorOutlineVariant, width: 0.5)),
                            ),
                            children: [
                              _buildTableHeaderCell("USUARIO"),
                              _buildTableHeaderCell("ROL"),
                              _buildTableHeaderCell("ESTADO"),
                              _buildTableHeaderCell("ÚLTIMO ACCESO"),
                              _buildTableHeaderCell("ACCIONES", alignRight: true),
                            ],
                          ),
                          if (filtered.isNotEmpty)
                            ...filtered.map((item) => TableRow(
                                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: colorOutlineVariant, width: 0.5))),
                                  children: [
                                    _buildUserCell(item),
                                    _buildRoleCell(item),
                                    _buildStatusCell(item),
                                    _buildLastAccessCell(item),
                                    _buildActionsCell(item),
                                  ],
                                )),
                        ],
                      ),
                      if (filtered.isEmpty) _buildEmptyState(),
                    ],
                  ),
                ),
              );
            },
          ),
          _buildPaginationFooter(allFiltered.length, totalPages, startIndex, endIndex),
        ],
      ),
    );
  }

  Widget _buildUserCell(UserModel item) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: colorPrimary),
              clipBehavior: Clip.antiAlias,
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(item),
                    )
                  : _buildAvatarPlaceholder(item),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(color: colorOnSurface, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(item.email, style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(UserModel item) {
    return Center(
      child: Text(
        item.name.isEmpty ? "?" : item.name.substring(0, 1).toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRoleCell(UserModel item) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: UnconstrainedBox(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _getRoleBgColor(item.role), borderRadius: BorderRadius.circular(12)),
            child: Text(
              _viewModel.getRoleName(item.role),
              style: TextStyle(color: _getRoleTextColor(item.role), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCell(UserModel item) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _getStatusColor(item.status))),
            const SizedBox(width: 8),
            Text(
              item.status,
              style: TextStyle(color: item.status == "Eliminado" ? const Color(0xFFBA1A1A) : colorOnSurface, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastAccessCell(UserModel item) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(item.lastAccess, style: const TextStyle(fontFamily: 'monospace', color: colorOnSurfaceVariant, fontSize: 13)),
      ),
    );
  }

  Widget _buildActionsCell(UserModel item) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: _viewModel.selectedViewMode == 1
              ? (item.status == "Aprobado"
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Color(0xFFBA1A1A), size: 20),
                          onPressed: () => _viewModel.rejectUser(item.id),
                          tooltip: "Rechazar",
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showApproveRequestDialog(context, item),
                          icon: const Icon(Icons.check, size: 14),
                          label: const Text("Aprobar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ],
                    ))
              : ElevatedButton(
                  onPressed: () => _showEditUserDialog(context, item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCFE2F9),
                    foregroundColor: const Color(0xFF526478),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text("Editar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: const Column(
        children: [
          Icon(Icons.people_outline, size: 40, color: colorOutlineVariant),
          SizedBox(height: 8),
          Text("No se encontraron usuarios", style: TextStyle(color: colorOnSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(int totalRecords, int totalPages, int startIndex, int endIndex) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            totalRecords == 0 ? "Sin registros" : "Mostrando ${startIndex + 1}-$endIndex de $totalRecords usuarios",
            style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 13),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 18),
                onPressed: _viewModel.currentPage > 0 ? () => _viewModel.setCurrentPage(_viewModel.currentPage - 1) : null,
              ),
              ...List.generate(totalPages, (index) {
                final bool isSelected = index == _viewModel.currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: isSelected
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(4)),
                          child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        )
                      : TextButton(
                          onPressed: () => _viewModel.setCurrentPage(index),
                          child: Text("${index + 1}", style: const TextStyle(color: colorOnSurface, fontSize: 13)),
                        ),
                );
              }),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                onPressed: _viewModel.currentPage < totalPages - 1 ? () => _viewModel.setCurrentPage(_viewModel.currentPage + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableTabItem(String label, int mode, int count) {
    final bool isSelected = _viewModel.selectedViewMode == mode;
    return InkWell(
      onTap: () => _viewModel.setSelectedViewMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? colorPrimary : Colors.transparent, width: 2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorPrimary : colorOnSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? colorPrimary.withValues(alpha: 0.1) : colorOutlineVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: TextStyle(color: isSelected ? colorPrimary : colorOnSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String label, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        label,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildPermissionsGuideCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.6)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildLeftProfilePanel()),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(border: Border(left: BorderSide(color: colorOutlineVariant.withValues(alpha: 0.6), width: 1))),
                    child: _buildRightOptionsPanel(),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLeftProfilePanel(),
                Divider(height: 1, thickness: 1, color: colorOutlineVariant.withValues(alpha: 0.6)),
                _buildRightOptionsPanel(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildLeftProfilePanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("GESTIÓN DE PERFILES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: colorOnSurfaceVariant)),
          const SizedBox(height: 16),
          TextField(
            controller: _profileNameController,
            decoration: InputDecoration(
              labelText: "Nombre del Perfil",
              hintText: "Ej: Supervisor",
              isDense: true,
              filled: true,
              fillColor: colorSurfaceContainerLow.withValues(alpha: 0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorOutlineVariant.withValues(alpha: 0.5))),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              final name = _profileNameController.text.trim();
              if (name.isEmpty) return;
              _viewModel.addLocalProfile(name);
              _profileNameController.clear();
            },
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text("CREAR PERFIL"),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 32),
          const Text("PERFILES GUARDADOS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: colorOnSurfaceVariant)),
          const SizedBox(height: 12),
          if (_viewModel.profiles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text("No hay perfiles creados", style: TextStyle(fontStyle: FontStyle.italic, color: colorOnSurfaceVariant, fontSize: 13), textAlign: TextAlign.center),
            )
          else
            ...List.generate(_viewModel.profiles.length, (index) {
              return _buildProfileListItem(index, _viewModel.profiles[index].name, isSelected: index == _viewModel.selectedProfileIndex);
            }),
        ],
      ),
    );
  }

  Widget _buildProfileListItem(int index, String title, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? colorPrimary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? colorPrimary.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(Icons.badge_outlined, color: isSelected ? colorPrimary : colorOnSurfaceVariant, size: 18),
        title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? colorPrimary : colorOnSurface, fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) const Icon(Icons.check_circle, color: colorPrimary, size: 16),
            const SizedBox(width: 8),
            if (_viewModel.profiles[index].id != RoleConstants.adminMasterId && _viewModel.profiles[index].id != RoleConstants.adminId)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)),
                onPressed: () => _confirmDeleteProfile(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
              ),
          ],
        ),
        onTap: () => _viewModel.setSelectedProfileIndex(index),
      ),
    );
  }

  Future<void> _confirmDeleteProfile(int index) async {
    final profile = _viewModel.profiles[index];
    final bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Perfil"),
        content: Text("¿Estás seguro de que deseas eliminar el perfil '${profile.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await _viewModel.deleteProfile(index);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil eliminado correctamente")));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al eliminar perfil: $e")));
      }
    }
  }

  Widget _buildRightOptionsPanel() {
    final profile = _viewModel.currentProfile;
    if (profile == null) {
      return Container(
        padding: const EdgeInsets.all(48),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings_outlined, size: 48, color: colorOutlineVariant),
              SizedBox(height: 16),
              Text("No hay perfiles", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorOnSurfaceVariant)),
              Text("Crea un perfil en el panel izquierdo para configurar accesos.", style: TextStyle(fontSize: 13, color: colorOnSurfaceVariant), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_suggest_outlined, color: colorPrimary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        "CONFIGURACIÓN: ${profile.name.toUpperCase()}", 
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1, color: colorOnSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16, color: colorPrimary),
                      onPressed: () => _showEditProfileNameDialog(context, profile),
                      tooltip: "Renombrar Perfil",
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  try {
                    await _viewModel.saveProfile(profile);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Cambios guardados para ${profile.name}"), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF10B981)),
                      );
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
                  }
                },
                icon: const Icon(Icons.save_as_outlined, size: 16),
                label: const Text("Guardar Cambios", style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildModularRow(profile, "Inventario", ["Ver datos", "Crear dañados"]),
          const Divider(height: 24),
          _buildModularRow(profile, "Nuevo Artículo", ["Guardar datos"]),
          const Divider(height: 24),
          _buildModularRow(profile, "Modificar Artículo", ["Modificar datos"]),
          const Divider(height: 24),
          _buildModularRow(profile, "Ventas", ["Crear venta", "Crear oferta", "Modificar ventas"]),
          const Divider(height: 24),
          _buildModularRow(profile, "Notificaciones", ["Visualizar datos"]),
          const Divider(height: 24),
          _buildModularRow(profile, "Cierre", ["Visualizar datos", "Crear Egresos", "Editar datos", "Crear cierre del dia"]),
        ],
      ),
    );
  }

  Widget _buildModularRow(UserProfileConfig profile, String title, List<String> permissions) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;
        final moduleHeader = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 4, height: 18, decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8, color: colorOnSurface)),
          ],
        );

        final wrapPermissions = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: permissions.map((perm) {
            final isChecked = profile.permissions[title]?.contains(perm) ?? false;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5))),
              child: InkWell(
                onTap: () => _viewModel.togglePermission(profile, title, perm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (val) => _viewModel.togglePermission(profile, title, perm),
                        activeColor: colorPrimary,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(perm, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorOnSurfaceVariant)),
                  ],
                ),
              ),
            );
          }).toList(),
        );

        if (isWide) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 200, child: Padding(padding: const EdgeInsets.only(top: 8), child: moduleHeader)),
            Expanded(child: wrapPermissions),
          ]);
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [moduleHeader, const SizedBox(height: 16), wrapPermissions]);
      },
    );
  }

  Widget _buildSecurityAuditCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: colorPrimary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Stack(
        children: [
          Positioned(right: -10, bottom: -10, child: Icon(Icons.shield_outlined, color: Colors.white.withValues(alpha: 0.08), size: 80)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Auditoría", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Historial de accesos", style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showAuditLogsDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                  minimumSize: const Size(0, 32),
                ),
                child: const Center(child: Text("Ver Logs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showApproveRequestDialog(BuildContext context, UserModel user) {
    UserProfileConfig? selectedProf;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorSurfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
                    child: const Icon(Icons.how_to_reg, color: Color(0xFF10B981), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text("Aprobar Usuario", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Estás a punto de autorizar el acceso de ${user.name} (${user.email}) al sistema.", style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 20),
                  const Text("ASIGNAR PERFIL:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorOnSurfaceVariant, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  if (_viewModel.profiles.isEmpty)
                    const Text("No hay perfiles configurados. Crea uno primero.", style: TextStyle(color: Color(0xFFB91C1C), fontSize: 13))
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: SingleChildScrollView(
                        child: Column(
                          children: _viewModel.profiles.map((p) {
                            final isSelected = selectedProf?.id == p.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => setDialogState(() => selectedProf = p),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected ? colorPrimary.withValues(alpha: 0.06) : colorSurfaceContainerLow.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isSelected ? colorPrimary : colorOutlineVariant.withValues(alpha: 0.4), width: isSelected ? 1.5 : 1.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.badge_outlined, size: 20, color: isSelected ? colorPrimary : colorOnSurfaceVariant),
                                      const SizedBox(width: 16),
                                      Expanded(child: Text(p.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? colorPrimary : colorOnSurface, fontSize: 14))),
                                      if (isSelected) const Icon(Icons.check_circle, color: colorPrimary, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: selectedProf == null
                      ? null
                      : () async {
                          try {
                            await _viewModel.approveUser(user, selectedProf!.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuario aprobado con éxito")));
                            }
                          } catch (e) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                          }
                        },
                  child: const Text("Confirmar Aprobación"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    UserProfileConfig? selectedProf = _viewModel.profiles.cast<UserProfileConfig?>().firstWhere(
      (p) => p?.id == user.role,
      orElse: () => null,
    );
    String selectedStatus = user.status;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorSurfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colorPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.edit_note, color: colorPrimary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text("Editar Usuario", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Modificando accesos para ${user.name}", style: const TextStyle(fontSize: 13, color: colorOnSurfaceVariant)),
                    const SizedBox(height: 24),
                    
                    const Text("ESTADO DE CUENTA:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorOnSurfaceVariant, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    if (user.role == RoleConstants.adminMasterId)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFFD8A8))),
                        child: const Row(children: [Icon(Icons.warning_amber_rounded, color: Color(0xFFE67E22), size: 16), SizedBox(width: 8), Expanded(child: Text("El usuario principal no puede ser suspendido. Para quitar este privilegio, transfiere el rol a otro usuario.", style: TextStyle(color: Color(0xFFB95E04), fontSize: 11, fontStyle: FontStyle.italic)))]),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: ["Activo", "suspendido"].contains(selectedStatus) ? selectedStatus : "Activo",
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorOutlineVariant.withValues(alpha: 0.5))),
                        ),
                      items: ["Activo", "suspendido"].map((st) {
                        return DropdownMenuItem(
                          value: st,
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _getStatusColor(st))),
                              const SizedBox(width: 8),
                              Text(
                                st == "suspendido" ? "Suspendido" : st,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedStatus = val);
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    const Text("ASIGNAR PERFIL (ROL):", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorOnSurfaceVariant, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    if (user.role == RoleConstants.adminMasterId && !_viewModel.isCurrentUserAdminMaster)
                      const Text("Admin Master (Rol bloqueado)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorPrimary))
                    else if (_viewModel.assignableRoles.isEmpty)
                      const Text("No hay perfiles configurados.", style: TextStyle(color: Color(0xFFB91C1C), fontSize: 13))
                    else
                      DropdownButtonFormField<String>(
                        initialValue: selectedProf?.id,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorOutlineVariant.withValues(alpha: 0.5))),
                        ),
                        items: _viewModel.assignableRoles.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedProf = _viewModel.assignableRoles.firstWhere((p) => p.id == val);
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: (selectedProf?.id == user.role && selectedStatus == user.status) || (user.role == RoleConstants.adminMasterId && !_viewModel.isCurrentUserAdminMaster)
                      ? null
                      : () async {
                          if (selectedProf?.id == RoleConstants.adminMasterId && user.role != RoleConstants.adminMasterId) {
                             final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                   title: const Text("⚠ TRANSFERENCIA DE PODER", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                   content: const Text("Estás a punto de transferir tu rol de 'Admin Master'. Al confirmar, perderás tus privilegios absolutos de forma irreversible y volverás a ser un Admin normal. ¿Estás absolutamente seguro?"),
                                   actions: [
                                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar")),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(c, true), 
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                        child: const Text("Sí, Transferir"),
                                      ),
                                   ]
                                )
                             );
                             if (confirm != true) return;
                          }

                          try {
                            await _viewModel.updateUser(
                              user.id, 
                              roleId: selectedProf?.id, 
                              status: selectedStatus,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuario actualizado con éxito")));
                            }
                          } catch (e) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                          }
                        },
                  child: const Text("Guardar Cambios"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditProfileNameDialog(BuildContext context, UserProfileConfig profile) async {
    final TextEditingController nameController = TextEditingController(text: profile.name);
    final formKey = GlobalKey<FormState>();

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Renombrar Perfil"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nuevo Nombre"),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return "El nombre no puede estar vacío";
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, foregroundColor: Colors.white),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final newName = nameController.text.trim();
      if (newName != profile.name) {
        profile.name = newName;
        try {
          await _viewModel.saveProfile(profile);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Perfil renombrado con éxito"), backgroundColor: Color(0xFF10B981)),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error al renombrar: $e"), backgroundColor: Colors.red),
            );
          }
        }
      }
    }
  }
  void _showAuditLogsDialog(BuildContext context) {
    // Implementación simplificada o pendiente de refactor
  }

  // Helpers de colores (se mantienen igual o se mueven a un tema)
  Color _getRoleBgColor(String roleId) {
    final name = _viewModel.getRoleName(roleId);
    switch (name) {
      case "Administrator": return const Color(0xFFCCE5FF);
      case "Manager": return const Color(0xFFCFE2F9);
      case "Editor": return const Color(0xFFDFE3E4);
      case "Pendiente": return const Color(0xFFFFEDC8);
      default: return const Color(0xFFE0E3E8);
    }
  }

  Color _getRoleTextColor(String roleId) {
    final name = _viewModel.getRoleName(roleId);
    switch (name) {
      case "Administrator": return const Color(0xFF001D31);
      case "Manager": return const Color(0xFF001D31);
      case "Editor": return const Color(0xFF181C20);
      case "Pendiente": return const Color(0xFF8E6A00);
      default: return const Color(0xFF3F4850);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Activo": return const Color(0xFF10B981);
      case "Aprobado": return const Color(0xFF10B981);
      case "suspendido": return const Color(0xFFE67E22);
      case "Pendiente": return const Color(0xFFF59E0B);
      default: return Colors.grey;
    }
  }
}
