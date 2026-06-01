import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confianza_admin/core/config/role_constants.dart';
import 'modelos_usuarios.dart';
import 'servicio_usuarios.dart';

class ViewModelUsuarios extends ChangeNotifier {
  final ServicioUsuarios _servicio = ServicioUsuarios();

  // Datos
  List<UserModel> _dbUsers = [];
  List<UserModel> _dbPendingUsers = [];
  List<UserModel> _allUsers = [];
  List<UserProfileConfig> _profiles = [];
  final List<AuditLog> _auditLogs = [];

  // Estado UI
  String _searchQuery = "";
  String _selectedRoleFilter = "Todos";
  int _selectedViewMode = 0; // 0 = Usuarios Activos, 1 = Solicitudes de Acceso
  int _currentPage = 0;
  static const int _itemsPerPage = 4;
  int _selectedProfileIndex = 0;

  // Suscripciones
  StreamSubscription? _usuariosSub;
  StreamSubscription? _registroSub;

  ViewModelUsuarios() {
    _init();
  }

  void _init() {
    debugPrint("DEBUG: Inicializando ViewModelUsuarios...");
    _usuariosSub = _servicio.listenToUsers().listen((users) {
      debugPrint("DEBUG: ViewModel recibió ${users.length} usuarios activos");
      _dbUsers = users;
      _updateCombinedUsers();
    }, onError: (e) {
      debugPrint("DEBUG: Error en suscripción de usuarios: $e");
    });

    _registroSub = _servicio.listenToPendingUsers().listen((pending) {
      debugPrint("DEBUG: ViewModel recibió ${pending.length} solicitudes pendientes");
      _dbPendingUsers = pending;
      _updateCombinedUsers();
    }, onError: (e) {
      debugPrint("DEBUG: Error en suscripción de registros: $e");
    });

    loadProfiles();
  }

  void _updateCombinedUsers() {
    _allUsers = [..._dbUsers, ..._dbPendingUsers];
    notifyListeners();
  }

  Future<void> loadProfiles() async {
    try {
      _profiles = await _servicio.getRoles();
      if (_profiles.isNotEmpty && _selectedProfileIndex >= _profiles.length) {
        _selectedProfileIndex = 0;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading profiles: $e");
    }
  }

  // Getters
  List<UserModel> get users => _allUsers;
  List<UserProfileConfig> get profiles => _profiles;
  List<AuditLog> get auditLogs => _auditLogs;
  String get searchQuery => _searchQuery;
  String get selectedRoleFilter => _selectedRoleFilter;
  int get selectedViewMode => _selectedViewMode;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get selectedProfileIndex => _selectedProfileIndex;

  UserProfileConfig? get currentProfile =>
      _profiles.isNotEmpty && _selectedProfileIndex < _profiles.length
          ? _profiles[_selectedProfileIndex]
          : null;

  UserModel? get currentUser {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    try {
      return _allUsers.firstWhere((u) => u.id == uid);
    } catch (_) {
      return null;
    }
  }

  bool get isCurrentUserAdminMaster {
    final user = currentUser;
    if (user == null) return false;
    return user.role == RoleConstants.adminMasterId;
  }

  List<UserProfileConfig> get assignableRoles {
    if (isCurrentUserAdminMaster) return _profiles;
    return _profiles.where((p) => p.id != RoleConstants.adminMasterId).toList();
  }

  String getRoleName(String roleId) {
    if (roleId.isEmpty) return 'Sin Rol';
    // Buscar en los perfiles cargados
    try {
      return _profiles.firstWhere((p) => p.id == roleId).name;
    } catch (_) {
      // Si no se encuentra (puede ser un rol antiguo guardado como texto), devolver el ID original
      return roleId;
    }
  }

  // Filtrado
  List<UserModel> get filteredUsers {
    final query = _searchQuery.trim().toLowerCase();
    return _allUsers.where((item) {
      bool matchesViewMode = false;
      if (_selectedViewMode == 0) {
        matchesViewMode = item.status == "Activo";
      } else if (_selectedViewMode == 1) {
        matchesViewMode = item.status == "Pendiente" || item.status == "Aprobado";
      } else if (_selectedViewMode == 2) {
        matchesViewMode = item.status == "suspendido";
      }

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

  // Acciones UI
  void setSearchQuery(String val) {
    _searchQuery = val;
    _currentPage = 0;
    notifyListeners();
  }

  void setRoleFilter(String val) {
    _selectedRoleFilter = val;
    _currentPage = 0;
    notifyListeners();
  }

  void setSelectedViewMode(int mode) {
    _selectedViewMode = mode;
    _currentPage = 0;
    notifyListeners();
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setSelectedProfileIndex(int index) {
    _selectedProfileIndex = index;
    notifyListeners();
  }

  // Acciones de Negocio
  Future<void> saveProfile(UserProfileConfig profile) async {
    try {
      final newId = await _servicio.saveRoleAndGetId(profile);
      
      // Actualizar localmente si era nuevo
      if (profile.id.startsWith('temp_')) {
        final index = _profiles.indexWhere((p) => p.id == profile.id);
        if (index != -1) {
          _profiles[index] = UserProfileConfig(
            id: newId,
            name: profile.name,
            permissions: profile.permissions,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProfile(int index) async {
    try {
      final profile = _profiles[index];
      if (profile.id.isNotEmpty && !profile.id.startsWith('temp_')) {
        await _servicio.deleteRole(profile.id);
      }
      
      _profiles.removeAt(index);
      if (_profiles.isEmpty) {
        _selectedProfileIndex = 0;
      } else if (_selectedProfileIndex >= _profiles.length) {
        _selectedProfileIndex = _profiles.length - 1;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void addLocalProfile(String name) {
    _profiles.add(
      UserProfileConfig(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        permissions: {},
      ),
    );
    _selectedProfileIndex = _profiles.length - 1;
    notifyListeners();
  }

  Future<void> rejectUser(String id) async {
    try {
      await _servicio.deletePendingUser(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> approveUser(UserModel user, String roleId) async {
    try {
      if (roleId == RoleConstants.adminMasterId) {
        throw Exception("No puedes aprobar a un usuario directamente como Admin Master. Asígnale otro rol y luego transfiere el poder.");
      }
      await _servicio.approveUser(user, roleId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> transferAdminMaster(String targetUserId) async {
    final currentUserData = currentUser;
    if (currentUserData == null) throw Exception("No hay sesión activa.");
    
    final adminMasterRole = _profiles.firstWhere(
      (p) => p.id == RoleConstants.adminMasterId, 
      orElse: () => throw Exception("Rol Admin Master no encontrado")
    );
    final normalAdminRole = _profiles.firstWhere(
      (p) => p.id == RoleConstants.adminId, 
      orElse: () => throw Exception("Rol Admin normal no encontrado")
    );

    await _servicio.transferAdminMaster(
      currentMasterUserId: currentUserData.id,
      newMasterUserId: targetUserId,
      adminMasterRoleId: adminMasterRole.id,
      normalAdminRoleId: normalAdminRole.id,
    );
  }

  Future<void> updateUser(String userId, {String? roleId, String? status}) async {
    try {
      if (roleId != null && roleId == RoleConstants.adminMasterId) {
         // Verificamos si ya es el Admin Master (no hacemos nada si no cambia)
         final userToUpdate = _allUsers.firstWhere((u) => u.id == userId);
         if (userToUpdate.role != RoleConstants.adminMasterId) {
            await transferAdminMaster(userId);
            // Solo retornamos si no hay cambios de estado pendientes
            if (status == null || status == userToUpdate.status) {
               return; 
            }
         }
      }
      await _servicio.updateUser(userId, roleId: roleId, status: status);
    } catch (e) {
      rethrow;
    }
  }

  void togglePermission(UserProfileConfig profile, String module, String permission) {
    final modPerms = profile.permissions;
    final isChecked = modPerms[module]?.contains(permission) ?? false;
    
    if (isChecked) {
      modPerms[module]?.remove(permission);
    } else {
      modPerms.putIfAbsent(module, () => {}).add(permission);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _usuariosSub?.cancel();
    _registroSub?.cancel();
    super.dispose();
  }
}
