import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:confianza_admin/modulos/sesion/vista_sesion.dart';
import 'package:confianza_admin/modulos/inicio/vista_inicio.dart';
import 'package:confianza_admin/modulos/generador/vista_generador.dart';
import 'package:confianza_admin/modulos/inventario/vista_inventario.dart';
import 'package:confianza_admin/modulos/cierre/vista_cierre.dart';
import 'package:confianza_admin/modulos/usuarios/vista_usuarios.dart';
import 'package:confianza_admin/modulos/pos/vista_pos.dart';
import 'package:confianza_admin/modulos/catalogos/vista_catalogos.dart';

// Proveedor para escuchar el estado de autenticación de Firebase de forma reactiva
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Clave global para la navegación (útil para el auto-logout por inactividad)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Proveedor principal del enrutador (GoRouter)
final enrutadorProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      // Si el estado aún está cargando, no hacemos nada todavía
      if (authState.isLoading) return null;

      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/';

      // Si no está logueado y trata de entrar a otra página, forzar al login
      if (!isLoggedIn && !isLoggingIn) return '/';
      
      // Si ya está logueado y trata de ver el login, enviarlo directo al inicio
      if (isLoggedIn && isLoggingIn) return '/inicio';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const VistaSesion(),
      ),
      GoRoute(
        path: '/inicio',
        builder: (context, state) => const VistaInicio(),
      ),
      GoRoute(
        path: '/generador',
        builder: (context, state) => const VistaGenerador(),
      ),
      GoRoute(
        path: '/inventario',
        builder: (context, state) => const VistaInventario(),
      ),
      GoRoute(
        path: '/cierre',
        builder: (context, state) => const VistaCierre(),
      ),
      GoRoute(
        path: '/usuarios',
        builder: (context, state) => const VistaUsuarios(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const VistaPos(),
      ),
      GoRoute(
        path: '/catalogos',
        builder: (context, state) => const VistaCatalogos(),
      ),
    ],
  );
});
