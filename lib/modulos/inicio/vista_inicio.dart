import 'package:flutter/material.dart';

import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';

class VistaInicio extends StatefulWidget {
  const VistaInicio({super.key});

  @override
  State<VistaInicio> createState() => _VistaInicioState();
}

class _VistaInicioState extends State<VistaInicio> {
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      activeRoute: '/inicio',
      title: 'Inicio',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bento KPI Cards Section
                const _KpiCardsSection(),
                const SizedBox(height: 32),

                // Layout Intermedio: Gráfico + Notificaciones
                LayoutBuilder(
                  builder: (context, bentoConstraints) {
                    final useHorizontalSplit =
                        bentoConstraints.maxWidth >= 900;
                    if (useHorizontalSplit) {
                      return const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _SalesChartCard(),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            flex: 4,
                            child: _NotificationsCard(),
                          ),
                        ],
                      );
                    } else {
                      return const Column(
                        children: [
                          _SalesChartCard(),
                          SizedBox(height: 32),
                          _NotificationsCard(),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Tabla de Movimientos de Inventario
                const _InventoryMovementsCard(),
                const SizedBox(height: 80), // Margen para el FAB
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sección Bento de las Tarjetas KPI
class _KpiCardsSection extends StatelessWidget {
  const _KpiCardsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1100) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.8,
          children: const [
            _KpiCard(
              title: "VENTAS TOTALES",
              value: "\$45,231.89",
              icon: Icons.payments,
              iconColor: AppColors.primary,
              trendText: "+12.5%",
              isPositiveTrend: true,
              sparkHeights: [0.4, 0.6, 0.45, 0.8, 0.9],
            ),
            _KpiCard(
              title: "COMPRAS TOTALES",
              value: "\$12,840.00",
              icon: Icons.shopping_cart,
              iconColor: AppColors.secondary,
              trendText: "-3.2%",
              isPositiveTrend: false,
              sparkHeights: [0.7, 0.5, 0.65, 0.4, 0.3],
            ),
            _KpiCard(
              title: "VALOR DE INVENTARIO",
              value: "\$128,450.00",
              icon: Icons.warehouse,
              iconColor: AppColors.secondary,
              trendText: "8,420 Items",
              isPositiveTrend: true,
              useLabelTrend: true,
              sparkHeights: [0.2, 0.4, 0.6, 0.8, 1.0],
            ),
            _KpiCard(
              title: "POSICIÓN DE CAJA",
              value: "\$8,211.50",
              icon: Icons.account_balance_wallet,
              iconColor: AppColors.secondary,
              trendText: "Actualizado: 14:30",
              isPositiveTrend: true,
              useClockTrend: true,
              sparkHeights: [0.3, 0.2, 0.5, 0.7, 0.6],
            ),
          ],
        );
      },
    );
  }
}

/// Tarjeta KPI Singular
class _KpiCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String trendText;
  final bool isPositiveTrend;
  final bool useLabelTrend;
  final bool useClockTrend;
  final List<double> sparkHeights;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.trendText,
    required this.isPositiveTrend,
    this.useLabelTrend = false,
    this.useClockTrend = false,
    required this.sparkHeights,
  });

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.5),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Fila Superior (Título y Valor + Icono)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.value,
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 20),
                ),
              ],
            ),

            // Fila Inferior (Tendencia y Mini Sparkline)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Detalle de tendencia / reloj
                Row(
                  children: [
                    Icon(
                      widget.useClockTrend
                          ? Icons.schedule
                          : widget.useLabelTrend
                          ? Icons.inventory
                          : widget.isPositiveTrend
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 14,
                      color: widget.useClockTrend
                          ? Colors.green
                          : widget.useLabelTrend
                          ? AppColors.primary
                          : widget.isPositiveTrend
                          ? Colors.green
                          : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.trendText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.useClockTrend
                            ? Colors.green
                            : widget.useLabelTrend
                            ? AppColors.primary
                            : widget.isPositiveTrend
                            ? Colors.green
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),

                // Sparkline Mini-gráfico
                SizedBox(
                  height: 24,
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: widget.sparkHeights.map((heightFactor) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 10,
                        height: 24 * heightFactor,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? widget.iconColor
                              : widget.iconColor.withValues(alpha: 0.2),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(2),
                            topRight: Radius.circular(2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de Rendimiento de Ventas Mensual (Gráfico Nativo)
class _SalesChartCard extends StatelessWidget {
  const _SalesChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del gráfico
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rendimiento de Ventas Mensual",
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Comparativa de ingresos y volumen de transacciones",
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Text(
                      "Últimos 30 días",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: AppColors.onSurface,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Visualizador Gráfico
          SizedBox(
            height: 250,
            child: Row(
              children: [
                // Etiquetas del eje Y
                const SizedBox(
                  width: 32,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "\$50k",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        "\$40k",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        "\$30k",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        "\$20k",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        "\$10k",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        "0",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Cuadrícula y Columnas de Barra
                Expanded(
                  child: Stack(
                    children: [
                      // Líneas de guía horizontal
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return Container(
                            height: 1,
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.2),
                          );
                        }),
                      ),

                      // Columnas de Datos de Barra
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildChartBar(
                            label: "Sem 1",
                            heightPercent: 0.45,
                            isActive: false,
                          ),
                          _buildChartBar(
                            label: "Sem 2",
                            heightPercent: 0.65,
                            isActive: false,
                          ),
                          _buildChartBar(
                            label: "Sem 3",
                            heightPercent: 0.55,
                            isActive: false,
                          ),
                          _buildChartBar(
                            label: "Sem 4",
                            heightPercent: 0.85,
                            isActive: true,
                            tooltipValue: "\$42,300",
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
    );
  }

  Widget _buildChartBar({
    required String label,
    required double heightPercent,
    required bool isActive,
    String? tooltipValue,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Tooltip interactivo si está activo
            if (isActive && tooltipValue != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inverseSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tooltipValue,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            // Barra
            Container(
              width: 48,
              height: 200 * heightPercent,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Etiqueta del eje X
            Text(
              label,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Card Lateral de Notificaciones
class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera Notificaciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Notificaciones",
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  "3 Nuevas",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Alertas
          _buildNotificationItem(
            icon: Icons.warning,
            iconColor: AppColors.error,
            borderColor: AppColors.error,
            title: "Stock Bajo: iPhone 13 Pro",
            subtitle: "Solo quedan 2 unidades en almacén.",
            bgColor: AppColors.errorContainer.withValues(
              alpha: 0.15,
            ),
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            icon: Icons.sync,
            iconColor: AppColors.primary,
            borderColor: Colors.transparent,
            title: "Cierre de Caja Exitoso",
            subtitle: "Terminal T-01 cerrado por J. Pérez.",
            bgColor: AppColors.surfaceContainerLow,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            icon: Icons.inventory_2,
            iconColor: AppColors.secondary,
            borderColor: Colors.transparent,
            title: "Nueva Orden Recibida",
            subtitle: "Pedido #4421 del proveedor TechCorp.",
            bgColor: AppColors.surfaceContainerLow,
          ),
          const SizedBox(height: 24),

          // Botón "Ver Todas"
          SizedBox(
            height: 38,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.outlineVariant.withValues(
                    alpha: 0.8,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: AppColors.primary,
              ),
              onPressed: () {},
              child: Text(
                "Ver Todas",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String title,
    required String subtitle,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != Colors.transparent
            ? Border(left: BorderSide(color: borderColor, width: 4))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabla de Movimientos Recientes
class _InventoryMovementsCard extends StatelessWidget {
  const _InventoryMovementsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera de la sección
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(
                alpha: 0.5,
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Movimientos de Inventario Recientes",
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.filter_list,
                      label: "Filtrar",
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.add,
                      label: "Nuevo Ajuste",
                      onPressed: () {},
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabla con scroll horizontal en caso de pantallas pequeñas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: const BoxConstraints(minWidth: 1000),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(4), // Producto
                  1: FlexColumnWidth(2), // Tipo
                  2: FlexColumnWidth(1.5), // Cantidad
                  3: FlexColumnWidth(2.5), // Fecha
                  4: FlexColumnWidth(2), // Usuario
                  5: FlexColumnWidth(2), // Estado
                  6: FixedColumnWidth(64), // Acción opciones
                },
                children: [
                  // Fila de encabezado
                  _buildTableHeader(),
                  // Filas de datos
                  _buildTableRow(
                    productName: "MacBook Air M2",
                    category: "Laptops > Apple",
                    imageUrl:
                        "https://lh3.googleusercontent.com/aida/ADBb0uhDGSJL6EQq__ES4O2BHuQPLhIu-v_4g9dOUZIK7_T_C3IqAudQPDnEnlH7hHQzst4S2rPl3Mts12ht5Y-_SbdPQUu1ub7GUcjjeYWFhomHxPINBqpxAJBKO90Kswd3b-3rivbPXBAgoRs_1GjMw7pxg8GwrO_1Xbaj96ZaNyENfufKBpOtyMNO8himPTyt-B8P8C6IoXm4_AFO45XaoFL_OjYQdCZP053oRa4BQhctwEdru2Sq18tQtzpUlRRrtCpnf1nIIrF_",
                    typeIcon: Icons.add_circle,
                    typeLabel: "Entrada",
                    typeColor: Colors.green,
                    quantity: "+15",
                    date: "24 Oct, 10:15 AM",
                    user: "Carlos Mendoza",
                    status: "COMPLETADO",
                    statusBg: Colors.green[100]!,
                    statusTextColor: Colors.green[700]!,
                  ),
                  _buildTableRow(
                    productName: "Sony WH-1000XM5",
                    category: "Audio > Headphones",
                    imageUrl:
                        "https://lh3.googleusercontent.com/aida/ADBb0uie9aXo1SLfhg9oUGqFi4nj1R8WsE7bT8hS8vdtDW1ECX8pNL-Rs-qEps1ft0cRqFODMqLGSDXutWEiHblqTxlePbkM7J1ag0U1jYhlT6NzJ91Um7oobtKxw1OsJxhJQ_7_9VfA-LFK1hQHzAgQy9y6yiGGW1MGZGnFnws73dmYfLqbK30MdXcUhAZ1WGfR1gUjpbzN19DA1IAVrbZN_jgFGMYwIMofXIqznfNk3_ib9SomYPmsyKJkn1iqRjorMszaPyTriM1KZQ",
                    typeIcon: Icons.remove_circle,
                    typeLabel: "Salida (Venta)",
                    typeColor: AppColors.error,
                    quantity: "-2",
                    date: "24 Oct, 09:45 AM",
                    user: "Sistema (POS)",
                    status: "COMPLETADO",
                    statusBg: Colors.green[100]!,
                    statusTextColor: Colors.green[700]!,
                  ),
                  _buildTableRow(
                    productName: "iPad Pro 11\"",
                    category: "Tablets > Apple",
                    imageUrl:
                        "https://lh3.googleusercontent.com/aida/ADBb0uh4Tj2eAXE_OWkZULpzK2h_Q8kPH-6MKNSC3wbUiSjuIeQFgke68asTEoP-OwydyJR-vHaoOza7-NbITPCUY5rVOcE1mVdRPQtX9q0SG1qsAzcLthOhHL7RXQrKwN5MUn190NZySmD45LzmuuocLrnRLtLizsFeVJg17xPdRcoksECY2NRTFBwqGF1qSGBRE0u6S_sNW2K1Y2G-WbYFAKgssRVf1iBWY9t6Y0HlbB1OPEA5Hd3iBoWqR_H4Vf3RS36pKAheDSSlQg",
                    typeIcon: Icons.swap_horiz,
                    typeLabel: "Transferencia",
                    typeColor: AppColors.secondary,
                    quantity: "5",
                    date: "24 Oct, 08:30 AM",
                    user: "Admin Central",
                    status: "EN TRÁNSITO",
                    statusBg: AppColors.surfaceContainerLow,
                    statusTextColor: AppColors.onSurfaceVariant,
                  ),
                  _buildTableRow(
                    productName: "Samsung Galaxy S23",
                    category: "Mobile > Samsung",
                    imageUrl:
                        "https://lh3.googleusercontent.com/aida/ADBb0uj8I9f53CpSj40cca_fxt6KDo57B4z5FBtDqrwX6YOaNbbsU1WX7mEhu5cunyifZXLih2dswdROV7dw0Js73dJ6-qs5F2VgSeZBUVN4YFIaVu_oLsBL2c-rstYiGoQhE-uY0TM2gcuR09ryDxDAHAGOxRwKRDsshuF-3NnsAIx7hHyVwi16RaRRLlSy9jG1gnABu5nQv53OELiPWAR5XPkb_VxkSsTmeuvRyhFfaZfhzRVU6MflDLaPguo-x9gcLMgro1_ligRf5Q",
                    typeIcon: Icons.add_circle,
                    typeLabel: "Entrada",
                    typeColor: Colors.green,
                    quantity: "+20",
                    date: "23 Oct, 17:20 PM",
                    user: "Maria Rojas",
                    status: "COMPLETADO",
                    statusBg: Colors.green[100]!,
                    statusTextColor: Colors.green[700]!,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary
              ? AppColors.primary
              : AppColors.surfaceContainerLowest,
          foregroundColor: isPrimary
              ? Colors.white
              : AppColors.onSurfaceVariant,
          side: isPrimary
              ? null
              : BorderSide(
                  color: AppColors.outlineVariant.withValues(
                    alpha: 0.8,
                  ),
                ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      children: [
        _buildHeaderCell("Producto"),
        _buildHeaderCell("Tipo"),
        _buildHeaderCell("Cantidad", isCentered: true),
        _buildHeaderCell("Fecha"),
        _buildHeaderCell("Usuario"),
        _buildHeaderCell("Estado"),
        const TableCell(child: SizedBox(height: 38)),
      ],
    );
  }

  Widget _buildHeaderCell(String label, {bool isCentered = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Text(
        label.toUpperCase(),
        textAlign: isCentered ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  TableRow _buildTableRow({
    required String productName,
    required String category,
    required String imageUrl,
    required IconData typeIcon,
    required String typeLabel,
    required Color typeColor,
    required String quantity,
    required String date,
    required String user,
    required String status,
    required Color statusBg,
    required Color statusTextColor,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      children: [
        // Producto
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surfaceContainerLow,
                      child: Icon(
                        Icons.image,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tipo
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(typeIcon, color: typeColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  typeLabel,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Cantidad
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(
            quantity,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),

        // Fecha
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              date,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ),

        // Usuario
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              user,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 12,
              ),
            ),
          ),
        ),

        // Estado
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Botón opciones
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
