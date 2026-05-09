import 'package:flutter/material.dart';
import 'package:confianza_admin/main.dart';

class VistaGenerador extends StatefulWidget {
  const VistaGenerador({super.key});

  @override
  State<VistaGenerador> createState() => _VistaGeneradorState();
}

class _VistaGeneradorState extends State<VistaGenerador> {
  // Paleta de colores consistente de la marca
  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorPrimaryContainer = Color(0xFF3498db);
  static const Color colorBackground = Color(0xFFF7F9FF);
  static const Color colorOnSurface = Color(0xFF181C20);
  static const Color colorOnSurfaceVariant = Color(0xFF3F4850);
  static const Color colorInverseSurface = Color(0xFF2D3135);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);
  static const Color colorSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color colorSurfaceContainerLow = Color(0xFFF1F4FA);
  static const Color colorSurfaceContainerHigh = Color(0xFFE5E8EE);

  // Controladores y variables de estado interactivos para la previsualización en vivo
  late final TextEditingController _productNameController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;

  String _labelSize = "Estándar (50mm x 30mm)";
  int _quantity = 15;
  bool _includeLogo = true;
  bool _showPrice = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(
      text: "Smartphone Ultra X12 - Negro Medianoche",
    );
    _skuController = TextEditingController(text: "IPH-14-PRO-BK");
    _priceController = TextEditingController(text: "1,299.00");

    // Reconstruir la vista al escribir en los inputs
    _productNameController.addListener(() => setState(() {}));
    _skuController.addListener(() => setState(() {}));
    _priceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorBackground,
      drawer: Drawer(
        child: Container(
          color: colorInverseSurface,
          child: const _SidebarContent(isDrawer: true),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra Lateral (Sidebar) fija en pantallas grandes
              if (isDesktop)
                SizedBox(
                  width: SidebarState.isCollapsed ? 76 : 260,
                  child: Container(
                    color: colorInverseSurface,
                    child: _SidebarContent(
                      isDrawer: false,
                      onToggleCollapse: () {
                        setState(() {
                          SidebarState.isCollapsed = !SidebarState.isCollapsed;
                        });
                      },
                    ),
                  ),
                ),

              // Área de Contenido Principal
              Expanded(
                child: Column(
                  children: [
                    // Cabecera superior
                    _Header(scaffoldKey: _scaffoldKey, isDesktop: isDesktop),

                    // Cuerpo del Generador con Scroll
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título e Información de Pantalla
                                const Text(
                                  "Generador de Código de Barras",
                                  style: TextStyle(
                                    color: colorOnSurface,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Genera y previsualiza etiquetas de articulos para impresión.",
                                  style: TextStyle(
                                    color: colorOnSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Layout Bento principal: Formulario + Previsualización
                                LayoutBuilder(
                                  builder: (context, workspaceConstraints) {
                                    final useHorizontalSplit =
                                        workspaceConstraints.maxWidth >= 950;
                                    if (useHorizontalSplit) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: _buildConfigForm(),
                                          ),
                                          const SizedBox(width: 24),
                                          Expanded(
                                            flex: 7,
                                            child: _buildLivePreviewCanvas(),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          _buildLivePreviewCanvas(),
                                          const SizedBox(height: 24),
                                          _buildConfigForm(),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Tarjetas de Estadísticas Inferiores
                                const _StatsSection(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Construye la columna izquierda de formularios de configuración
  Widget _buildConfigForm() {
    return Column(
      children: [
        // Card de Datos del Item
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorSurfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorOutlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note, color: colorPrimary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Datos del Item",
                    style: TextStyle(
                      color: colorOnSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buscador de inventario
              const Text(
                "Buscar Item en Inventario",
                style: TextStyle(
                  color: colorOnSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "SKU o Nombre del producto",
                    hintStyle: const TextStyle(color: colorOnSurfaceVariant),
                    suffixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: colorOnSurfaceVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    filled: true,
                    fillColor: colorSurfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nombre del Producto
              const Text(
                "Nombre del Producto",
                style: TextStyle(
                  color: colorOnSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _productNameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: colorOutlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: colorPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grid de SKU y Precio
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "SKU / ID",
                          style: TextStyle(
                            color: colorOnSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _skuController,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: colorOutlineVariant,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: colorPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Precio Unitario",
                          style: TextStyle(
                            color: colorOnSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _priceController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.attach_money,
                                size: 16,
                                color: colorOnSurfaceVariant,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: colorOutlineVariant,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: colorPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Card de Parámetros de Impresión
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorSurfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorOutlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.settings_applications,
                    color: colorPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Parámetros de Impresión",
                    style: TextStyle(
                      color: colorOnSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Selector tamaño etiqueta
              const Text(
                "Tamaño de Etiqueta (Ajuste Térmico)",
                style: TextStyle(
                  color: colorOnSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorOutlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                        const [
                          "Estándar (50mm x 30mm)",
                          "Grande (100mm x 50mm)",
                          "Joyas Pequeñas (25mm x 15mm)",
                        ].contains(_labelSize)
                        ? _labelSize
                        : "Estándar (50mm x 30mm)",
                    isExpanded: true,
                    style: const TextStyle(color: colorOnSurface, fontSize: 13),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: colorOnSurface,
                    ),
                    items:
                        <String>[
                          "Estándar (50mm x 30mm)",
                          "Grande (100mm x 50mm)",
                          "Joyas Pequeñas (25mm x 15mm)",
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _labelSize = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contador de cantidad
              const Text(
                "Cantidad a Imprimir",
                style: TextStyle(
                  color: colorOnSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: colorOutlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove,
                              size: 16,
                              color: colorOnSurfaceVariant,
                            ),
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          Expanded(
                            child: Text(
                              _quantity.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colorOnSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 16,
                              color: colorOnSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(() => _quantity++);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Checkboxes
              Row(
                children: [
                  Checkbox(
                    value: _includeLogo,
                    activeColor: colorPrimary,
                    onChanged: (val) {
                      setState(() => _includeLogo = val ?? true);
                    },
                  ),
                  const Text(
                    "Incluir logo de la empresa",
                    style: TextStyle(color: colorOnSurface, fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _showPrice,
                    activeColor: colorPrimary,
                    onChanged: (val) {
                      setState(() => _showPrice = val ?? true);
                    },
                  ),
                  const Text(
                    "Mostrar precio en etiqueta",
                    style: TextStyle(color: colorOnSurface, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye el lienzo de previsualización en vivo (derecha)
  Widget _buildLivePreviewCanvas() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Banner cabecera de previsualización en vivo
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: colorPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "PREVISUALIZACIÓN EN VIVO (ESCALA 1:1)",
                style: TextStyle(
                  color: colorPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Tarjeta de la Etiqueta Térmica Real (Aspecto 5:3)
          Center(
            child: Container(
              width: 440,
              height: 264, // Proporción áurea de 5:3
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cabecera de Etiqueta (Nombre de Producto e Info + Precio)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _productNameController.text.isNotEmpty
                                  ? _productNameController.text
                                        .split(" - ")
                                        .first
                                  : "Teléfono Inteligente",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _productNameController.text.contains(" - ")
                                  ? _productNameController.text
                                        .split(" - ")
                                        .sublist(1)
                                        .join(" - ")
                                  : "Negro Medianoche • 256GB",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showPrice) ...[
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "PRECIO AL DETALLE",
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _priceController.text.isNotEmpty
                                  ? "\$${_priceController.text}"
                                  : "\$0.00",
                              style: const TextStyle(
                                color: colorPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  // Sección del Código de Barras Vectorial Nativo
                  Column(
                    children: [
                      Container(
                        height: 64,
                        width: double.infinity,
                        color: const Color(0xFFF8FAFC).withValues(alpha: 0.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _buildBarcodeLines(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _skuController.text.isNotEmpty
                            ? _skuController.text
                            : "IPH14PROBK2024",
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6.0,
                        ),
                      ),
                    ],
                  ),

                  // Sección Inferior (Logo corporativo e info de certificación)
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (_includeLogo) ...[
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: colorPrimary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "LC",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            const Text(
                              "SISTEMA CONFIANZA\nARTÍCULO CERTIFICADO",
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          "Impreso: 24/05/2024",
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Botones de acción "Print Now" y "Download for Print"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.print, size: 18),
                label: const Text(
                  "Imprimir Ahora",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorPrimary,
                  side: const BorderSide(color: colorPrimary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: colorSurfaceContainerLowest,
                ),
                onPressed: () {},
                icon: const Icon(Icons.download, size: 18),
                label: const Text(
                  "Descargar para Impresión",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dibuja líneas de código de barras realistas con grosores variados de manera vectorial
  List<Widget> _buildBarcodeLines() {
    final List<int> linePatterns = [
      1,
      2,
      0,
      1,
      0,
      3,
      0,
      1,
      2,
      0,
      2,
      3,
      0,
      1,
      4,
      0,
      1,
      2,
      0,
      2,
      0,
      3,
      1,
      0,
      4,
      0,
      1,
      2,
    ];

    return linePatterns.map((weight) {
      if (weight == 0) {
        return const SizedBox(width: 4);
      }
      return Container(width: weight.toDouble() * 2, color: Colors.black);
    }).toList();
  }
}

/// Contenido de la Barra Lateral (Sidebar)
class _SidebarContent extends StatelessWidget {
  final bool isDrawer;
  final VoidCallback? onToggleCollapse;
  const _SidebarContent({required this.isDrawer, this.onToggleCollapse});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabecera de la Marca
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SidebarState.isCollapsed && !isDrawer ? 12.0 : 24.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: SidebarState.isCollapsed && !isDrawer
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                SidebarState.isCollapsed && !isDrawer
                    ? "LC"
                    : "La Confianza admin",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              if (!(SidebarState.isCollapsed && !isDrawer)) ...[
                const SizedBox(height: 4),
                Text(
                  "PANEL DE CONTROL",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Items de Navegación
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            children: [
              _buildNavItem(
                icon: Icons.dashboard,
                label: "Inicio",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/inicio');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.group,
                label: "Usuarios",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/usuarios');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.inventory_2,
                label: "Inventario",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/inventario');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.point_of_sale,
                label: "Cierre de Caja",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/cierre');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.storage,
                label: "Datos",
                isActive: false,
                onTap: () {},
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.view_week,
                label: "Códigos de Barras",
                isActive: true,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
            ],
          ),
        ),

        // Footer del Sidebar
        const Divider(color: Color(0xFF4E6073), height: 1),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: SidebarState.isCollapsed && !isDrawer ? 8.0 : 16.0,
          ),
          child: Column(
            children: [
              if (!isDrawer && onToggleCollapse != null)
                _buildNavItem(
                  icon: SidebarState.isCollapsed
                      ? Icons.chevron_right
                      : Icons.chevron_left,
                  label: "Retraer",
                  isActive: false,
                  onTap: onToggleCollapse!,
                  isCollapsed: SidebarState.isCollapsed,
                ),
              _buildNavItem(
                icon: Icons.help_outline,
                label: "Soporte",
                isActive: false,
                onTap: () {},
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
              _buildNavItem(
                icon: Icons.logout,
                label: "Cerrar Sesión",
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isCollapsed = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 8.0 : 16.0,
            vertical: 12.0,
          ),
          margin: const EdgeInsets.symmetric(vertical: 2.0),
          decoration: BoxDecoration(
            color: isActive
                ? _VistaGeneradorState.colorPrimary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
                size: 20,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabecera Superior (Header)
class _Header extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isDesktop;
  const _Header({required this.scaffoldKey, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: _VistaGeneradorState.colorSurfaceContainerLowest,
        border: const Border(
          bottom: BorderSide(
            color: _VistaGeneradorState.colorOutlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sección de Pestañas y Título
          Row(
            children: [
              if (!isDesktop) ...[
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: _VistaGeneradorState.colorOnSurface,
                  ),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              const Text(
                "RetailAdmin Pro",
                style: TextStyle(
                  color: _VistaGeneradorState.colorPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 24,
                  color: _VistaGeneradorState.colorOutlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                const SizedBox(width: 16),
                // Pestañas secundarias
                _buildTab("Generador", isSelected: true),
                _buildTab("Historial", isSelected: false),
                _buildTab("Plantillas", isSelected: false),
              ],
            ],
          ),

          // Sección de Perfil y Notificaciones
          Row(
            children: [
              if (isDesktop) ...[
                SizedBox(
                  width: 220,
                  height: 36,
                  child: TextField(
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Buscar producto...",
                      hintStyle: const TextStyle(
                        color: _VistaGeneradorState.colorOnSurfaceVariant,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: _VistaGeneradorState.colorOnSurfaceVariant,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                      fillColor: _VistaGeneradorState.colorSurfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(99),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  size: 22,
                  color: _VistaGeneradorState.colorOnSurfaceVariant,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 22,
                  color: _VistaGeneradorState.colorOnSurfaceVariant,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              // Avatar de perfil de red con fallback local
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _VistaGeneradorState.colorPrimaryContainer,
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida/ADBb0uj8I9f53CpSj40cca_fxt6KDo57B4z5FBtDqrwX6YOaNbbsU1WX7mEhu5cunyifZXLih2dswdROV7dw0Js73dJ6-qs5F2VgSeZBUVN4YFIaVu_oLsBL2c-rstYiGoQhE-uY0TM2gcuR09ryDxDAHAGOxRwKRDsshuF-3NnsAIx7hHyVwi16RaRRLlSy9jG1gnABu5nQv53OELiPWAR5XPkb_VxkSsTmeuvRyhFfaZfhzRVU6MflDLaPguo-x9gcLMgro1_ligRf5Q',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _VistaGeneradorState.colorPrimary,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 18,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: isSelected
            ? const Border(
                bottom: BorderSide(
                  color: _VistaGeneradorState.colorPrimary,
                  width: 2,
                ),
              )
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? _VistaGeneradorState.colorPrimary
              : _VistaGeneradorState.colorOnSurfaceVariant,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

/// Tarjetas de Estadísticas Inferiores (Fila de 3)
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 550) {
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 2.2,
          children: [
            // Total Impreso Hoy
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _VistaGeneradorState.colorSurfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _VistaGeneradorState.colorOutlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TOTAL IMPRESO HOY",
                    style: TextStyle(
                      color: _VistaGeneradorState.colorOnSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        "1,248",
                        style: TextStyle(
                          color: _VistaGeneradorState.colorOnSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Color(0xFF10B981),
                              size: 12,
                            ),
                            SizedBox(width: 2),
                            Text(
                              "+12%",
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Printer Status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _VistaGeneradorState.colorSurfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _VistaGeneradorState.colorOutlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ESTADO DE LA IMPRESORA",
                    style: TextStyle(
                      color: _VistaGeneradorState.colorOnSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "En Línea",
                        style: TextStyle(
                          color: _VistaGeneradorState.colorOnSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Zebra ZT411 - Bandeja 1",
                    style: TextStyle(
                      color: _VistaGeneradorState.colorOnSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Media Left
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _VistaGeneradorState.colorSurfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _VistaGeneradorState.colorOutlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MATERIAL RESTANTE",
                    style: TextStyle(
                      color: _VistaGeneradorState.colorOnSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: const SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        value: 0.65,
                        backgroundColor:
                            _VistaGeneradorState.colorSurfaceContainerLow,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _VistaGeneradorState.colorPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "650 etiquetas restantes",
                    style: TextStyle(
                      color: _VistaGeneradorState.colorOnSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
