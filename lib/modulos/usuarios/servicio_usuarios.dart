import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modelos_usuarios.dart';

class ServicioUsuarios {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> listenToUsers() {
    debugPrint("DEBUG: Iniciando listenToUsers()");
    return _firestore
        .collection('Usuarios')
        .where('Estado', isNotEqualTo: 'Pendiente')
        .snapshots()
        .map((snapshot) {
          debugPrint(
            "DEBUG: Recibidos ${snapshot.docs.length} usuarios de Firestore",
          );
          return snapshot.docs.map((doc) {
            try {
              return UserModel.fromFirestore(
                doc.data(),
                doc.id,
                isRequest: false,
              );
            } catch (e) {
              debugPrint("DEBUG: Error mapeando usuario ${doc.id}: $e");
              rethrow;
            }
          }).toList();
        })
        .handleError((error) {
          debugPrint("DEBUG: ERROR en stream listenToUsers: $error");
        });
  }

  Stream<List<UserModel>> listenToPendingUsers() {
    debugPrint("DEBUG: Iniciando listenToPendingUsers()");
    return _firestore
        .collection('Usuarios')
        .where('Estado', isEqualTo: 'Pendiente')
        .snapshots()
        .map((snapshot) {
          debugPrint(
            "DEBUG: Recibidas ${snapshot.docs.length} solicitudes pendientes de Firestore",
          );
          return snapshot.docs.map((doc) {
            try {
              return UserModel.fromFirestore(
                doc.data(),
                doc.id,
                isRequest: true,
              );
            } catch (e) {
              debugPrint("DEBUG: Error mapeando solicitud ${doc.id}: $e");
              rethrow;
            }
          }).toList();
        })
        .handleError((error) {
          debugPrint("DEBUG: ERROR en stream listenToPendingUsers: $error");
        });
  }

  Future<List<UserProfileConfig>> getRoles() async {
    debugPrint("DEBUG: Cargando roles desde Firestore...");
    final snapshot = await _firestore.collection('Roles').get();
    final List<UserProfileConfig> roles = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String name = data['nombre'] as String? ?? 'Sin nombre';
      final dynamic permsData = data['permisos'];

      final Map<String, Set<String>> permissions = {};

      if (permsData is Map<String, dynamic>) {
        // Nuevo formato: Mapa { 'Modulo - Accion': true/false }
        permsData.forEach((permKey, valor) {
          if (valor == true && permKey.contains(' - ')) {
            final parts = permKey.split(' - ');
            final String module = parts[0];
            String action = parts[1];
            if (module == 'Cierre' && action == 'Crear egresos') {
              action = 'Crear Egresos';
            }
            permissions.putIfAbsent(module, () => {}).add(action);
          }
        });
      } else if (permsData is List<dynamic>) {
        // Compatibilidad con formato anterior: Lista [ { permiso: '...', valor: true } ]
        for (var p in permsData) {
          if (p is Map<String, dynamic>) {
            final String permStr = p['permiso'] as String? ?? '';
            final bool valor = p['valor'] as bool? ?? false;

            if (valor && permStr.contains(' - ')) {
              final parts = permStr.split(' - ');
              final String module = parts[0];
              String action = parts[1];
              if (module == 'Cierre' && action == 'Crear egresos') {
                action = 'Crear Egresos';
              }
              permissions.putIfAbsent(module, () => {}).add(action);
            }
          }
        }
      }

      roles.add(
        UserProfileConfig(id: doc.id, name: name, permissions: permissions),
      );
    }
    debugPrint("DEBUG: ${roles.length} roles cargados correctamente");
    return roles;
  }

  Future<String> saveRoleAndGetId(UserProfileConfig profile) async {
    try {
      debugPrint("DEBUG: Starting saveRoleAndGetId for ${profile.name}");
      final Map<String, bool> permissionsMap = {};

      final Map<String, List<String>> structure = {
        "Inventario": ["Ver datos", "Crear dañados"],
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

      structure.forEach((module, actions) {
        for (var action in actions) {
          final bool isEnabled =
              profile.permissions[module]?.contains(action) ?? false;
          permissionsMap['$module - $action'] = isEnabled;
        }
      });

      final bool isNew = profile.id.startsWith('temp_');

      if (!isNew) {
        final existingDoc = await _firestore.collection('Roles').doc(profile.id).get();
        if (existingDoc.exists && existingDoc.data()?['nombre'] == 'Admin Master' && profile.name != 'Admin Master') {
          throw Exception('No puedes cambiarle el nombre al rol Admin Master.');
        }
      } else if (profile.name.trim().toLowerCase() == 'admin master') {
        throw Exception('El nombre "Admin Master" está reservado para el sistema.');
      }

      final DocumentReference docRef;
      if (isNew) {
        docRef = _firestore.collection('Roles').doc();
        debugPrint("DEBUG: Generating new document ID: ${docRef.id}");
      } else {
        docRef = _firestore.collection('Roles').doc(profile.id);
        debugPrint("DEBUG: Updating existing document: ${profile.id}");
      }

      final Map<String, dynamic> dataToSave = {
        'nombre': profile.name,
        'permisos': permissionsMap,
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      };

      debugPrint("DEBUG: Data to save: $dataToSave");

      if (isNew) {
        await docRef.set(dataToSave);
      } else {
        await docRef.set(dataToSave, SetOptions(merge: true));
      }

      debugPrint(
        "DEBUG: Save operation completed successfully for ID: ${docRef.id}",
      );
      return docRef.id;
    } catch (e, stack) {
      debugPrint("DEBUG: ERROR in saveRoleAndGetId: $e");
      debugPrint("DEBUG: Stack trace: $stack");
      rethrow;
    }
  }

  Future<void> deleteRole(String id) async {
    final doc = await _firestore.collection('Roles').doc(id).get();
    if (doc.exists && doc.data()?['nombre'] == 'Admin Master') {
      throw Exception('El rol "Admin Master" es del sistema y no puede ser eliminado.');
    }
    await _firestore.collection('Roles').doc(id).delete();
  }

  Future<void> deletePendingUser(String id) async {
    final doc = await _firestore.collection('Usuarios').doc(id).get();
    if (doc.exists) {
      final roleId = doc.data()?['Rol'];
      if (roleId != null) {
        final rolDoc = await _firestore.collection('Roles').doc(roleId).get();
        if (rolDoc.exists && rolDoc.data()?['nombre'] == 'Admin Master') {
          throw Exception('No puedes eliminar al usuario Admin Master.');
        }
      }
    }
    await _firestore.collection('Usuarios').doc(id).delete();
  }

  Future<void> approveUser(UserModel user, String roleId) async {
    debugPrint(
      "DEBUG: Iniciando aprobación para usuario ${user.id} con Rol ID: $roleId",
    );

    // Al estar todo en la misma colección, solo actualizamos el documento
    await _firestore.collection('Usuarios').doc(user.id).update({
      'Estado': "Aprobado",
      'Rol': roleId,
      'fecha_aprobacion': DateTime.now().toIso8601String(),
    });

    debugPrint("DEBUG: Aprobación completada con éxito (Update a Aprobado)");
  }

  Future<void> updateUser(
    String userId, {
    String? roleId,
    String? status,
  }) async {
    final doc = await _firestore.collection('Usuarios').doc(userId).get();
    if (!doc.exists) return;

    final currentRoleId = doc.data()?['Rol'];
    bool isCurrentlyMaster = false;

    if (currentRoleId != null) {
      final rolDoc = await _firestore.collection('Roles').doc(currentRoleId).get();
      if (rolDoc.exists && rolDoc.data()?['nombre'] == 'Admin Master') {
        isCurrentlyMaster = true;
      }
    }

    if (isCurrentlyMaster) {
      if (status != null && status != 'Activo') {
        throw Exception('El Admin Master no puede ser suspendido ni modificado de estado.');
      }
      if (roleId != null && roleId != currentRoleId) {
        throw Exception('No puedes quitar el rol de Admin Master directamente. Utiliza la opción de transferir rol.');
      }
    }

    final Map<String, dynamic> updates = {
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    };
    if (roleId != null) updates['Rol'] = roleId;
    if (status != null) updates['Estado'] = status;

    await _firestore.collection('Usuarios').doc(userId).update(updates);
  }

  Future<void> transferAdminMaster({
    required String currentMasterUserId,
    required String newMasterUserId,
    required String adminMasterRoleId,
    required String normalAdminRoleId,
  }) async {
    final batch = _firestore.batch();
    
    // El nuevo recibe el poder
    batch.update(_firestore.collection('Usuarios').doc(newMasterUserId), {
      'Rol': adminMasterRoleId,
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    });

    // El antiguo se degrada a Admin Normal
    batch.update(_firestore.collection('Usuarios').doc(currentMasterUserId), {
      'Rol': normalAdminRoleId,
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    });

    await batch.commit();
    debugPrint("DEBUG: Transferencia de poder completada.");
  }
}
