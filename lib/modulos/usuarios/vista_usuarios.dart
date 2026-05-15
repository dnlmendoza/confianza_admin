import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';

/// Modelo de datos para un Usuario
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // "Administrator", "Manager", "Editor", "Viewer"
  final String status; // "Active", "Offline", "Suspended"
  final String lastAccess;
  final String imageUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastAccess,
    required this.imageUrl,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? status,
    String? lastAccess,
    String? imageUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      lastAccess: lastAccess ?? this.lastAccess,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> json, String id, {required bool isRequest}) {
    final String nombres = json['Nombres'] as String? ?? '';
    final String apellidos = json['Apellidos'] as String? ?? '';
    final String name = '$nombres $apellidos'.trim();
    
    // Imprimir llaves del documento para depuración del desarrollador
    debugPrint("Firestore Keys for user '$name': ${json.keys.toList()}");
    if (json.containsKey('FotoUrl') || json.containsKey('fotoUrl')) {
      debugPrint("Image URL value detected: ${json['FotoUrl'] ?? json['fotoUrl']}");
    }

    // Buscar el primer valor que no sea nulo entre variantes comunes de nombres de campo
    final Object? possibleUrl = json['FotoUrl'] ?? 
                                json['fotoUrl'] ?? 
                                json['fotourl'] ?? 
                                json['Foto'] ?? 
                                json['foto'] ?? 
                                json['Imagen'];
                                
    final String rawUrl = possibleUrl?.toString().trim() ?? '';
    
    return UserModel(
      id: id,
      name: name.isEmpty ? 'Sin nombre' : name,
      email: json['Idcorreo'] as String? ?? json['Correo'] as String? ?? '',
      role: json['Rol'] as String? ?? (isRequest ? 'Pendiente' : 'Sin Rol'),
      status: isRequest ? 'pendiente' : (json['Estado'] as String? ?? 'Activo'),
      lastAccess: json['Fecha'] as String? ?? '',
      imageUrl: rawUrl,
    );
  }
}

/// Modelo de datos para un Registro de Auditoría
class AuditLog {
  final String time;
  final String user;
  final String action;

  const AuditLog({
    required this.time,
    required this.user,
    required this.action,
  });
}

/// Modelo de datos para la gestión lógica de perfiles de usuario
class UserProfileConfig {
  final String id;
  String name;
  final Map<String, Set<String>> permissions;

  UserProfileConfig({
    required this.id,
    required this.name,
    required this.permissions,
  });
}

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

  // Estados interactivos
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = "Todos";
  int _selectedViewMode = 0; // 0 = Usuarios Activos, 1 = Solicitudes de Acceso
  int _currentPage = 0;
  static const int _itemsPerPage = 4;

  // LÓGICA DINÁMICA DE PERFILES
  final TextEditingController _profileNameController = TextEditingController();
  int _selectedProfileIndex = 0;
  final List<UserProfileConfig> _profiles = [];

  // Lista mutable de usuarios que se alimenta de Firestore
  final List<UserModel> _users = [];
  List<UserModel> _dbUsers = [];
  List<UserModel> _dbPendingUsers = [];

  StreamSubscription? _usuariosSub;
  StreamSubscription? _registroSub;

  // Lista estática de logs de auditoría para el diálogo
  final List<AuditLog> _auditLogs = [];

  @override
  void initState() {
    super.initState();
    _listenToUsers();
  }

  void _listenToUsers() {
    _usuariosSub = FirebaseFirestore.instance.collection('Usuarios').snapshots().listen((snapshot) {
      final usersList = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromFirestore(data, doc.id, isRequest: false);
      }).toList();
      
      if (mounted) {
        setState(() {
          _dbUsers = usersList;
          _updateCombinedUsers();
        });
      }
    });

    _registroSub = FirebaseFirestore.instance.collection('Usuarios_registro').snapshots().listen((snapshot) {
      final pendingList = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromFirestore(data, doc.id, isRequest: true);
      }).toList();
      
      if (mounted) {
        setState(() {
          _dbPendingUsers = pendingList;
          _updateCombinedUsers();
        });
      }
    });
  }

  void _updateCombinedUsers() {
    _users.clear();
    _users.addAll(_dbUsers);
    _users.addAll(_dbPendingUsers);
  }

  @override
  void dispose() {
    _usuariosSub?.cancel();
    _registroSub?.cancel();
    _searchController.dispose();
    _profileNameController.dispose();
    super.dispose();
  }

  // Filtrado reactivo en vivo
  List<UserModel> get _filteredUsers {
    final query = _searchController.text.trim().toLowerCase();
    return _users.where((item) {
      // Filtrado por el modo de vista de la tabla (Activos vs Solicitudes)
      final bool isRequest = item.status == "pendiente";
      final bool matchesViewMode =
          (_selectedViewMode == 1) ? isRequest : !isRequest;

      if (!matchesViewMode) return false;

      final matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.email.toLowerCase().contains(query);
      final matchesRole =
          _selectedRoleFilter == "Todos" || item.role == _selectedRoleFilter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _users.where((u) => u.status == "pendiente").length;
    final notifications =
        pendingCount > 0
            ? [
              pendingCount == 1
                  ? "Nueva solicitud de usuario pendiente"
                  : "$pendingCount nuevas solicitudes pendientes",
            ]
            : null;

    return AdminLayout(
      activeRoute: '/usuarios',
      title: 'Usuarios',
      notifications: notifications ?? [],
      searchController: _searchController,
      onSearchChanged: (val) {
        setState(() {
          _currentPage = 0;
        });
      },
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
          value: "${_users.length}",
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
          value: "${_users.where((u) => u.status == 'pendiente').length}",
          subtitle: "Pendientes de aprobación",
          icon: Icons.person_add_alt_1,
          iconColor: const Color(0xFF8E6A00), // Amber/Gold for pending state
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
    final allFiltered = _filteredUsers;

    // Lógica de paginación dinámica
    final totalPages =
        (allFiltered.length / _itemsPerPage).ceil() == 0
            ? 1
            : (allFiltered.length / _itemsPerPage).ceil();

    // Validar y corregir el índice actual si se queda fuera de rango tras filtros
    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
    }
    if (_currentPage < 0) _currentPage = 0;

    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex =
        (startIndex + _itemsPerPage < allFiltered.length)
            ? startIndex + _itemsPerPage
            : allFiltered.length;

    // La variable que consume el resto de la tabla
    final filtered =
        allFiltered.isEmpty
            ? <UserModel>[]
            : allFiltered.sublist(startIndex, endIndex);

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
          // Tab Switcher Maestro
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
                _buildTableTabItem(
                  "Usuarios Activos",
                  0,
                  _users.where((u) => u.status != 'pendiente').length,
                ),
                _buildTableTabItem(
                  "Solicitudes de Acceso",
                  1,
                  _users.where((u) => u.status == 'pendiente').length,
                ),
              ],
            ),
          ),
          // Filtros y Exportaciones
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
                      onChanged: (val) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: "Buscar por nombre o correo...",
                        hintStyle: TextStyle(
                          color: colorOnSurfaceVariant,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: colorOnSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botón de Filtrado por Rol
                PopupMenuButton<String>(
                  tooltip: "Filtrar por Rol",
                  onSelected: (val) {
                    setState(() {
                      _selectedRoleFilter = val;
                      _currentPage = 0;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "Todos",
                      child: Text("Todos los Roles"),
                    ),
                    const PopupMenuItem(
                      value: "Administrator",
                      child: Text("Administrator"),
                    ),
                    const PopupMenuItem(
                      value: "Manager",
                      child: Text("Manager"),
                    ),
                    const PopupMenuItem(value: "Editor", child: Text("Editor")),
                    const PopupMenuItem(value: "Viewer", child: Text("Viewer")),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorOutlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.filter_list,
                          size: 16,
                          color: colorOnSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedRoleFilter == "Todos"
                              ? "Filtrar"
                              : _selectedRoleFilter,
                          style: const TextStyle(
                            color: colorOnSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),

          // Tabla de Datos
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth > 850.0
                  ? constraints.maxWidth
                  : 850.0;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2.5), // User Info
                          1: FlexColumnWidth(1.4), // Role
                          2: FlexColumnWidth(1.2), // Status
                          3: FlexColumnWidth(1.5), // Last Access
                          4: FlexColumnWidth(2.1), // Actions
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              color: colorSurfaceContainerLow,
                              border: Border(
                                bottom: BorderSide(
                                  color: colorOutlineVariant,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            children: [
                              _buildTableHeaderCell("USUARIO"),
                              _buildTableHeaderCell(
                                _selectedViewMode == 1 ? "SOLICITUD" : "ROL",
                              ),
                              _buildTableHeaderCell("ESTADO"),
                              _buildTableHeaderCell("ÚLTIMO ACCESO"),
                              _buildTableHeaderCell(
                                _selectedViewMode == 1 ? "DECISIÓN" : "ACCIONES",
                                alignRight: true,
                              ),
                            ],
                          ),
                          if (filtered.isNotEmpty)
                            ...filtered.map((item) {
                              return TableRow(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: colorOutlineVariant,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                children: [
                                  // User Avatar + Name + Email
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 12.0,
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
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Center(
                                                        child: Text(
                                                          item.name.substring(0, 1).toUpperCase(),
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Center(
                                                    child: Text(
                                                      item.name.substring(0, 1).toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  color: colorOnSurface,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.email,
                                                style: const TextStyle(
                                                  color: colorOnSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Role Chip
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: UnconstrainedBox(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getRoleBgColor(item.role),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            item.role,
                                            style: TextStyle(
                                              color: _getRoleTextColor(item.role),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Status Dot + Label
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _getStatusColor(item.status),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item.status,
                                            style: TextStyle(
                                              color: item.status == "Eliminado"
                                                  ? const Color(0xFFBA1A1A)
                                                  : colorOnSurface,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Last Access Time
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Text(
                                        item.lastAccess,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          color: colorOnSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Actions Button
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child:
                                            _selectedViewMode == 1
                                                ? Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.cancel_outlined,
                                                        color: Color(0xFFBA1A1A),
                                                        size: 20,
                                                      ),
                                                      tooltip: "Rechazar",
                                                      onPressed: () async {
                                                        try {
                                                          await FirebaseFirestore.instance.collection('Usuarios_registro').doc(item.id).delete();
                                                        } catch (e) {
                                                          if (context.mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text("Error al rechazar: $e")),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      splashRadius: 20,
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton.icon(
                                                      onPressed:
                                                          () =>
                                                              _showApproveRequestDialog(
                                                                context,
                                                                item,
                                                              ),
                                                      icon: const Icon(
                                                        Icons.check,
                                                        size: 14,
                                                      ),
                                                      label: const Text("Aprobar"),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF10B981,
                                                                ),
                                                            foregroundColor:
                                                                Colors.white,
                                                            elevation: 0,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                  horizontal: 12,
                                                                  vertical: 6,
                                                                ),
                                                            minimumSize:
                                                                const Size(0, 32),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                            6,
                                                                          ),
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                )
                                                : ElevatedButton(
                                                  onPressed:
                                                      () => _showEditUserDialog(
                                                        context,
                                                        item,
                                                      ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFFCFE2F9,
                                                            ),
                                                        foregroundColor:
                                                            const Color(
                                                              0xFF526478,
                                                            ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                              horizontal: 16,
                                                              vertical: 6,
                                                            ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                        4,
                                                                      ),
                                                            ),
                                                        elevation: 0,
                                                      ),
                                                  child: const Text(
                                                    "Editar",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                        ],
                      ),
                      if (filtered.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 40,
                                color: colorOutlineVariant,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "No se encontraron usuarios",
                                style: TextStyle(
                                  color: colorOnSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Paginación
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  allFiltered.isEmpty
                      ? "Sin registros"
                      : "Mostrando ${allFiltered.isEmpty ? 0 : startIndex + 1}-$endIndex de ${allFiltered.length} usuarios",
                  style: const TextStyle(
                    color: colorOnSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 18),
                      onPressed:
                          _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                    ),
                    ...List.generate(totalPages, (index) {
                      final bool isSelected = index == _currentPage;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child:
                            isSelected
                                ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                                : TextButton(
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(36, 36),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed:
                                      () => setState(() => _currentPage = index),
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: colorOnSurface,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                      );
                    }),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 18),
                      onPressed:
                          _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String label, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        label,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          color: colorOnSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
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
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: colorOutlineVariant.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                    ),
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
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorOutlineVariant.withValues(alpha: 0.6),
                ),
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
          const Text(
            "GESTIÓN DE PERFILES",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: colorOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _profileNameController,
            decoration: InputDecoration(
              labelText: "Nombre del Perfil",
              hintText: "Ej: Supervisor",
              isDense: true,
              filled: true,
              fillColor: colorSurfaceContainerLow.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorOutlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              final name = _profileNameController.text.trim();
              if (name.isEmpty) return;
              setState(() {
                _profiles.add(
                  UserProfileConfig(
                    id: UniqueKey().toString(),
                    name: name,
                    permissions: {},
                  ),
                );
                _profileNameController.clear();
                // Selecciona automáticamente el nuevo
                _selectedProfileIndex = _profiles.length - 1;
              });
            },
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text("CREAR PERFIL"),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 32),
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
          if (_profiles.isEmpty)
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
            ...List.generate(_profiles.length, (index) {
              return _buildProfileListItem(
                index,
                _profiles[index].name,
                isSelected: index == _selectedProfileIndex,
              );
            }),
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
        color:
            isSelected
                ? colorPrimary.withValues(alpha: 0.08)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isSelected
                  ? colorPrimary.withValues(alpha: 0.3)
                  : Colors.transparent,
        ),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(
          Icons.badge_outlined,
          color: isSelected ? colorPrimary : colorOnSurfaceVariant,
          size: 18,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colorPrimary : colorOnSurface,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(Icons.check_circle, color: colorPrimary, size: 16),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: Color(0xFFBA1A1A),
              ),
              onPressed: () {
                setState(() {
                  _profiles.removeAt(index);
                  // Reajustar index seleccionado si es necesario
                  if (_profiles.isEmpty) {
                    _selectedProfileIndex = 0;
                  } else if (_selectedProfileIndex >= _profiles.length) {
                    _selectedProfileIndex = _profiles.length - 1;
                  }
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 18,
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedProfileIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildRightOptionsPanel() {
    if (_profiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 48,
                color: colorOutlineVariant,
              ),
              SizedBox(height: 16),
              Text(
                "No hay perfiles",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorOnSurfaceVariant,
                ),
              ),
              Text(
                "Crea un perfil en el panel izquierdo para configurar accesos.",
                style: TextStyle(fontSize: 13, color: colorOnSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final currentProfile = _profiles[_selectedProfileIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings_suggest_outlined,
                color: colorPrimary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "CONFIGURACIÓN: ${currentProfile.name.toUpperCase()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1,
                    color: colorOnSurface,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Cambios guardados para ${currentProfile.name}",
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                icon: const Icon(Icons.save_as_outlined, size: 16),
                label: const Text(
                  "Guardar Cambios",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildModularRow(currentProfile, "Inventario", ["Ver datos", "Crear dañados"]),
          const Divider(height: 24),
          _buildModularRow(currentProfile, "Nuevo Artículo", ["Guardar datos"]),
          const Divider(height: 24),
          _buildModularRow(currentProfile, "Modificar Artículo", [
            "Visualizar datos",
            "Modificar datos",
          ]),
          const Divider(height: 24),
          _buildModularRow(currentProfile, "Ventas", [
            "Crear venta",
            "Crear oferta",
          ]),
          const Divider(height: 24),
          _buildModularRow(currentProfile, "Notificaciones", [
            "Visualizar datos",
          ]),
          const Divider(height: 24),
          _buildModularRow(currentProfile, "Cierre", [
            "Visualizar datos",
            "Añadir egresos",
            "Editar datos",
            "Crear cierre del dia",
            "Modificar ventas",
          ]),
        ],
      ),
    );
  }

  Widget _buildModularRow(
    UserProfileConfig profile,
    String title,
    List<String> permissions,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;

        final moduleHeader = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.8,
                color: colorOnSurface,
              ),
            ),
          ],
        );

        final wrapPermissions = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: permissions.map((perm) {
            final isChecked =
                profile.permissions[title]?.contains(perm) ?? false;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorOutlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    final modPerms = profile.permissions;
                    if (isChecked) {
                      modPerms[title]?.remove(perm);
                    } else {
                      modPerms.putIfAbsent(title, () => {}).add(perm);
                    }
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (val) {
                          setState(() {
                            final modPerms = profile.permissions;
                            if (val == true) {
                              modPerms.putIfAbsent(title, () => {}).add(perm);
                            } else {
                              modPerms[title]?.remove(perm);
                            }
                          });
                        },
                        activeColor: colorPrimary,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      perm,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: moduleHeader,
                ),
              ),
              Expanded(child: wrapPermissions),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            moduleHeader,
            const SizedBox(height: 16),
            wrapPermissions,
          ],
        );
      },
    );
  }

  Widget _buildSecurityAuditCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                onPressed: () => _showAuditLogsDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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

  // Helpers de colores semánticos
  Color _getRoleBgColor(String role) {
    switch (role) {
      case "Administrator":
        return const Color(0xFFCCE5FF);
      case "Manager":
        return const Color(0xFFCFE2F9);
      case "Editor":
        return const Color(0xFFDFE3E4);
      case "Pendiente":
        return const Color(0xFFFFEDC8); // Amber container for pending requests
      default:
        return const Color(0xFFE0E3E8);
    }
  }

  Color _getRoleTextColor(String role) {
    switch (role) {
      case "Administrator":
        return const Color(0xFF001D31);
      case "Manager":
        return const Color(0xFF36485B);
      case "Editor":
        return const Color(0xFF434849);
      case "Pendiente":
        return const Color(0xFF8E6A00); // Dark amber for text
      default:
        return colorOnSurfaceVariant;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Activo":
        return const Color(0xFF10B981);
      case "pendiente":
        return const Color(0xFFF2994A); // Orange for pending
      case "Eliminado":
        return const Color(0xFFBA1A1A); // Red for deleted
      default:
        return colorOutlineVariant;
    }
  }
  // METODOS DE APOYO PARA GESTION DE FLUJO DE SOLICITUDES

  Widget _buildTableTabItem(String label, int index, int count) {
    final bool isSelected = _selectedViewMode == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedViewMode = index;
            _currentPage = 0; // Reset paginación al cambiar pestaña
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? colorPrimary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? colorPrimary : colorOnSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorPrimary.withValues(alpha: 0.1)
                          : colorOutlineVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colorPrimary : colorOnSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.how_to_reg,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Aprobar Usuario",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Estás a punto de autorizar el acceso de ${user.name} (${user.email}) al sistema.",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "ASIGNAR PERFIL:",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorOnSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_profiles.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "No hay perfiles configurados. Crea uno primero en la sección de Roles y Permisos.",
                        style: TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: SingleChildScrollView(
                        child: Column(
                          children:
                              _profiles.map((p) {
                                final isSelected = selectedProf?.id == p.id;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setDialogState(() {
                                          selectedProf = p;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? colorPrimary.withValues(
                                                    alpha: 0.06,
                                                  )
                                                  : colorSurfaceContainerLow
                                                      .withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? colorPrimary
                                                    : colorOutlineVariant
                                                        .withValues(alpha: 0.4),
                                            width: isSelected ? 1.5 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.badge_outlined,
                                              size: 20,
                                              color:
                                                  isSelected
                                                      ? colorPrimary
                                                      : colorOnSurfaceVariant,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                p.name,
                                                style: TextStyle(
                                                  fontWeight:
                                                      isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.w500,
                                                  color:
                                                      isSelected
                                                          ? colorPrimary
                                                          : colorOnSurface,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_circle,
                                                color: colorPrimary,
                                                size: 20,
                                              )
                                            else
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: colorOutlineVariant,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: colorOutlineVariant.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      selectedProf == null
                          ? null
                          : () async {
                            try {
                              final docRef = FirebaseFirestore.instance.collection('Usuarios_registro').doc(user.id);
                              final docSnapshot = await docRef.get();
                              
                              if (docSnapshot.exists) {
                                final data = docSnapshot.data() ?? {};
                                data['Estado'] = "Activo";
                                data['Rol'] = selectedProf!.name;
                                
                                // Persistir en Usuarios y borrar de registro
                                await FirebaseFirestore.instance.collection('Usuarios').doc(user.id).set(data);
                                await docRef.delete();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error al aprobar usuario: $e")),
                                );
                              }
                              return;
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Acceso autorizado para ${user.name} como ${selectedProf!.name}",
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                  child: const Text("Aceptar y Activar Acceso"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // DIÁLOGOS CRUD


  void _showEditUserDialog(BuildContext context, UserModel user) {
    String selectedRole = user.role;
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
              title: const Row(
                children: [
                  Icon(Icons.edit, color: colorPrimary, size: 22),
                  SizedBox(width: 12),
                  Text(
                    "Editar Perfil de Usuario",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: colorSurfaceContainerLow.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorOutlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colorPrimary,
                            foregroundImage: user.imageUrl.isNotEmpty
                                ? NetworkImage(user.imageUrl)
                                : null,
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: colorOnSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: "Rol en el Sistema",
                        labelStyle: TextStyle(fontSize: 13),
                      ),
                      items: {selectedRole, ..._profiles.map((p) => p.name)}
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedRole = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Estado",
                        labelStyle: TextStyle(fontSize: 13),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Activo",
                          child: Text("Activo"),
                        ),
                        DropdownMenuItem(
                          value: "pendiente",
                          child: Text("pendiente"),
                        ),
                        DropdownMenuItem(
                          value: "Eliminado",
                          child: Text("Eliminado"),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedStatus = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(
                      color: colorOnSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance.collection('Usuarios').doc(user.id).update({
                        'Rol': selectedRole,
                        'Estado': selectedStatus,
                      });
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error al actualizar perfil: $e")),
                        );
                      }
                      return;
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          "Perfil de '${user.name}' actualizado exitosamente.",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Guardar Cambios"),
                ),
              ],
            );
          },
        );
      },
    );
  }



  void _showAuditLogsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorSurfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: colorPrimary, size: 24),
              SizedBox(width: 12),
              Text(
                "Log de Actividad y Seguridad",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _auditLogs.length,
              separatorBuilder: (context, index) => const Divider(
                color: colorOutlineVariant,
                height: 16,
                thickness: 0.5,
              ),
              itemBuilder: (context, index) {
                final log = _auditLogs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 18,
                        color: colorOnSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: colorOnSurface,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                                children: [
                                  TextSpan(
                                    text: "${log.user} ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: log.action,
                                    style: const TextStyle(
                                      color: colorOnSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              log.time,
                              style: const TextStyle(
                                color: colorOnSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }


}

/// CABECERA SUPERIOR (Búsqueda y Perfil)
