// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'viewmodel_sesion.dart';

class VistaSesion extends StatefulWidget {
  const VistaSesion({super.key});

  @override
  State<VistaSesion> createState() => _VistaSesionState();
}

class _VistaSesionState extends State<VistaSesion> {
  bool _showManualLogin = false;
  final ViewModelSesion _viewModel = ViewModelSesion();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;

              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                      child: Container(
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
                          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isDesktop)
                                Expanded(
                                  child: Container(
                                    color: AppColors.inverseSurface,
                                    padding: const EdgeInsets.all(48.0),
                                    child: const _SeccionIzquierda(),
                                  ),
                                ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 64.0 : 24.0,
                                    vertical: isDesktop ? 64.0 : 48.0,
                                  ),
                                  child: _showManualLogin 
                                      ? _buildManualLoginForm() 
                                      : _SeccionDerecha(
                                          onToggleManual: () => setState(() => _showManualLogin = true),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: _FooterSecurityBadges(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildManualLoginForm() {
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
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
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
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Contraseña",
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),
        
        if (_viewModel.errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            _viewModel.errorMessage!,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _viewModel.isLoading ? null : _handleLogin,
            child: _viewModel.isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("INICIAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: () => setState(() => _showManualLogin = false),
          child: const Text("Volver a Vinculación QR"),
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

    final success = await _viewModel.loginManual(
      nombre: nombre,
      apellido: apellido,
      contrasena: password,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/inicio');
    }
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
              children: List.generate(6, (i) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)))),
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
                  "Accede a tu panel de administración empresarial de forma segura sincronizando tu dispositivo móvil en segundos.",
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
                  icon: Icons.qr_code_scanner,
                  title: "Escaneo Seguro",
                  subtitle: "Encriptación de punto a punto",
                  iconBgColor: AppColors.primary,
                ),
                const SizedBox(height: 24),
                _buildSecurityFeature(
                  icon: Icons.verified_user,
                  title: "Validación Biométrica",
                  subtitle: "Requiere FaceID o Huella en el móvil",
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
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sección Derecha - Formulario y Código QR
class _SeccionDerecha extends StatelessWidget {
  final VoidCallback onToggleManual;
  const _SeccionDerecha({required this.onToggleManual});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Vincular Dispositivo",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Abre la app móvil y escanea el código para iniciar sesión",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 200,
                  height: 200,
                  color: AppColors.background,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida/ADBb0uhavFE_cdN_MH6UxaJ-YPDlv4eh33h9JYk6e2KNmCBzQNPuhZtiOoIhdsHI-q1wHAr6-Xl5Gd0quGqRYPONfHwjLJmWY4isWJj5LKRhI8peJyGlvQHvam4_TYbUwWYWevidMqtgPAhzsoZcVDqQakp7ADvTlLNZdLTZYm9UgBA37QPxV-AJglIFeIR8-S4qCS5rhWR-TdqMgvOwx6jfICPRc24XlXU9Zf-lu_dm_37CtwO9appUDY-lbS8O_IyXRvewqo6LIgESWQ',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.qr_code, size: 120, color: AppColors.secondary)),
                  ),
                ),
              ),
              ..._buildFocusCorners(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BouncingDots(),
            SizedBox(width: 8),
            Text("ESPERANDO ESCANEO...", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.outlineVariant.withOpacity(0.5))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("O BIEN", style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
            ),
            Expanded(child: Divider(color: AppColors.outlineVariant.withOpacity(0.5))),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.8)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              foregroundColor: AppColors.onSurfaceVariant,
              backgroundColor: AppColors.surfaceContainerLowest,
            ),
            onPressed: onToggleManual,
            icon: const Icon(Icons.person, size: 20),
            label: const Text("Ingreso Manual", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.help_outline, size: 16),
          label: const Text("¿Necesitas ayuda para vincularte?", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  List<Widget> _buildFocusCorners() {
    const double cornerSize = 24.0;
    const double borderThickness = 4.0;
    const Color cornerColor = AppColors.primary;
    return [
      Positioned(top: 0, left: 0, child: _buildCorner(top: true, left: true, size: cornerSize, thickness: borderThickness, color: cornerColor)),
      Positioned(top: 0, right: 0, child: _buildCorner(top: true, left: false, size: cornerSize, thickness: borderThickness, color: cornerColor)),
      Positioned(bottom: 0, left: 0, child: _buildCorner(top: false, left: true, size: cornerSize, thickness: borderThickness, color: cornerColor)),
      Positioned(bottom: 0, right: 0, child: _buildCorner(top: false, left: false, size: cornerSize, thickness: borderThickness, color: cornerColor)),
    ];
  }

  Widget _buildCorner({required bool top, required bool left, required double size, required double thickness, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: color, width: thickness) : BorderSide.none,
          bottom: !top ? BorderSide(color: color, width: thickness) : BorderSide.none,
          left: left ? BorderSide(color: color, width: thickness) : BorderSide.none,
          right: !left ? BorderSide(color: color, width: thickness) : BorderSide.none,
        ),
      ),
    );
  }
}

/// Widget Animado de Puntos Rebotando
class BouncingDots extends StatefulWidget {
  const BouncingDots({super.key});

  @override
  State<BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double phase = (index * math.pi / 3.0);
            final double value = math.sin((_controller.value * 2 * math.pi) - phase);
            return Transform.translate(offset: Offset(0, (value * 3.5).clamp(-6.0, 0.0)), child: child);
          },
          child: Container(width: 7, height: 7, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
        );
      }),
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
        Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ],
    );
  }
}
