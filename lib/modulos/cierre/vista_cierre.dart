import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class VistaCierre extends StatefulWidget {
  const VistaCierre({super.key});

  @override
  State<VistaCierre> createState() => _VistaCierreState();
}

class _VistaCierreState extends State<VistaCierre> {
  int _activeTab = 0;
  Map<String, dynamic>? _selectedRecibo;
  Future<DocumentSnapshot>? _usuarioFuture;

  Widget _buildTabButton(int index, String label) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.outlineVariant.withValues(alpha: 0.25)
              : AppColors.outlineVariant.withValues(alpha: 0.1),
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListPanel() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton(0, "Ingresos")),
                Expanded(child: _buildTabButton(1, "Egresos")),
              ],
            ),
          ),
          Expanded(
            child: _activeTab == 0 ? _buildIngresosList() : _buildEgresosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIngresosList() {
    DateTime now = DateTime.now();
    // Formatear la fecha como "DD-MM-YYYY" para que coincida con el String en Firestore
    String formattedDate =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Ventas') // Con V mayúscula
          .where('fecha', isEqualTo: formattedDate)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error al cargar ventas: ${snapshot.error}",
              textAlign: TextAlign.center,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No hay ventas registradas el día de hoy."),
          );
        }

        final docs = snapshot.data!.docs.toList();

        // Ordenar localmente por hora descendente para evitar el error de índice de Firestore
        docs.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>? ?? {};
          final dataB = b.data() as Map<String, dynamic>? ?? {};
          final horaA = dataA['hora']?.toString() ?? '';
          final horaB = dataB['hora']?.toString() ?? '';
          return horaB.compareTo(horaA); // Descendente
        });

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: docs.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outlineVariant,
            indent: 0,
            endIndent: 0,
          ),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>? ?? {};

            // Extracción según la estructura real de Firestore
            final recibo = data['recibo'] ?? 'S/N';
            final total = data['total'] ?? 0.0;

            // Cantidad de artículos en el arreglo 'articulos'
            int cantidadArticulos = 0;
            if (data['articulos'] is List) {
              cantidadArticulos = (data['articulos'] as List).length;
            }

            // La hora ya viene como String "17:29:36"
            String horaFormateada = data['hora'] ?? 'Sin hora';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 2,
              ),
              title: Text(
                'Recibo: $recibo',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  'Hora: $horaFormateada • Artículos: $cantidadArticulos',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              trailing: Text(
                'L. ${total is num ? total.toStringAsFixed(2) : total.toString()}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedRecibo = data;
                  final idUsuario = data['id_usuario']?.toString();
                  if (idUsuario != null && idUsuario.isNotEmpty) {
                    _usuarioFuture = FirebaseFirestore.instance.collection('Usuarios').doc(idUsuario).get();
                  } else {
                    _usuarioFuture = null;
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEgresosList() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 8,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.outlineVariant,
        indent: 0,
        endIndent: 0,
      ),
      itemBuilder: (context, index) {
        return const SizedBox(height: 60);
      },
    );
  }

  Widget _buildMetadataItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptArticleItem(
    String qty,
    String name,
    String unitPrice,
    String total,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          qty,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          unitPrice,
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          total,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildReceiptFooterRow(
    String label,
    String value, {
    bool isBoldValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildRecibosSection() {
    if (_selectedRecibo == null) {
      return Center(
        child: Text(
          "Seleccione un recibo",
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    final data = _selectedRecibo!;
    final recibo = data['recibo']?.toString() ?? 'S/N';
    final hora = data['hora']?.toString() ?? 'Sin hora';

    final articulosList = data['articulos'] is List
        ? (data['articulos'] as List)
        : [];
    final articulosCount = articulosList.length;
    final total = data['total'] ?? 0.0;

    final fallbackUsuario =
        data['usuario']?.toString() ?? data['vendedor']?.toString() ?? 'Caja';
    final rawCliente = data['cliente']?.toString() ?? data['nombre']?.toString() ?? '';
    final nombreCliente = rawCliente.trim().isNotEmpty ? rawCliente.trim() : '---';
    final rawRtn = data['rtn']?.toString() ?? '';
    final rtn = rawRtn.trim().isNotEmpty ? rawRtn.trim() : '---';
    final pagoRecibido = data['pagoRecibido'] ?? data['efectivo'] ?? total;
    final cambio = data['cambio'] ?? data['vuelto'] ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 0.0, right: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recibo $recibo",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$hora • $articulosCount ${articulosCount == 1 ? 'artículo' : 'artículos'}",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                "L. ${total is num ? total.toStringAsFixed(2) : total.toString()}",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // User Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: _usuarioFuture,
                  builder: (context, snapshot) {
                    String nombreUsuario = fallbackUsuario;
                    
                    if (_usuarioFuture == null) {
                      nombreUsuario = "Sin ID ($fallbackUsuario)";
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      nombreUsuario = "Cargando...";
                    } else if (snapshot.hasError) {
                      nombreUsuario = "Error en query";
                    } else if (snapshot.hasData && snapshot.data!.exists) {
                      final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                      final nombres = userData['Nombres']?.toString() ?? userData['nombres']?.toString() ?? '';
                      final apellidos = userData['Apellidos']?.toString() ?? userData['apellidos']?.toString() ?? '';
                      
                      final primerNombre = nombres.trim().split(RegExp(r'\s+')).first;
                      final primerApellido = apellidos.trim().split(RegExp(r'\s+')).first;

                      final nombreCompleto = "$primerNombre $primerApellido".trim();
                      nombreUsuario = nombreCompleto.isNotEmpty ? nombreCompleto : fallbackUsuario;
                    } else if (snapshot.connectionState == ConnectionState.done && (!snapshot.hasData || !snapshot.data!.exists)) {
                      nombreUsuario = "ID no encontrado en DB";
                    }

                    return RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: "Usuario: "),
                          TextSpan(
                            text: nombreUsuario,
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                if (nombreCliente != '---' && rtn != '---') ...[
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: "Cliente: "),
                        TextSpan(
                          text: nombreCliente,
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: "RTN: "),
                        TextSpan(
                          text: rtn,
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: "Cliente: "),
                            TextSpan(
                              text: nombreCliente,
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: "RTN: "),
                            TextSpan(
                              text: rtn,
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Articles List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: articulosList.map((art) {
                final artMap = art as Map<String, dynamic>? ?? {};
                final qty = artMap['cantidad']?.toString() ?? '1';
                final name =
                    artMap['nombre']?.toString() ??
                    artMap['producto']?.toString() ??
                    artMap['articulo']?.toString() ??
                    'Artículo';
                final unitPrice = artMap['precio'] ?? 0.0;
                final artTotal = artMap['total'] ?? artMap['subtotal'] ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildReceiptArticleItem(
                    "${qty}x",
                    name,
                    "L. ${unitPrice is num ? unitPrice.toStringAsFixed(2) : unitPrice.toString()}",
                    "L. ${artTotal is num ? artTotal.toStringAsFixed(2) : artTotal.toString()}",
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 24),
          // Footer
          _buildReceiptFooterRow(
            "Pago recibido",
            "L. ${pagoRecibido is num ? pagoRecibido.toStringAsFixed(2) : pagoRecibido.toString()}",
            isBoldValue: false,
          ),
          const SizedBox(height: 8),
          _buildReceiptFooterRow(
            "Cambio devuelto",
            "L. ${cambio is num ? cambio.toStringAsFixed(2) : cambio.toString()}",
            isBoldValue: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    final recibo = _selectedRecibo?['recibo']?.toString() ?? 'N/A';
    final fecha = _selectedRecibo?['fecha']?.toString() ?? 'N/A';
    final totalValue = _selectedRecibo?['total'] ?? 0.0;
    final total =
        "L. ${totalValue is num ? totalValue.toStringAsFixed(2) : totalValue.toString()}";
    final proveedor =
        _selectedRecibo?['proveedor']?.toString() ??
        'N/A'; // O dejar N/A si no aplica

    final metadataBar = Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetadataItem(
              "NUMERO RECIBO",
              recibo,
              Icons.receipt_long_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
          Expanded(
            child: _buildMetadataItem(
              "FECHA",
              fecha,
              Icons.calendar_month_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
          Expanded(
            child: _buildMetadataItem(
              "TOTAL",
              total,
              Icons.category_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
          Expanded(
            child: _buildMetadataItem(
              "PROVEEDOR",
              proveedor,
              Icons.local_shipping_outlined,
            ),
          ),
        ],
      ),
    );

    return Card(
            color: AppColors.surfaceContainerLowest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Identificadores de arriba (Metadatos replicados de inventario)
                  metadataBar,
                  // (metadataBar was here)
            const SizedBox(height: 8),
            // Sección inferior (replicando lista de lotes/artículos y espacio libre)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Lista de Recibos / Artículos
                  Expanded(flex: 1, child: _buildRecibosSection()),
                  Container(
                    width: 1,
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  // Espacio de la derecha para más detalles
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(
                          child: const SizedBox(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Lógica para finalizar
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              child: const Text("Finalizar"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      activeRoute: '/cierre',
      title: 'Cierre de Caja',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          if (isMobile) {
            return Column(
              children: [
                Expanded(child: _buildListPanel()),
                Expanded(flex: 2, child: _buildDetailsPanel()),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.only(
              left: 0,
              right: 12,
              top: 0,
              bottom: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.3 < 350
                      ? 350
                      : constraints.maxWidth * 0.3,
                  child: _buildListPanel(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildDetailsPanel(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
