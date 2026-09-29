import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Importante para traducir widgets nativos
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confianza_admin/firebase_options.dart';
import 'package:confianza_admin/core/enrutador.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    // NÚCLEO: ProviderScope inicializa el motor de Riverpod
    const ProviderScope(child: MyApp()),
  );
}

// MyApp ahora es un ConsumerWidget para poder leer los proveedores de Riverpod
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el enrutador que ya contiene toda la seguridad y rutas
    final enrutador = ref.watch(enrutadorProvider);

    return InactivitySignOutListener(
      child: MaterialApp.router(
        title: 'La Confianza Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006397)),
          useMaterial3: true,
        ),
        // --- CONFIGURACIÓN DE IDIOMA PARA COMPONENTES NATIVOS (EJ. DATEPICKER) ---
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
        ],
        locale: const Locale('es', 'ES'), // Forzar la app entera al español
        routerConfig:
            enrutador, // Usamos router moderno en lugar del map de rutas viejo
      ),
    );
  }
}

// Escuchador de Inactividad Intacto (Solo optimizamos cómo expulsa al usuario)
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
    if (_timer == null ||
        now.difference(_lastInteraction) > const Duration(seconds: 2)) {
      _lastInteraction = now;
      _timer?.cancel();
      _timer = Timer(const Duration(minutes: 10), _signOutUser);
    }
  }

  void _signOutUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Magia de Riverpod: Al hacer signOut, el authStateProvider cambia,
      // y el GoRouter detecta el cambio expulsando al usuario al '/' instantáneamente.
      await FirebaseAuth.instance.signOut();
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

// Restaurado: Estado simple de la barra lateral (Se refactorizará a Riverpod después si es necesario)
class SidebarState {
  static bool isCollapsed = false;
}
