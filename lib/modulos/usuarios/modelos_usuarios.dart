import 'package:flutter/foundation.dart';

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
      status: json['Estado'] as String? ?? (isRequest ? 'Pendiente' : 'Activo'),
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
