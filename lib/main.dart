import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confianza_admin/firebase_options.dart';
import 'package:confianza_admin/modulos/sesion/vista_sesion.dart';
import 'package:confianza_admin/modulos/inicio/vista_inicio.dart';
import 'package:confianza_admin/modulos/generador/vista_generador.dart';
import 'package:confianza_admin/modulos/inventario/vista_inventario.dart';
import 'package:confianza_admin/modulos/cierre/vista_cierre.dart';
import 'package:confianza_admin/modulos/usuarios/vista_usuarios.dart';
import 'package:confianza_admin/modulos/pos/vista_pos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          builder: (context, child) => InactivitySignOutListener(child: child!),
          title: 'La Confianza Admin',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF006397),
            ),
            useMaterial3: true,
          ),
          initialRoute: '/inventario',
          routes: {
            '/': (context) => const VistaSesion(),
            '/inicio': (context) => const VistaInicio(),
            '/generador': (context) => const VistaGenerador(),
            '/inventario': (context) => const VistaInventario(),
            '/cierre': (context) => const VistaCierre(),
            '/usuarios': (context) => const VistaUsuarios(),
            '/pos': (context) => const VistaPos(),
          },
        );
      },
    );
  }
}

class SidebarState {
  static bool isCollapsed = false;
}

class InactivitySignOutListener extends StatefulWidget {
  final Widget child;
  const InactivitySignOutListener({super.key, required this.child});

  @override
  State<InactivitySignOutListener> createState() =>
      _InactivitySignOutListenerState();
}

class _InactivitySignOutListenerState extends State<InactivitySignOutListener> {
  Timer? _timer;
  DateTime _lastInteraction = DateTime.now();

  @override
  void initState() {
    super.initState();
    _resetTimer();
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  @override
  void dispose() {
    _timer?.cancel();
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    super.dispose();
  }

  bool _onKeyEvent(KeyEvent event) {
    _resetTimer();
    return false;
  }

  void _resetTimer() {
    final now = DateTime.now();
    // Throttle interaction updates to once every 2 seconds to avoid timer recreation overhead
    if (_timer == null ||
        now.difference(_lastInteraction) > const Duration(seconds: 2)) {
      _lastInteraction = now;
      _timer?.cancel();
      // Temporizador de 10 minutos (600 segundos) para el comportamiento definitivo
      _timer = Timer(const Duration(minutes: 10), _signOutUser);
    }
  }

  void _signOutUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerHover: (_) => _resetTimer(),
      onPointerSignal: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
