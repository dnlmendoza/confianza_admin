// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';

class VistaSesion extends StatefulWidget {
  const VistaSesion({super.key});

  @override
  State<VistaSesion> createState() => _VistaSesionState();
}

class _VistaSesionState extends State<VistaSesion> {
  // Paleta de colores exacta según el diseño de Tailwind CSS provisto
  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorSecondary = Color(0xFF4E6073);
  static const Color colorBackground = Color(0xFFF7F9FF);
  static const Color colorOnSurface = Color(0xFF181C20);
  static const Color colorOnSurfaceVariant = Color(0xFF3F4850);
  static const Color colorInverseSurface = Color(0xFF2D3135);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);
  static const Color colorSurfaceContainerLowest = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Si el ancho es mayor o igual a 800px, mostramos diseño de escritorio de doble columna
          final isDesktop = constraints.maxWidth >= 800;

          return Stack(
            children: [
              // Contenido principal centrado
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    decoration: BoxDecoration(
                      color: colorSurfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: colorOutlineVariant.withOpacity(0.5)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Columna Izquierda (Instrucciones) - Oculta en móviles
                          if (isDesktop)
                            Expanded(
                              child: Container(
                                color: colorInverseSurface,
                                padding: const EdgeInsets.all(48.0),
                                child: const _SeccionIzquierda(),
                              ),
                            ),

                          // Columna Derecha (Formulario / Acciones)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 64.0 : 24.0,
                                vertical: isDesktop ? 64.0 : 48.0,
                              ),
                              child: const _SeccionDerecha(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Pie de página de seguridad (SSL & ISO)
              const Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: _FooterSecurityBadges(),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Sección Izquierda - Información y Diseño Abstracto
class _SeccionIzquierda extends StatelessWidget {
  const _SeccionIzquierda();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gráfico Abstracto de Fondo (Semitransparente)
        Positioned.fill(
          child: Opacity(
            opacity: 0.05,
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              ],
            ),
          ),
        ),

        // Contenido de Información
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Cabecera Informativa
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

            // Tarjetas de seguridad del dispositivo
            Column(
              children: [
                _buildSecurityFeature(
                  icon: Icons.qr_code_scanner,
                  title: "Escaneo Seguro",
                  subtitle: "Encriptación de punto a punto",
                  iconBgColor: _VistaSesionState.colorPrimary,
                ),
                const SizedBox(height: 24),
                _buildSecurityFeature(
                  icon: Icons.verified_user,
                  title: "Validación Biométrica",
                  subtitle: "Requiere FaceID o Huella en el móvil",
                  iconBgColor: _VistaSesionState.colorSecondary,
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
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
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

/// Sección Derecha - Formulario y Código QR
class _SeccionDerecha extends StatelessWidget {
  const _SeccionDerecha();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Título de la sección
        const Text(
          "Vincular Dispositivo",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _VistaSesionState.colorOnSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Abre la app móvil y escanea el código para iniciar sesión",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _VistaSesionState.colorOnSurfaceVariant,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),

        // Contenedor del Código QR con enfoque de escáner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _VistaSesionState.colorOutlineVariant.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Cuadro del QR Code
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 200,
                  height: 200,
                  color: _VistaSesionState.colorBackground,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida/ADBb0uhavFE_cdN_MH6UxaJ-YPDlv4eh33h9JYk6e2KNmCBzQNPuhZtiOoIhdsHI-q1wHAr6-Xl5Gd0quGqRYPONfHwjLJmWY4isWJj5LKRhI8peJyGlvQHvam4_TYbUwWYWevidMqtgPAhzsoZcVDqQakp7ADvTlLNZdLTZYm9UgBA37QPxV-AJglIFeIR8-S4qCS5rhWR-TdqMgvOwx6jfICPRc24XlXU9Zf-lu_dm_37CtwO9appUDY-lbS8O_IyXRvewqo6LIgESWQ',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_VistaSesionState.colorPrimary),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Respaldo en caso de fallo de red
                      return const Center(
                        child: Icon(
                          Icons.qr_code,
                          size: 120,
                          color: _VistaSesionState.colorSecondary,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Esquinas de enfoque de la cámara
              ..._buildFocusCorners(),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Indicador Animado "Esperando escaneo..."
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BouncingDots(),
            SizedBox(width: 8),
            Text(
              "ESPERANDO ESCANEO...",
              style: TextStyle(
                color: _VistaSesionState.colorOnSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Línea Divisoria "O BIEN"
        Row(
          children: [
            Expanded(child: Divider(color: _VistaSesionState.colorOutlineVariant.withOpacity(0.5))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "O BIEN",
                style: TextStyle(
                  color: _VistaSesionState.colorSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Expanded(child: Divider(color: _VistaSesionState.colorOutlineVariant.withOpacity(0.5))),
          ],
        ),
        const SizedBox(height: 24),

        // Botón "Ingreso Manual"
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _VistaSesionState.colorOutlineVariant.withOpacity(0.8)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              foregroundColor: _VistaSesionState.colorOnSurfaceVariant,
              backgroundColor: _VistaSesionState.colorSurfaceContainerLowest,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/inicio');
            },
            icon: const Icon(Icons.person, size: 20),
            label: const Text(
              "Ingreso Manual",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Enlace de ayuda
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: _VistaSesionState.colorPrimary,
          ),
          onPressed: () {
            // Acción de ayuda
          },
          icon: const Icon(Icons.help_outline, size: 16),
          label: const Text(
            "¿Necesitas ayuda para vincularte?",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// Construye las 4 esquinas azules de enfoque del escáner
  List<Widget> _buildFocusCorners() {
    const double cornerSize = 24.0;
    const double borderThickness = 4.0;
    const Color cornerColor = _VistaSesionState.colorPrimary;

    return [
      // Arriba Izquierda
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: cornerColor, width: borderThickness),
              left: BorderSide(color: cornerColor, width: borderThickness),
            ),
          ),
        ),
      ),
      // Arriba Derecha
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: cornerColor, width: borderThickness),
              right: BorderSide(color: cornerColor, width: borderThickness),
            ),
          ),
        ),
      ),
      // Abajo Izquierda
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: cornerColor, width: borderThickness),
              left: BorderSide(color: cornerColor, width: borderThickness),
            ),
          ),
        ),
      ),
      // Abajo Derecha
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: cornerColor, width: borderThickness),
              right: BorderSide(color: cornerColor, width: borderThickness),
            ),
          ),
        ),
      ),
    ];
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
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
            // Genera una fase sinusoidal para cada punto para crear un efecto de ola continuo
            final double phase = (index * math.pi / 3.0);
            final double value = math.sin((_controller.value * 2 * math.pi) - phase);
            final double yOffset = (value * 3.5).clamp(-6.0, 0.0);

            return Transform.translate(
              offset: Offset(0, yOffset),
              child: child,
            );
          },
          child: Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: _VistaSesionState.colorPrimary,
              shape: BoxShape.circle,
            ),
          ),
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
        Icon(icon, size: 16, color: _VistaSesionState.colorSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: _VistaSesionState.colorSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
