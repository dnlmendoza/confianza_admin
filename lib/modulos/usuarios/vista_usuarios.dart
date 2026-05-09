import 'package:flutter/material.dart';
import 'package:confianza_admin/main.dart';

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

class VistaUsuarios extends StatefulWidget {
  const VistaUsuarios({super.key});

  @override
  State<VistaUsuarios> createState() => _VistaUsuariosState();
}

class _VistaUsuariosState extends State<VistaUsuarios> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Paleta de colores consistente de la marca
  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorPrimaryContainer = Color(0xFF3498db);
  static const Color colorBackground = Color(0xFFF7F9FF);
  static const Color colorOnSurface = Color(0xFF181C20);
  static const Color colorOnSurfaceVariant = Color(0xFF3F4850);
  static const Color colorInverseSurface = Color(0xFF2D3135);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);
  static const Color colorSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color colorSurfaceContainerLow = Color(0xFFF1F4FA);

  // Estados interactivos
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = "Todos";

  // Lista mutable de usuarios iniciales de la captura
  final List<UserModel> _users = [
    const UserModel(
      id: "1",
      name: "Alejandra Rodríguez",
      email: "alejandra.r@enterprise.com",
      role: "Administrator",
      status: "Active",
      lastAccess: "Hoy, 09:42 AM",
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uhDGSJL6EQq__ES4O2BHuQPLhIu-v_4g9dOUZIK7_T_C3IqAudQPDnEnlH7hHQzst4S2rPl3Mts12ht5Y-_SbdPQUu1ub7GUcjjeYWFhomHxPINBqpxAJBKO90Kswd3b-3rivbPXBAgoRs_1GjMw7pxg8GwrO_1Xbaj96ZaNyENfufKBpOtyMNO8himPTyt-B8P8C6IoXm4_AFO45XaoFL_OjYQdCZP053oRa4BQhctwEdru2Sq18tQtzpUlRRrtCpnf1nIIrF_",
    ),
    const UserModel(
      id: "2",
      name: "Carlos Mendoza",
      email: "c.mendoza@retail.pro",
      role: "Manager",
      status: "Active",
      lastAccess: "Ayer, 18:20 PM",
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uie9aXo1SLfhg9oUGqFi4nj1R8WsE7bT8hS8vdtDW1ECX8pNL-Rs-qEps1ft0cRqFODMqLGSDXutWEiHblqTxlePbkM7J1ag0U1jYhlT6NzJ91Um7oobtKxw1OsJxhJQ_7_9VfA-LFK1hQHzAgQy9y6yiGGW1MGZGnFnws73dmYfLqbK30MdXcUhAZ1WGfR1gUjpbzN19DA1IAVrbZN_jgFGMYwIMofXIqznfNk3_ib9SomYPmsyKJkn1iqRjorMszaPyTriM1KZQ",
    ),
    const UserModel(
      id: "3",
      name: "Elena Torres",
      email: "e.torres@retail.pro",
      role: "Editor",
      status: "Offline",
      lastAccess: "24 Jun, 2024",
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uh4Tj2eAXE_OWkZULpzK2h_Q8kPH-6MKNSC3wbUiSjuIeQFgke68asTEoP-OwydyJR-vHaoOza7-NbITPCUY5rVOcE1mVdRPQtX9q0SG1qsAzcLthOhHL7RXQrKwN5MUn190NZySmD45LzmuuocLrnRLtLizsFeVJg17xPdRcoksECY2NRTFBwqGF1qSGBRE0u6S_sNW2K1Y2G-WbYFAKgssRVf1iBWY9t6Y0HlbB1OPEA5Hd3iBoWqR_H4Vf3RS36pKAheDSSlQg",
    ),
    const UserModel(
      id: "4",
      name: "Julian Blanco",
      email: "j.blanco@retail.pro",
      role: "Viewer",
      status: "Suspended",
      lastAccess: "15 May, 2024",
      imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uj8I9f53CpSj40cca_fxt6KDo57B4z5FBtDqrwX6YOaNbbsU1WX7mEhu5cunyifZXLih2dswdROV7dw0Js73dJ6-qs5F2VgSeZBUVN4YFIaVu_oLsBL2c-rstYiGoQhE-uY0TM2gcuR09ryDxDAHAGOxRwKRDsshuF-3NnsAIx7hHyVwi16RaRRLlSy9jG1gnABu5nQv53OELiPWAR5XPkb_VxkSsTmeuvRyhFfaZfhzRVU6MflDLaPguo-x9gcLMgro1_ligRf5Q",
    ),
  ];

  // Lista estática de logs de auditoría para el diálogo
  final List<AuditLog> _auditLogs = const [
    AuditLog(time: "Hace 5 minutos", user: "Alejandra Rodríguez", action: "Actualizó los permisos de rol del Editor"),
    AuditLog(time: "Hace 20 minutos", user: "Carlos Mendoza", action: "Inició sesión desde un nuevo dispositivo móvil"),
    AuditLog(time: "Ayer, 03:15 PM", user: "Alejandra Rodríguez", action: "Creó el usuario Elena Torres con rol de Editor"),
    AuditLog(time: "Hace 3 días", user: "Julian Blanco", action: "Intento fallido de inicio de sesión (MFA no verificado)"),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtrado reactivo en vivo
  List<UserModel> get _filteredUsers {
    final query = _searchController.text.trim().toLowerCase();
    return _users.where((item) {
      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.email.toLowerCase().contains(query);
      final matchesRole = _selectedRoleFilter == "Todos" || item.role == _selectedRoleFilter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorBackground,
      drawer: Drawer(
        child: Container(
          color: colorInverseSurface,
          child: const _SidebarContent(isDrawer: true),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sidebar fija en escritorio
              if (isDesktop)
                SizedBox(
                  width: SidebarState.isCollapsed ? 76 : 260,
                  child: Container(
                    color: colorInverseSurface,
                    child: _SidebarContent(
                      isDrawer: false,
                      onToggleCollapse: () {
                        setState(() {
                          SidebarState.isCollapsed = !SidebarState.isCollapsed;
                        });
                      },
                    ),
                  ),
                ),

              // Área de Contenido
              Expanded(
                child: Column(
                  children: [
                    // Cabecera superior
                    _Header(
                      scaffoldKey: _scaffoldKey,
                      isDesktop: isDesktop,
                      searchController: _searchController,
                      onSearchChanged: (val) {
                        setState(() {});
                      },
                    ),

                    // Cuerpo del Gestor de Usuarios
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header del Módulo y Botón "+ Create New User"
                            _buildModuleHeader(context),
                            const SizedBox(height: 24),

                            // Bento Grid de Métricas
                            _buildBentoStatsGrid(context),
                            const SizedBox(height: 24),

                            // Tabla de Datos Principal
                            _buildDataTableCard(context),
                            const SizedBox(height: 24),

                            // Sección de Roles y Seguridad Inferior
                            _buildBottomSection(context, isDesktop),
                          ],
                        ),
                      ),
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

  Widget _buildModuleHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Gestión de Usuarios",
                style: TextStyle(color: colorOnSurface, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              SizedBox(height: 4),
              Text(
                "Administra los roles, accesos y permisos de tu equipo de trabajo.",
                style: TextStyle(color: colorOnSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showCreateUserDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 1,
          ),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text("Create New User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
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
          subtitle: "+4 este mes",
          icon: Icons.group,
          iconColor: colorPrimary,
          iconBgColor: const Color(0xFFCCE5FF),
          subtitleColor: const Color(0xFF10B981),
          isTrend: true,
        ),
        _buildBentoStatCard(
          title: "Sesiones Activas",
          value: "18",
          subtitle: "Tiempo real",
          icon: Icons.bolt,
          iconColor: const Color(0xFF4E6073),
          iconBgColor: const Color(0xFFD1E4FB),
          subtitleColor: colorOnSurfaceVariant,
        ),
        _buildBentoStatCard(
          title: "Roles Definidos",
          value: "6",
          subtitle: "Permisos granulares",
          icon: Icons.badge,
          iconColor: const Color(0xFF5A5F60),
          iconBgColor: const Color(0xFFDFE3E4),
          subtitleColor: colorOnSurfaceVariant,
        ),
        _buildBentoStatCard(
          title: "Seguridad",
          value: "98%",
          subtitle: "MFA Activo",
          icon: Icons.security,
          iconColor: const Color(0xFFBA1A1A),
          iconBgColor: const Color(0xFFFFDAD6),
          subtitleColor: const Color(0xFFBA1A1A),
        ),
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
                style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                style: const TextStyle(color: colorOnSurface, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1),
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
                    style: TextStyle(color: subtitleColor, fontSize: 11, fontWeight: FontWeight.w500),
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
    final filtered = _filteredUsers;

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
                        hintStyle: TextStyle(color: colorOnSurfaceVariant, fontSize: 13),
                        prefixIcon: Icon(Icons.search, size: 18, color: colorOnSurfaceVariant),
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
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "Todos", child: Text("Todos los Roles")),
                    const PopupMenuItem(value: "Administrator", child: Text("Administrator")),
                    const PopupMenuItem(value: "Manager", child: Text("Manager")),
                    const PopupMenuItem(value: "Editor", child: Text("Editor")),
                    const PopupMenuItem(value: "Viewer", child: Text("Viewer")),
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
                          _selectedRoleFilter == "Todos" ? "Filtrar" : _selectedRoleFilter,
                          style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botón de Exportar
                InkWell(
                  onTap: () => _simulateDataExport(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorOutlineVariant),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download, size: 16, color: colorOnSurfaceVariant),
                        SizedBox(width: 8),
                        Text(
                          "Exportar",
                          style: TextStyle(color: colorOnSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabla de Datos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 850,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),   // User Info
                  1: FlexColumnWidth(1.5), // Role
                  2: FlexColumnWidth(1.2), // Status
                  3: FlexColumnWidth(1.8), // Last Access
                  4: FlexColumnWidth(1.2), // Actions
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: colorSurfaceContainerLow,
                      border: Border(bottom: BorderSide(color: colorOutlineVariant, width: 0.5)),
                    ),
                    children: [
                      _buildTableHeaderCell("USER"),
                      _buildTableHeaderCell("ROLE"),
                      _buildTableHeaderCell("STATUS"),
                      _buildTableHeaderCell("LAST ACCESS"),
                      _buildTableHeaderCell("ACTIONS", alignRight: true),
                    ],
                  ),
                  if (filtered.isEmpty)
                    TableRow(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline, size: 40, color: colorOutlineVariant),
                              SizedBox(height: 8),
                              Text("No se encontraron usuarios", style: TextStyle(color: colorOnSurfaceVariant, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                      ],
                    )
                  else
                    ...filtered.map((item) {
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: colorOutlineVariant, width: 0.5)),
                        ),
                        children: [
                          // User Avatar + Name + Email
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: colorPrimaryContainer),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Text(
                                            item.name.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      },
                                    ),
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
                          ),

                          // Role Chip
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: UnconstrainedBox(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getRoleBgColor(item.role),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.role,
                                    style: TextStyle(color: _getRoleTextColor(item.role), fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Status Dot + Label
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: _getStatusColor(item.status)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.status,
                                    style: TextStyle(
                                      color: item.status == "Suspended" ? const Color(0xFFBA1A1A) : colorOnSurface,
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
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                item.lastAccess,
                                style: const TextStyle(fontFamily: 'monospace', color: colorOnSurfaceVariant, fontSize: 13),
                              ),
                            ),
                          ),

                          // Actions Button
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () => _showEditUserDialog(context, item),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFCFE2F9),
                                    foregroundColor: const Color(0xFF526478),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    elevation: 0,
                                  ),
                                  child: const Text("Edit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ),

          // Paginación
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mostrando 1-${filtered.length} de ${_users.length} usuarios",
                  style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 13),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 18),
                      onPressed: () {},
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(4)),
                      child: const Text("1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(width: 4),
                    TextButton(onPressed: () {}, child: const Text("2", style: TextStyle(color: colorOnSurface, fontSize: 13))),
                    TextButton(onPressed: () {}, child: const Text("3", style: TextStyle(color: colorOnSurface, fontSize: 13))),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 18),
                      onPressed: () {},
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

  Widget _buildBottomSection(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildPermissionsGuideCard()),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: _buildSecurityAuditCard(context)),
        ],
      );
    } else {
      return Column(
        children: [
          _buildPermissionsGuideCard(),
          const SizedBox(height: 24),
          _buildSecurityAuditCard(context),
        ],
      );
    }
  }

  Widget _buildPermissionsGuideCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Roles & Permisos del Sistema",
                style: TextStyle(color: colorOnSurface, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.info_outline, color: colorPrimary, size: 22),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 2.1,
            children: [
              _buildRoleGuideItem("Administrator", "Acceso total a todos los módulos, configuración del sistema y gestión de facturación."),
              _buildRoleGuideItem("Manager", "Gestión de inventario, ventas y reportes avanzados. Sin acceso a ajustes globales."),
              _buildRoleGuideItem("Editor", "Puede crear y editar productos y ventas, pero no eliminar registros maestros."),
              _buildRoleGuideItem("Viewer", "Acceso de solo lectura a tableros de control y reportes de inventario."),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleGuideItem(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: colorOnSurface, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 12, height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAuditCard(BuildContext context) {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorPrimary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.shield_outlined, color: Colors.white.withValues(alpha: 0.08), size: 140),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Auditoría de Seguridad",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Revisa el historial detallado de cambios en los permisos y accesos del sistema para mantener la integridad de los datos.",
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showAuditLogsDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text("Ver Log de Actividad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
      default:
        return colorOnSurfaceVariant;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Active":
        return const Color(0xFF10B981);
      case "Offline":
        return colorOutlineVariant;
      default:
        return const Color(0xFFBA1A1A);
    }
  }

  // DIÁLOGOS CRUD
  void _showCreateUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = "Administrator";
    String selectedStatus = "Active";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorSurfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.person_add, color: colorPrimary, size: 24),
                  SizedBox(width: 12),
                  Text("Create New User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        labelStyle: TextStyle(fontSize: 13),
                        prefixIcon: Icon(Icons.badge_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email Address",
                        labelStyle: TextStyle(fontSize: 13),
                        prefixIcon: Icon(Icons.mail_outline, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: "System Role", labelStyle: TextStyle(fontSize: 13)),
                      items: const [
                        DropdownMenuItem(value: "Administrator", child: Text("Administrator")),
                        DropdownMenuItem(value: "Manager", child: Text("Manager")),
                        DropdownMenuItem(value: "Editor", child: Text("Editor")),
                        DropdownMenuItem(value: "Viewer", child: Text("Viewer")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(labelText: "Status", labelStyle: TextStyle(fontSize: 13)),
                      items: const [
                        DropdownMenuItem(value: "Active", child: Text("Active")),
                        DropdownMenuItem(value: "Offline", child: Text("Offline")),
                        DropdownMenuItem(value: "Suspended", child: Text("Suspended")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedStatus = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: colorOnSurfaceVariant, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    if (name.isEmpty || email.isEmpty) return;

                    setState(() {
                      _users.add(UserModel(
                        id: UniqueKey().toString(),
                        name: name,
                        email: email,
                        role: selectedRole,
                        status: selectedStatus,
                        lastAccess: "Justo ahora",
                        imageUrl: "https://lh3.googleusercontent.com/aida/ADBb0uhavFE_cdN_MH6UxaJ-YPDlv4eh33h9JYk6e2KNmCBzQNPuhZtiOoIhdsHI-q1wHAr6-Xl5Gd0quGqRYPONfHwjLJmWY4isWJj5LKRhI8peJyGlvQHvam4_TYbUwWYWevidMqtgPAhzsoZcVDqQakp7ADvTlLNZdLTZYm9UgBA37QPxV-AJglIFeIR8-S4qCS5rhWR-TdqMgvOwx6jfICPRc24XlXU9Zf-lu_dm_37CtwO9appUDY-lbS8O_IyXRvewqo6LIgESWQ",
                      ));
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        content: Text("Usuario '$name' creado exitosamente."),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, foregroundColor: Colors.white),
                  child: const Text("Save User"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    String selectedRole = user.role;
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit, color: colorPrimary, size: 22),
                      SizedBox(width: 12),
                      Text("Edit User Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Color(0xFFBA1A1A)),
                    onPressed: () => _showConfirmDeleteDialog(context, user),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        labelStyle: TextStyle(fontSize: 13),
                        prefixIcon: Icon(Icons.badge_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email Address",
                        labelStyle: TextStyle(fontSize: 13),
                        prefixIcon: Icon(Icons.mail_outline, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: "System Role", labelStyle: TextStyle(fontSize: 13)),
                      items: const [
                        DropdownMenuItem(value: "Administrator", child: Text("Administrator")),
                        DropdownMenuItem(value: "Manager", child: Text("Manager")),
                        DropdownMenuItem(value: "Editor", child: Text("Editor")),
                        DropdownMenuItem(value: "Viewer", child: Text("Viewer")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(labelText: "Status", labelStyle: TextStyle(fontSize: 13)),
                      items: const [
                        DropdownMenuItem(value: "Active", child: Text("Active")),
                        DropdownMenuItem(value: "Offline", child: Text("Offline")),
                        DropdownMenuItem(value: "Suspended", child: Text("Suspended")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedStatus = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: colorOnSurfaceVariant, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    if (name.isEmpty || email.isEmpty) return;

                    setState(() {
                      final idx = _users.indexWhere((u) => u.id == user.id);
                      if (idx != -1) {
                        _users[idx] = user.copyWith(
                          name: name,
                          email: email,
                          role: selectedRole,
                          status: selectedStatus,
                        );
                      }
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        content: Text("Usuario '$name' actualizado exitosamente."),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, foregroundColor: Colors.white),
                  child: const Text("Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmDeleteDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorSurfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFBA1A1A), size: 24),
              SizedBox(width: 12),
              Text("Eliminar Usuario", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Text(
            "¿Está seguro de que desea eliminar permanentemente al usuario '${user.name}'? Esta acción no se puede deshacer.",
            style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: colorOnSurfaceVariant, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _users.removeWhere((u) => u.id == user.id);
                });
                Navigator.pop(context); // Cierra confirmación
                Navigator.pop(context); // Cierra modal editar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFFBA1A1A),
                    behavior: SnackBarBehavior.floating,
                    content: Text("Usuario '${user.name}' eliminado."),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), foregroundColor: Colors.white),
              child: const Text("Eliminar"),
            ),
          ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: colorPrimary, size: 24),
              SizedBox(width: 12),
              Text("Log de Actividad y Seguridad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _auditLogs.length,
              separatorBuilder: (context, index) => const Divider(color: colorOutlineVariant, height: 16, thickness: 0.5),
              itemBuilder: (context, index) {
                final log = _auditLogs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.history, size: 18, color: colorOnSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: colorOnSurface, fontSize: 13, fontFamily: 'Inter'),
                                children: [
                                  TextSpan(text: "${log.user} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: log.action, style: const TextStyle(color: colorOnSurfaceVariant)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(log.time, style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500)),
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
              style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, foregroundColor: Colors.white),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  void _simulateDataExport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (!context.mounted) return;
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text("Listado de Usuarios Exportado", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }
            });

            return AlertDialog(
              backgroundColor: colorSurfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(strokeWidth: 3, color: colorPrimary),
                    SizedBox(height: 20),
                    Text(
                      "Exportando listado de usuarios...",
                      style: TextStyle(color: colorOnSurface, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// CABECERA SUPERIOR (Búsqueda y Perfil)
class _Header extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isDesktop;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _Header({
    required this.scaffoldKey,
    required this.isDesktop,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: _VistaUsuariosState.colorSurfaceContainerLowest,
        border: Border(bottom: BorderSide(color: _VistaUsuariosState.colorOutlineVariant, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop) ...[
                IconButton(
                  icon: const Icon(Icons.menu, color: _VistaUsuariosState.colorOnSurface),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              const Text(
                "RetailAdmin Pro",
                style: TextStyle(color: _VistaUsuariosState.colorPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 32),
              if (isDesktop)
                Container(
                  width: 320,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _VistaUsuariosState.colorSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: "Buscar por nombre o correo...",
                      hintStyle: TextStyle(color: _VistaUsuariosState.colorOnSurfaceVariant, fontSize: 13),
                      prefixIcon: Icon(Icons.search, size: 18, color: _VistaUsuariosState.colorOnSurfaceVariant),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 22, color: _VistaUsuariosState.colorOnSurfaceVariant),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22, color: _VistaUsuariosState.colorOnSurfaceVariant),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _VistaUsuariosState.colorPrimaryContainer, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida/ADBb0uj8I9f53CpSj40cca_fxt6KDo57B4z5FBtDqrwX6YOaNbbsU1WX7mEhu5cunyifZXLih2dswdROV7dw0Js73dJ6-qs5F2VgSeZBUVN4YFIaVu_oLsBL2c-rstYiGoQhE-uY0TM2gcuR09ryDxDAHAGOxRwKRDsshuF-3NnsAIx7hHyVwi16RaRRLlSy9jG1gnABu5nQv53OELiPWAR5XPkb_VxkSsTmeuvRyhFfaZfhzRVU6MflDLaPguo-x9gcLMgro1_ligRf5Q',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _VistaUsuariosState.colorPrimary,
                      child: const Icon(Icons.person, color: Colors.white, size: 18),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// BARRA LATERAL (Sidebar)
class _SidebarContent extends StatelessWidget {
  final bool isDrawer;
  final VoidCallback? onToggleCollapse;

  const _SidebarContent({required this.isDrawer, this.onToggleCollapse});

  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabecera del Sidebar
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SidebarState.isCollapsed && !isDrawer ? 12.0 : 24.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: SidebarState.isCollapsed && !isDrawer ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                SidebarState.isCollapsed && !isDrawer ? "LC" : "La Confianza admin",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (!(SidebarState.isCollapsed && !isDrawer)) ...[
                const SizedBox(height: 4),
                const Text(
                  "PANEL DE CONTROL",
                  style: TextStyle(color: colorOutlineVariant, fontSize: 11),
                ),
              ],
            ],
          ),
        ),

        // Items de Navegación del Sidebar
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            children: [
              _buildNavItem(
                icon: Icons.dashboard,
                label: "Inicio",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/inicio');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.group,
                label: "Usuarios",
                isActive: true,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.inventory_2,
                label: "Inventario",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/inventario');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.point_of_sale,
                label: "Cierre de Caja",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/cierre');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.storage,
                label: "Datos",
                isActive: false,
                onTap: () {},
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.view_week,
                label: "Códigos de Barras",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/generador');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
            ],
          ),
        ),

        const Divider(color: Color(0xFF4E6073), height: 1),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: SidebarState.isCollapsed && !isDrawer ? 8.0 : 16.0,
          ),
          child: Column(
            children: [
              if (!isDrawer && onToggleCollapse != null)
                _buildNavItem(
                  icon: SidebarState.isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                  label: "Retraer",
                  isActive: false,
                  onTap: onToggleCollapse!,
                  isCollapsed: SidebarState.isCollapsed,
                ),
              _buildNavItem(
                icon: Icons.help_outline,
                label: "Soporte",
                isActive: false,
                onTap: () {},
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.logout,
                label: "Cerrar Sesión",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
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
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isCollapsed = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: isActive ? colorPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 8.0 : 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : colorOutlineVariant,
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : colorOutlineVariant,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
