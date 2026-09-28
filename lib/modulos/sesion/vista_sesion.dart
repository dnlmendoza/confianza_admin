// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'viewmodel_sesion.dart';

class VistaSesion extends ConsumerStatefulWidget {
  const VistaSesion({super.key});

  @override
  ConsumerState<VistaSesion> createState() => _VistaSesionState();
}

class _VistaSesionState extends ConsumerState<VistaSesion> {
  bool _obscurePassword = true;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Cambiamos el punto de quiebre a 900 para dar más espacio a laptops pequeñas
          final isDesktop = constraints.maxWidth >= 900;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: isDesktop
                          ? IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: AppColors.inverseSurface,
                                      padding: const EdgeInsets.all(48.0),
                                      child: const _SeccionIzquierda(),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(64.0),
                                      child: _buildManualLoginForm(),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 48.0,
                              ),
                              child: _buildManualLoginForm(),
                            ),
                    ),
                    const SizedBox(height: 48),
                    // Ahora los badges están en el flujo normal, nunca se van a superponer
                    const _FooterSecurityBadges(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildManualLoginForm() {
    final loginState = ref.watch(viewModelSesionProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Ingreso Manual",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Ingresa tus datos para acceder al panel",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 32),

        TextField(
          controller: _nombreController,
          decoration: const InputDecoration(
            labelText: "Nombre",
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _apellidoController,
          decoration: const InputDecoration(
            labelText: "Apellido",
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: "Contraseña",
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),

        if (loginState.errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            loginState.errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 32),

        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: loginState.isLoading ? null : _handleLogin,
            child: loginState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "INICIAR SESIÓN",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final password = _passwordController.text.trim();

    if (nombre.isEmpty || apellido.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos")),
      );
      return;
    }

    // Riverpod 2.x
    await ref.read(viewModelSesionProvider.notifier).loginManual(
      nombre: nombre,
      apellido: apellido,
      contrasena: password,
    );
    
    // No usamos Navigator.pushReplacementNamed('/inicio') porque el GoRouter
    // detectará el cambio de estado de Auth automáticamente y redirigirá.
  }
}

/// Sección Izquierda - Información y Diseño Abstracto
class _SeccionIzquierda extends StatelessWidget {
  const _SeccionIzquierda();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.05,
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                6,
                (i) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "La Confianza admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Accede a tu panel de administración ingresando tus credenciales de usuario autorizado.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                _buildSecurityFeature(
                  icon: Icons.shield,
                  title: "Acceso Restringido",
                  subtitle: "Solo administradores autorizados",
                  iconBgColor: AppColors.primary,
                ),
                const SizedBox(height: 24),
                _buildSecurityFeature(
                  icon: Icons.security,
                  title: "Conexión Encriptada",
                  subtitle: "Tus datos están protegidos",
                  iconBgColor: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityFeature({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Insignias de seguridad en el pie de página
class _FooterSecurityBadges extends StatelessWidget {
  const _FooterSecurityBadges();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBadge(icon: Icons.lock, label: "SSL SECURE"),
          const SizedBox(width: 32),
          _buildBadge(icon: Icons.shield, label: "ISO 27001"),
        ],
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
