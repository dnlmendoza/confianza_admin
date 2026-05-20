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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006397)),
            useMaterial3: true,
          ),
          // Si el usuario ya está autenticado, vamos a /inicio, si no a /
          initialRoute: snapshot.hasData ? '/inicio' : '/',
          routes: {
            '/': (context) => const VistaSesion(),
            '/inicio': (context) => const VistaInicio(),
            '/generador': (context) => const VistaGenerador(),
            '/inventario': (context) => const VistaInventario(),
            '/cierre': (context) => const VistaCierre(),
            '/usuarios': (context) => const VistaUsuarios(),
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
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
  State<InactivitySignOutListener> createState() => _InactivitySignOutListenerState();
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
    if (_timer == null || now.difference(_lastInteraction) > const Duration(seconds: 2)) {
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

