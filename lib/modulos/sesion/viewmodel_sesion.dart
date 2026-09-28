import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confianza_admin/core/config/role_constants.dart';

// Estado inmutable para el login
class LoginState {
  final bool isLoading;
  final String? errorMessage;
  const LoginState({this.isLoading = false, this.errorMessage});
}

// ViewModel moderno usando Notifier de Riverpod 2/3
class ViewModelSesion extends Notifier<LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  LoginState build() {
    return const LoginState();
  }

  Future<bool> loginManual({
    required String nombre,
    required String apellido,
    required String contrasena,
  }) async {
    state = const LoginState(isLoading: true);

    try {
      final String userEmail = '${apellido.trim().toLowerCase()}${nombre.trim().toLowerCase()}@laconfianza.hn';

      await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: contrasena,
      );

      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            final String? roleId = userData['Rol'];
            if (roleId != null && (roleId == RoleConstants.adminId || roleId == RoleConstants.adminMasterId)) {
              state = const LoginState(isLoading: false);
              return true;
            }
          }
        }
      }

      await _auth.signOut();
      state = const LoginState(isLoading: false, errorMessage: "No tienes permisos de administrador para acceder.");
      return false;
    } on FirebaseAuthException catch (e) {
      String msg = "Error de autenticación: ${e.message}";
      switch (e.code) {
        case 'user-not-found': msg = "Usuario no registrado en el sistema."; break;
        case 'wrong-password': msg = "Contraseña incorrecta."; break;
        case 'invalid-email': msg = "El formato del correo generado no es válido."; break;
        case 'user-disabled': msg = "Este usuario ha sido deshabilitado."; break;
        case 'invalid-credential': msg = "Credenciales inválidas (usuario o contraseña incorrectos)."; break;
      }
      state = LoginState(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = LoginState(isLoading: false, errorMessage: "Error inesperado: $e");
      return false;
    }
  }

  void clearError() {
    state = LoginState(isLoading: state.isLoading, errorMessage: null);
  }
}

// Proveedor de Riverpod para el ViewModel de Sesión
final viewModelSesionProvider = NotifierProvider<ViewModelSesion, LoginState>(() {
  return ViewModelSesion();
});
