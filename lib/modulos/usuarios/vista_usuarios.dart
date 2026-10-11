import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'modelos_usuarios.dart';
import 'viewmodel_usuarios.dart';
import 'package:confianza_admin/core/config/role_constants.dart';
import 'widgets/crear_usuario_dialog.dart';

class VistaUsuarios extends ConsumerStatefulWidget {
  const VistaUsuarios({super.key});

  @override
  ConsumerState<VistaUsuarios> createState() => _VistaUsuariosState();
}

class _VistaUsuariosState extends ConsumerState<VistaUsuarios> {
  // Paleta de colores consistente de la marca
  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorOnSurface = Color(0xFF181C20);
  static const Color colorOnSurfaceVariant = Color(0xFF3F4850);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);
  static const Color colorSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color colorSurfaceContainerLow = Color(0xFFF1F4FA);

  static const Map<String, List<String>> _modulosPermisos = {
    "Inventario": ["Ver datos", "Carrito", "Crear dañados"],
    "Nuevo Artículo": ["Guardar datos"],
    "Modificar Artículo": ["Modificar datos"],
    "Ventas": ["Crear venta", "Crear oferta", "Modificar ventas"],
    "Notificaciones": ["Visualizar datos"],
    "Cierre": [
      "Visualizar datos",
      "Crear Egresos",
      "Editar datos",
      "Crear cierre del dia",
    ],
  };

  IconData _getModuleIcon(String module) {
    switch (module) {
      case "Inventario":
        return Icons.inventory_outlined;
      case "Nuevo Artículo":
        return Icons.add_box_outlined;
      case "Modificar Artículo":
        return Icons.edit_note_outlined;
      case "Ventas":
        return Icons.shopping_cart_outlined;
      case "Notificaciones":
        return Icons.notifications_active_outlined;
      case "Cierre":
        return Icons.point_of_sale;
      default:
        return Icons.security_outlined;
    }
  }

  ViewModelUsuarios get _viewModel =>
      ref.read(usuariosViewModelProvider.notifier);

  UserModel? _selectedUser;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _profileNameController = TextEditingController();

  void _selectUser(UserModel user) {
    setState(() {
      _selectedUser = user;
    });
    _viewModel.selectProfileByRole(user.role);
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref
          .read(usuariosViewModelProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
  }

  String? _currentEditName;
  String? _currentEditProfileId;

  String _getActiveName(UserProfileConfig profile) {
    if (_currentEditProfileId == profile.id && _currentEditName != null) {
      return _currentEditName!;
    }
    return profile.name;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _profileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado base para forzar redibujos cuando notifyListeners (state++) es llamado
    final _ = ref.watch(usuariosViewModelProvider);

    // Escuchamos el estado general y dejamos la estructura intacta

    return AdminLayout(
      activeRoute: '/usuarios',
      title: 'Usuarios',
      notifications: const [],
      centerWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderStatCard(
            title: "Total Usuarios",
            value: "${_viewModel.users.length}",
            subtitle: "Nuevos este mes",
            icon: Icons.group,
            iconColor: colorPrimary,
            iconBgColor: const Color(0xFFCCE5FF),
            subtitleColor: const Color(0xFF10B981),
            isTrend: true,
          ),
          const SizedBox(width: 12),
          _buildHeaderStatCard(
            title: "Sesiones Activas",
            value: "0",
            subtitle: "Tiempo real",
            icon: Icons.bolt,
            iconColor: const Color(0xFF4E6073),
            iconBgColor: const Color(0xFFD1E4FB),
            subtitleColor: colorOnSurfaceVariant,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          final listWidth = constraints.maxWidth * 0.3 < 350
              ? 350.0
              : constraints.maxWidth * 0.3;

          if (isMobile) {
            return Column(
              children: [
                Expanded(
                  child: _buildDataTableCard(context, constraints.maxWidth),
                ),
                const SizedBox(height: 12),
                Expanded(
                  flex: 2,
                  child: _buildPermissionsGuideCard(constraints.maxWidth),
                ),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.only(
              left: 0,
              right: 12,
              top: 0,
              bottom: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: listWidth,
                  child: _buildDataTableCard(context, listWidth),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildPermissionsGuideCard(
                      constraints.maxWidth - listWidth - 24,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderStatCard({
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
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: colorOnSurfaceVariant,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: colorOnSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isTrend) ...[
                    Icon(Icons.trending_up, color: subtitleColor, size: 11),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
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

  Widget _buildTabButton(int mode, String label) {
    final isSelected = _viewModel.selectedViewMode == mode;
    return GestureDetector(
      onTap: () {
        _viewModel.setSelectedViewMode(mode);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorOutlineVariant.withValues(alpha: 0.25)
              : colorOutlineVariant.withValues(alpha: 0.1),
          border: Border(
            bottom: BorderSide(
              color: isSelected ? colorPrimary : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colorPrimary : colorOnSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTableCard(BuildContext context, double cardWidth) {
    final allFiltered = _viewModel.filteredUsers;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: colorOutlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Pestañas (estilo idéntico a vista cierre)
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorOutlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton(0, "Activos")),
                Expanded(child: _buildTabButton(2, "Suspendidos")),
              ],
            ),
          ),

          // Buscador integrado
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: colorSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: "Buscar usuario...",
                        hintStyle: TextStyle(
                          color: colorOnSurfaceVariant,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: colorOnSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 9),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (c) => const CrearUsuarioDialog(),
                  ),
                  tooltip: "Crear Usuario",
                  icon: const Icon(
                    Icons.person_add,
                    color: colorPrimary,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorSurfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de usuarios en tarjetas
          Expanded(
            child: allFiltered.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    itemCount: allFiltered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = allFiltered[index];
                      final isSelected = _selectedUser?.id == item.id;

                      return Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorPrimary.withValues(alpha: 0.08)
                              : colorSurfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? colorPrimary
                                : colorOutlineVariant.withValues(alpha: 0.5),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isSelected ? 0.04 : 0.02,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _selectUser(item),
                            onDoubleTap: () {
                              _selectUser(item);
                              _showEditUserDialog(context, item);
                            },
                            onLongPress: () {
                              _selectUser(item);
                              _showEditUserDialog(context, item);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorPrimary,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: item.imageUrl.isNotEmpty
                                            ? Image.network(
                                                item.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) =>
                                                        _buildAvatarPlaceholder(
                                                          item,
                                                        ),
                                              )
                                            : _buildAvatarPlaceholder(item),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? colorPrimary
                                                    : colorOnSurface,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item.email,
                                              style: const TextStyle(
                                                color: colorOnSurfaceVariant,
                                                fontSize: 11.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                            color: colorOnSurfaceVariant,
                                          ),
                                          tooltip: "Editar Usuario",
                                          onPressed: () {
                                            _selectUser(item);
                                            _showEditUserDialog(context, item);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: colorOutlineVariant.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getRoleBgColor(item.role),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          _viewModel.getRoleName(item.role),
                                          style: TextStyle(
                                            color: _getRoleTextColor(item.role),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _formatFechaIngreso(
                                              item.lastAccess,
                                            ),
                                            style: const TextStyle(
                                              color: colorOnSurfaceVariant,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(UserModel item) {
    return Center(
      child: Text(
        item.name.isEmpty ? "?" : item.name.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
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
          Text(
            "No se encontraron usuarios",
            style: TextStyle(color: colorOnSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsGuideCard(double cardWidth) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.6)),
      ),
      child: Builder(
        builder: (context) {
          final isWide = cardWidth > 450;
          final rightPanelWidth = isWide ? (cardWidth * 2 / 3) : cardWidth;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildLeftProfilePanel()),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: colorOutlineVariant.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildRightOptionsPanel(rightPanelWidth),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 1, child: _buildLeftProfilePanel()),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorOutlineVariant.withValues(alpha: 0.6),
                ),
                Expanded(
                  flex: 2,
                  child: _buildRightOptionsPanel(rightPanelWidth),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildLeftProfilePanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "PERFILES GUARDADOS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: colorOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (_viewModel.profiles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "No hay perfiles creados",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: colorOnSurfaceVariant,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...List.generate(_viewModel.profiles.length, (index) {
              return _buildProfileListItem(
                index,
                _viewModel.profiles[index].name,
                isSelected: index == _viewModel.selectedProfileIndex,
              );
            }),
        ],
      ),
    );
  }

  void _confirmDeleteProfile(int index) {
    final profile = _viewModel.profiles[index];
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Eliminar Perfil"),
        content: Text(
          "¿Estás seguro de que deseas eliminar el perfil '${profile.name}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(c);
              await _viewModel.deleteProfile(index);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Perfil eliminado exitosamente"),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
            ),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileListItem(
    int index,
    String title, {
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? colorPrimary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? colorPrimary.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colorPrimary : colorOnSurface,
            fontSize: 14,
          ),
        ),
        trailing:
            isSelected &&
                _viewModel.profiles[index].id != RoleConstants.adminMasterId
            ? IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFBA1A1A),
                  size: 20,
                ),
                onPressed: () => _confirmDeleteProfile(index),
              )
            : null,
        onTap: () => _viewModel.setSelectedProfileIndex(index),
      ),
    );
  }

  Widget _buildRightOptionsPanel(double panelWidth) {
    final profile = _viewModel.currentProfile;
    if (profile == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 48,
                color: colorOutlineVariant,
              ),
              const SizedBox(height: 16),
              const Text(
                "No hay perfiles",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorOnSurfaceVariant,
                ),
              ),
              const Text(
                "No hay perfiles configurados.",
                style: TextStyle(fontSize: 13, color: colorOnSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _viewModel.addLocalProfile("Nuevo Perfil"),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text(
                  "CREAR PERFIL",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Icon(
                Icons.settings_suggest_outlined,
                color: colorPrimary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: profile.name,
                  key: ValueKey("profile_name_${profile.id}"),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1,
                    color: colorOnSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: "Nombre del Perfil",
                    isDense: true,
                    filled: true,
                    fillColor: colorSurfaceContainerLow.withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: colorOutlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: colorOutlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    _currentEditName = val;
                    _currentEditProfileId = profile.id;
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  final newName = _getActiveName(profile).trim();
                  if (newName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("El nombre no puede estar vacío"),
                      ),
                    );
                    return;
                  }
                  if (_viewModel.profiles.any(
                    (p) =>
                        p.name.toLowerCase() == newName.toLowerCase() &&
                        p.id != profile.id,
                  )) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Ya existe un perfil con ese nombre"),
                      ),
                    );
                    return;
                  }
                  _currentEditName = null;
                  _currentEditProfileId = null;
                  _viewModel.addLocalProfile(newName);
                },
                icon: const Icon(Icons.add_circle_outline, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: colorSurfaceContainerLow,
                  foregroundColor: colorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () async {
                  final newName = _getActiveName(profile).trim();
                  if (newName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("El nombre no puede estar vacío"),
                      ),
                    );
                    return;
                  }
                  if (_viewModel.profiles.any(
                    (p) =>
                        p.name.toLowerCase() == newName.toLowerCase() &&
                        p.id != profile.id,
                  )) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Ya existe un perfil con ese nombre"),
                      ),
                    );
                    return;
                  }

                  profile.name = newName;

                  try {
                    await _viewModel.saveProfile(profile);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Cambios guardados para ${profile.name}",
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al guardar: $e")),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.save_outlined, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: colorOutlineVariant),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._modulosPermisos.entries.map((entry) {
                  return _buildModulePermissionSection(
                    profile,
                    entry.key,
                    entry.value,
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModulePermissionSection(
    UserProfileConfig profile,
    String moduleTitle,
    List<String> permissions,
  ) {
    final granted = profile.permissions[moduleTitle] ?? <String>{};
    final activeCount = permissions.where((p) => granted.contains(p)).length;
    final totalCount = permissions.length;

    // Agrupar permisos de 2 en 2
    final List<List<String>> pairs = [];
    for (int i = 0; i < permissions.length; i += 2) {
      pairs.add(
        permissions.sublist(
          i,
          (i + 2 <= permissions.length) ? i + 2 : permissions.length,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado de la categoría / módulo compacto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.0),
            decoration: BoxDecoration(
              color: colorSurfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  _getModuleIcon(moduleTitle),
                  color: colorPrimary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    moduleTitle.toUpperCase(),
                    style: const TextStyle(
                      color: colorPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: colorPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "$activeCount de $totalCount activos",
                    style: const TextStyle(
                      color: colorPrimary,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de permisos organizada de 2 en 2
          ...pairs.asMap().entries.map((entry) {
            final idx = entry.key;
            final pair = entry.value;
            final isLastPair = idx == pairs.length - 1;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildPermissionItem(
                        profile,
                        moduleTitle,
                        pair[0],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: pair.length > 1
                          ? _buildPermissionItem(profile, moduleTitle, pair[1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                if (!isLastPair)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: colorOutlineVariant.withValues(alpha: 0.2),
                    indent: 6,
                    endIndent: 6,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(
    UserProfileConfig profile,
    String moduleTitle,
    String perm,
  ) {
    final granted = profile.permissions[moduleTitle] ?? <String>{};
    final isChecked = granted.contains(perm);

    return InkWell(
      onTap: () {
        _viewModel.togglePermission(profile, moduleTitle, perm);
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: SizedBox(
          height: 35,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  perm,
                  style: TextStyle(
                    color: isChecked ? colorOnSurface : colorOnSurfaceVariant,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 22,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Switch(
                    value: isChecked,
                    onChanged: (val) {
                      _viewModel.togglePermission(profile, moduleTitle, perm);
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: colorPrimary,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: colorOutlineVariant.withValues(
                      alpha: 0.4,
                    ),
                    trackOutlineColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.transparent,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    UserProfileConfig? selectedProf = _viewModel.profiles
        .cast<UserProfileConfig?>()
        .firstWhere((p) => p?.id == user.role, orElse: () => null);
    String selectedStatus = user.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorSurfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_note,
                      color: colorPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Editar Usuario",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Modificando accesos para ${user.name}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "ESTADO DE CUENTA:",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorOnSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (user.role == RoleConstants.adminMasterId)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFD8A8)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFE67E22),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "El usuario principal no puede ser suspendido. Para quitar este privilegio, transfiere el rol a otro usuario.",
                                style: TextStyle(
                                  color: Color(0xFFB95E04),
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue:
                            ["Activo", "suspendido"].contains(selectedStatus)
                            ? selectedStatus
                            : "Activo",
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        items: ["Activo", "suspendido"].map((st) {
                          return DropdownMenuItem(
                            value: st,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getStatusColor(st),
                                  ),
                                ),
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
                          if (val != null) {
                            setDialogState(() => selectedStatus = val);
                          }
                        },
                      ),

                    const SizedBox(height: 20),

                    const Text(
                      "ASIGNAR PERFIL (ROL):",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorOnSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (user.role == RoleConstants.adminMasterId)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorOutlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: colorPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedProf?.name ??
                                    "Admin Master (Rol protegido)",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colorPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_viewModel.assignableRoles.isEmpty)
                      const Text(
                        "No hay perfiles configurados.",
                        style: TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 13,
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: selectedProf?.id,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        items: _viewModel.assignableRoles.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              p.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedProf = _viewModel.assignableRoles
                                   .firstWhere((p) => p.id == val);
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      (selectedProf?.id == user.role &&
                              selectedStatus == user.status) ||
                          user.role == RoleConstants.adminMasterId
                      ? null
                      : () async {
                          if (selectedProf?.id == RoleConstants.adminMasterId &&
                              user.role != RoleConstants.adminMasterId) {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text(
                                  "⚠ TRANSFERENCIA DE PODER",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: const Text(
                                  "Estás a punto de transferir tu rol de 'Admin Master'. Al confirmar, perderás tus privilegios absolutos de forma irreversible y volverás a ser un Admin normal. ¿Estás absolutamente seguro?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: const Text("Cancelar"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Sí, Transferir"),
                                  ),
                                ],
                              ),
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
                              if (_selectedUser?.id == user.id &&
                                  selectedProf?.id != null) {
                                _selectUser(
                                  user.copyWith(
                                    role: selectedProf!.id,
                                    status: selectedStatus,
                                  ),
                                );
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Usuario actualizado con éxito",
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
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

  // Helpers de colores (se mantienen igual o se mueven a un tema)
  Color _getRoleBgColor(String roleId) {
    final name = _viewModel.getRoleName(roleId);
    switch (name) {
      case "Administrator":
        return const Color(0xFFCCE5FF);
      case "Manager":
        return const Color(0xFFCFE2F9);
      case "Editor":
        return const Color(0xFFDFE3E4);
      case "Pendiente":
        return const Color(0xFFFFEDC8);
      default:
        return const Color(0xFFE0E3E8);
    }
  }

  Color _getRoleTextColor(String roleId) {
    final name = _viewModel.getRoleName(roleId);
    switch (name) {
      case "Administrator":
        return const Color(0xFF001D31);
      case "Manager":
        return const Color(0xFF001D31);
      case "Editor":
        return const Color(0xFF181C20);
      case "Pendiente":
        return const Color(0xFF8E6A00);
      default:
        return const Color(0xFF3F4850);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Activo":
        return const Color(0xFF10B981);
      case "Aprobado":
        return const Color(0xFF10B981);
      case "suspendido":
        return const Color(0xFFE67E22);
      case "Pendiente":
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  String _formatFechaIngreso(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return "Sin fecha";
    try {
      final dt = DateTime.tryParse(trimmed);
      if (dt != null) {
        return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
      }
    } catch (_) {}
    if (trimmed.contains('T')) {
      final parts = trimmed.split('T').first.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    }
    if (trimmed.contains(' ')) {
      final datePart = trimmed.split(' ').first;
      final parts = datePart.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    }
    return trimmed;
  }
}
