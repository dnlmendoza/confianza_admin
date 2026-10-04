

/// Modelo de datos para un Usuario
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // "Administrator", "Manager", "Editor", "Viewer"
  final String status; // "Active", "Offline", "Suspended"
  final String lastAccess;
  final String imageUrl;
  final String telefono;
  final String idDispositivo;
  final Map<String, bool> permisos;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastAccess,
    required this.imageUrl,
    this.telefono = '',
    this.idDispositivo = '',
    this.permisos = const {},
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? status,
    String? lastAccess,
    String? imageUrl,
    String? telefono,
    String? idDispositivo,
    Map<String, bool>? permisos,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      lastAccess: lastAccess ?? this.lastAccess,
      imageUrl: imageUrl ?? this.imageUrl,
      telefono: telefono ?? this.telefono,
      idDispositivo: idDispositivo ?? this.idDispositivo,
      permisos: permisos ?? this.permisos,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> json, String id, {required bool isRequest}) {
    final String nombresRaw = (json['Nombres'] as String? ?? '').trim();
    final String apellidosRaw = (json['Apellidos'] as String? ?? '').trim();
    
    final String primerNombre = nombresRaw.isNotEmpty ? nombresRaw.split(RegExp(r'\s+')).first : '';
    final String primerApellido = apellidosRaw.isNotEmpty ? apellidosRaw.split(RegExp(r'\s+')).first : '';
    
    final String name = '$primerNombre $primerApellido'.trim();
    
    // Buscar el primer valor que no sea nulo entre variantes comunes de nombres de campo
    final Object? possibleUrl = json['FotoUrl'] ?? 
                                json['fotoUrl'] ?? 
                                json['fotourl'] ?? 
                                json['Foto'] ?? 
                                json['foto'] ?? 
                                json['Imagen'];
                                
    final String rawUrl = possibleUrl?.toString().trim() ?? '';
    
    final dynamic rawPermisos = json['permisos'];
    final Map<String, bool> parsedPermisos = {};
    if (rawPermisos is Map) {
      rawPermisos.forEach((key, value) {
        if (key is String && value is bool) {
          parsedPermisos[key] = value;
        }
      });
    }
    
    return UserModel(
      id: id,
      name: name.isEmpty ? 'Sin nombre' : name,
      email: json['Idcorreo'] as String? ?? json['Correo'] as String? ?? '',
      role: json['Rol'] as String? ?? (isRequest ? 'Pendiente' : 'Sin Rol'),
      status: json['Estado'] as String? ?? (isRequest ? 'Pendiente' : 'Activo'),
      lastAccess: json['Fecha'] as String? ?? '',
      imageUrl: rawUrl,
      telefono: json['Telefono']?.toString() ?? '',
      idDispositivo: json['IdDispositivo']?.toString() ?? '',
      permisos: parsedPermisos,
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
