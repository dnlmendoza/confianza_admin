import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:confianza_admin/core/config/role_constants.dart';

class ViewModelSesion extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> loginManual({
    required String nombre,
    required String apellido,
    required String contrasena,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Construir el identificador de correo
      // User said: apellidonombre@laconfianza.hn
      final String userEmail = '${apellido.trim().toLowerCase()}${nombre.trim().toLowerCase()}@laconfianza.hn';
      
      debugPrint("Intentando Firebase Auth login para: $userEmail");

      // Iniciar sesión con Firebase Auth
      await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: contrasena,
      );

      // Verificar el rol del usuario en Firestore por ID (No por nombre)
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
            if (roleId != null) {
              if (roleId == RoleConstants.adminId || roleId == RoleConstants.adminMasterId) {
                // Login exitoso y tiene permisos
                _isLoading = false;
                notifyListeners();
                return true;
              }
            }
          }
        }
      }

      // Si llegamos aquí, el usuario no tiene permisos
      await _auth.signOut();
      _errorMessage = "No tienes permisos de administrador para acceder a esta plataforma.";
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error de Firebase Auth: ${e.code} - ${e.message}");
      
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = "Usuario no registrado en el sistema de autenticación.";
          break;
        case 'wrong-password':
          _errorMessage = "Contraseña incorrecta.";
          break;
        case 'invalid-email':
          _errorMessage = "El formato del correo generado no es válido.";
          break;
        case 'user-disabled':
          _errorMessage = "Este usuario ha sido deshabilitado.";
          break;
        case 'invalid-credential':
          _errorMessage = "Credenciales inválidas (usuario o contraseña incorrectos).";
          break;
        default:
          _errorMessage = "Error de autenticación: ${e.message}";
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Error inesperado en login: $e");
      _errorMessage = "Error inesperado: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
