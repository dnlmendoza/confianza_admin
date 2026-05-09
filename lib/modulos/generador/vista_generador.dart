import 'package:flutter/material.dart';

import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
class VistaGenerador extends StatefulWidget {
  const VistaGenerador({super.key});

  @override
  State<VistaGenerador> createState() => _VistaGeneradorState();
}

class _VistaGeneradorState extends State<VistaGenerador> {
  

  // Controladores y variables de estado interactivos para la previsualización en vivo
  late final TextEditingController _productNameController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;

  String _labelSize = "Estándar (50mm x 30mm)";
  int _quantity = 15;
  bool _includeLogo = true;
  bool _showPrice = true;

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
    return AdminLayout(
      activeRoute: '/generador',
      title: 'Códigos de Barras',
      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título e Información de Pantalla
                                Text(
                                  "Generador de Código de Barras",
                                  style: TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Genera y previsualiza etiquetas de articulos para impresión.",
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 32),

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
                                          SizedBox(width: 24),
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
                                          SizedBox(height: 24),
                                          _buildConfigForm(),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 24),

                                // Tarjetas de Estadísticas Inferiores
                                const _StatsSection(),
                                ],
                              ),
                            ),
                          ),
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
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Datos del Item",
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Buscador de inventario
              Text(
                "Buscar Item en Inventario",
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "SKU o Nombre del producto",
                    hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                    suffixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Nombre del Producto
              Text(
                "Nombre del Producto",
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _productNameController,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Grid de SKU y Precio
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SKU / ID",
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _skuController,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.outlineVariant,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Precio Unitario",
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _priceController,
                            style: TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.attach_money,
                                size: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.outlineVariant,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
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
        SizedBox(height: 20),

        // Card de Parámetros de Impresión
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.settings_applications,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Parámetros de Impresión",
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Selector tamaño etiqueta
              Text(
                "Tamaño de Etiqueta (Ajuste Térmico)",
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
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
                    style: TextStyle(color: AppColors.onSurface, fontSize: 13),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.onSurface,
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
              SizedBox(height: 16),

              // Contador de cantidad
              Text(
                "Cantidad a Imprimir",
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
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
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
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
              SizedBox(height: 20),

              // Checkboxes
              Row(
                children: [
                  Checkbox(
                    value: _includeLogo,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _includeLogo = val ?? true);
                    },
                  ),
                  Text(
                    "Incluir logo de la empresa",
                    style: TextStyle(color: AppColors.onSurface, fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _showPrice,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _showPrice = val ?? true);
                    },
                  ),
                  Text(
                    "Mostrar precio en etiqueta",
                    style: TextStyle(color: AppColors.onSurface, fontSize: 13),
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
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Banner cabecera de previsualización en vivo
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                "PREVISUALIZACIÓN EN VIVO (ESCALA 1:1)",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 48),

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
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              _productNameController.text.contains(" - ")
                                  ? _productNameController.text
                                        .split(" - ")
                                        .sublist(1)
                                        .join(" - ")
                                  : "Negro Medianoche • 256GB",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showPrice) ...[
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "PRECIO AL DETALLE",
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              _priceController.text.isNotEmpty
                                  ? "\$${_priceController.text}"
                                  : "\$0.00",
                              style: TextStyle(
                                color: AppColors.primary,
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
                      SizedBox(height: 6),
                      Text(
                        _skuController.text.isNotEmpty
                            ? _skuController.text
                            : "IPH14PROBK2024",
                        style: TextStyle(
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
                    decoration: BoxDecoration(
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
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "LC",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                            Text(
                              "SISTEMA CONFIANZA\nARTÍCULO CERTIFICADO",
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
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
          SizedBox(height: 48),

          // Botones de acción "Print Now" y "Download for Print"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
                icon: Icon(Icons.print, size: 18),
                label: Text(
                  "Imprimir Ahora",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppColors.surfaceContainerLowest,
                ),
                onPressed: () {},
                icon: Icon(Icons.download, size: 18),
                label: Text(
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
        return SizedBox(width: 4);
      }
      return Container(width: weight.toDouble() * 2, color: Colors.black);
    }).toList();
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
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TOTAL IMPRESO HOY",
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "1,248",
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12),
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
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ESTADO DE LA IMPRESORA",
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "En Línea",
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Zebra ZT411 - Bandeja 1",
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
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
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MATERIAL RESTANTE",
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        value: 0.65,
                        backgroundColor:
                            AppColors.surfaceContainerLow,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "650 etiquetas restantes",
                    style: TextStyle(
                      color: AppColors.onSurface,
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
