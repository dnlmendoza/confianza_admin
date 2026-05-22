import 'package:flutter/material.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';

/// Modelo de datos para representar un movimiento de caja
class TransactionRecord {
  final String time;
  final String description;
  final bool isIngreso;
  final double amount;

  const TransactionRecord({
    required this.time,
    required this.description,
    required this.isIngreso,
    required this.amount,
  });
}

class VistaCierre extends StatefulWidget {
  const VistaCierre({super.key});

  @override
  State<VistaCierre> createState() => _VistaCierreState();
}

class _VistaCierreState extends State<VistaCierre> {
  // Controladores para la búsqueda y filtrado
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "Todos"; // "Todos", "Ingresos", "Egresos"

  // Controladores interactivos para el conteo de billetes con valores iniciales
  final TextEditingController _cnt100Controller = TextEditingController(text: "0");
  final TextEditingController _cnt50Controller = TextEditingController(text: "12");
  final TextEditingController _cnt20Controller = TextEditingController(text: "45");
  final TextEditingController _cnt10Controller = TextEditingController(text: "82");
  final TextEditingController _cnt5Controller = TextEditingController(text: "30");
  final TextEditingController _coinsController = TextEditingController(text: "40.30");

  // Balance esperado
  static const double _expectedBalance = 4510.30;

  // Lista estática de movimientos de caja de la captura
  final List<TransactionRecord> _transactions = const [
    TransactionRecord(time: "08:15 AM", description: "Venta #9421 - Juan Pérez", isIngreso: true, amount: 120.00),
    TransactionRecord(time: "09:30 AM", description: "Pago Suministros Oficina", isIngreso: false, amount: 45.50),
    TransactionRecord(time: "11:00 AM", description: "Venta #9422 - Cliente Final", isIngreso: true, amount: 3200.00),
    TransactionRecord(time: "01:45 PM", description: "Reposición de Caja Chica", isIngreso: false, amount: 150.00),
    TransactionRecord(time: "03:20 PM", description: "Venta #9423 - Ana María", isIngreso: true, amount: 450.00),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _cnt100Controller.dispose();
    _cnt50Controller.dispose();
    _cnt20Controller.dispose();
    _cnt10Controller.dispose();
    _cnt5Controller.dispose();
    _coinsController.dispose();
    super.dispose();
  }

  // Cálculos matemáticos reactivos
  int _parseCount(String text) => int.tryParse(text) ?? 0;
  double _parseValue(String text) => double.tryParse(text) ?? 0.0;

  double get _total100 => _parseCount(_cnt100Controller.text) * 100.0;
  double get _total50 => _parseCount(_cnt50Controller.text) * 50.0;
  double get _total20 => _parseCount(_cnt20Controller.text) * 20.0;
  double get _total10 => _parseCount(_cnt10Controller.text) * 10.0;
  double get _total5 => _parseCount(_cnt5Controller.text) * 5.0;
  double get _totalCoins => _parseValue(_coinsController.text);

  double get _totalCounted => _total100 + _total50 + _total20 + _total10 + _total5 + _totalCoins;
  double get _difference => _expectedBalance - _totalCounted;

  // Filtrado de transacciones según búsqueda y tipo
  List<TransactionRecord> get _filteredTransactions {
    final query = _searchController.text.trim().toLowerCase();
    return _transactions.where((item) {
      final matchesSearch = query.isEmpty || item.description.toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == "Todos" ||
          (_selectedFilter == "Ingresos" && item.isIngreso) ||
          (_selectedFilter == "Egresos" && !item.isIngreso);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      activeRoute: '/cierre',
      title: 'Cierre de Caja',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          return isDesktop
                          ? Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Panel izquierdo: Bento de Métricas e Historial de transacciones
                                  Expanded(
                                    flex: 7,
                                    child: _buildLeftRecordsPanel(context),
                                  ),
                                  SizedBox(width: 24),
                                  // Panel derecho: Contador de Billetes y Respaldo
                                  Expanded(
                                    flex: 5,
                                    child: _buildRightBillCounterPanel(context),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildLeftRecordsPanel(context, shrinkWrap: true),
                                  SizedBox(height: 24),
                                  _buildRightBillCounterPanel(context, shrinkWrap: true),
                                ],
                              ),
                              );
        },
      ),
    );
  }

  /// PANEL IZQUIERDO: Bento de Resumen y Tabla de Detalle
  Widget _buildLeftRecordsPanel(BuildContext context, {bool shrinkWrap = false}) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick Summary Bento Grid
        _buildBentoGrid(context),
        SizedBox(height: 24),

        // Transactions Table Card
        Expanded(
          child: _buildTransactionsTableCard(context),
        ),
      ],
    );

    if (shrinkWrap) {
      return SizedBox(
        height: 680,
        child: content,
      );
    }
    return content;
  }

  Widget _buildBentoGrid(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GridView.count(
      crossAxisCount: isMobile ? 1 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isMobile ? 3.2 : 1.45,
      children: [
        _buildBentoCard(
          title: "Ventas del Día",
          value: "L. 4,852.50",
          subtitle: "12% vs ayer",
          icon: Icons.trending_up,
          iconColor: Color(0xFF10B981),
          subtitleColor: Color(0xFF10B981),
        ),
        _buildBentoCard(
          title: "Egresos / Gastos",
          value: "L. 342.20",
          subtitle: "8 comprobantes",
          icon: Icons.receipt_long,
          iconColor: Color(0xFFBA1A1A),
          subtitleColor: AppColors.onSurfaceVariant,
        ),
        _buildBentoCard(
          title: "Balance Neto",
          value: "L. 4,510.30",
          subtitle: "Efectivo esperado",
          icon: Icons.account_balance_wallet,
          iconColor: AppColors.primary,
          subtitleColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          Text(
            value,
            style: TextStyle(color: AppColors.onSurface, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(color: subtitleColor, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTableCard(BuildContext context) {
    final filtered = _filteredTransactions;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header de la Tabla
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
              border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Detalle de Movimientos",
                  style: TextStyle(color: AppColors.onSurface, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () => _simulatePdfExport(),
                      icon: Icon(Icons.picture_as_pdf, size: 16, color: AppColors.primary),
                      label: Text("Exportar PDF", style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 8),
                    // Menú de Filtro Interactivo
                    PopupMenuButton<String>(
                      icon: Icon(Icons.filter_list, size: 20, color: AppColors.onSurfaceVariant),
                      tooltip: "Filtrar por Tipo",
                      onSelected: (val) {
                        setState(() {
                          _selectedFilter = val;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "Todos", child: Text("Todos")),
                        const PopupMenuItem(value: "Ingresos", child: Text("Ingresos")),
                        const PopupMenuItem(value: "Egresos", child: Text("Egresos")),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  hintText: "Buscar movimientos...",
                  hintStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                  prefixIcon: Icon(Icons.search, size: 18, color: AppColors.onSurfaceVariant),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Cuerpo de la Tabla
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2), // Hora
                  1: FlexColumnWidth(3),   // Descripción
                  2: FlexColumnWidth(1.2), // Tipo
                  3: FlexColumnWidth(1.5), // Monto
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
                    ),
                    children: [
                      _buildTableHeaderCell("HORA"),
                      _buildTableHeaderCell("DESCRIPCIÓN"),
                      _buildTableHeaderCell("TIPO"),
                      _buildTableHeaderCell("MONTO", alignRight: true),
                    ],
                  ),
                  if (filtered.isEmpty)
                    TableRow(
                      children: [
                        SizedBox(),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.outlineVariant),
                              SizedBox(height: 8),
                              Text(
                                "No se encontraron movimientos",
                                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(),
                        SizedBox(),
                      ],
                    )
                  else
                    ...filtered.map((item) {
                      return TableRow(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
                        ),
                        children: [
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Text(
                                item.time,
                                style: TextStyle(fontFamily: 'monospace', color: AppColors.onSurfaceVariant, fontSize: 13),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                item.description,
                                style: TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: UnconstrainedBox(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: item.isIngreso
                                        ? Color(0xFFECFDF5)
                                        : Color(0xFFFDF2F2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.isIngreso ? "INGRESO" : "EGRESO",
                                    style: TextStyle(
                                      color: item.isIngreso
                                          ? Color(0xFF10B981)
                                          : Color(0xFFBA1A1A),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                "${item.isIngreso ? '' : '-'}L. ${item.amount.toStringAsFixed(2)}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: item.isIngreso ? AppColors.onSurface : Color(0xFFBA1A1A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String label, {bool alignRight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        label,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// PANEL DERECHO: Contador de Billetes Oscuro
  Widget _buildRightBillCounterPanel(BuildContext context, {bool shrinkWrap = false}) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card Principal del Contador
        Expanded(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.inverseSurface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabecera del Contador
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Contador de Billetes",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Ingrese la cantidad por denominación",
                          style: TextStyle(color: AppColors.outlineVariant, fontSize: 12),
                        ),
                      ],
                    ),
                    Icon(Icons.payments, color: AppColors.primaryContainer, size: 28),
                  ],
                ),
                SizedBox(height: 20),

                // Lista de Denominaciones Escroleable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDenominationRow(label: "100", title: "Billetes de L. 100", subtitle: "Denominación Alta", controller: _cnt100Controller, factor: 100),
                        _buildDenominationRow(label: "50", title: "Billetes de L. 50", controller: _cnt50Controller, factor: 50),
                        _buildDenominationRow(label: "20", title: "Billetes de L. 20", controller: _cnt20Controller, factor: 20),
                        _buildDenominationRow(label: "10", title: "Billetes de L. 10", controller: _cnt10Controller, factor: 10),
                        _buildDenominationRow(label: "5", title: "Billetes de L. 5", controller: _cnt5Controller, factor: 5),
                        _buildCoinRow(controller: _coinsController),
                      ],
                    ),
                  ),
                ),
                Divider(color: Colors.white10, height: 24),

                // Footer Actions y Sumas
                _buildCounterFooter(context),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // System Sync Card
        _buildSyncCard(context),
      ],
    );

    if (shrinkWrap) {
      return SizedBox(
        height: 680,
        child: content,
      );
    }
    return content;
  }

  Widget _buildDenominationRow({
    required String label,
    required String title,
    String? subtitle,
    required TextEditingController controller,
    required int factor,
  }) {
    final computedVal = _parseCount(controller.text) * factor;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(color: AppColors.primaryContainer, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: AppColors.outlineVariant.withValues(alpha: 0.7), fontSize: 10)),
                  ],
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 64,
                height: 32,
                alignment: Alignment.center,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() {}),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryContainer)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 76,
                child: Text(
                  "L. ${computedVal.toStringAsFixed(2)}",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: AppColors.outlineVariant, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinRow({required TextEditingController controller}) {
    final computedVal = _parseValue(controller.text);

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.toll, color: AppColors.outlineVariant, size: 20),
              ),
              SizedBox(width: 14),
              Text("Monedas y Otros", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Row(
            children: [
              Container(
                width: 64,
                height: 32,
                alignment: Alignment.center,
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => setState(() {}),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryContainer)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 76,
                child: Text(
                  "L. ${computedVal.toStringAsFixed(2)}",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: AppColors.outlineVariant, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterFooter(BuildContext context) {
    final isMatched = _difference.abs() < 0.01;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TOTAL CONTADO",
                  style: TextStyle(color: AppColors.outlineVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "L. ${_totalCounted.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                      style: TextStyle(color: AppColors.primaryContainer, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      isMatched ? Icons.check_circle : Icons.error_outline,
                      color: isMatched ? Color(0xFF10B981) : Color(0xFFFBBF24),
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Diferencia",
                  style: TextStyle(color: AppColors.outlineVariant, fontSize: 12),
                ),
                SizedBox(height: 2),
                Text(
                  "L. ${_difference.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: isMatched ? Color(0xFF10B981) : Color(0xFFFBBF24),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _showFinishClosureDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 52),
            elevation: 2,
          ),
          icon: Icon(Icons.verified, size: 20),
          label: Text("Finish Closure", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildSyncCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.cloud_sync, color: AppColors.onSurfaceVariant, size: 22),
          ),
          SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sincronización en la Nube",
                  style: TextStyle(color: AppColors.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "Último respaldo hace 2 minutos",
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Avatares del equipo
          SizedBox(
            width: 48,
            height: 32,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      "https://lh3.googleusercontent.com/aida/ADBb0uhDGSJL6EQq__ES4O2BHuQPLhIu-v_4g9dOUZIK7_T_C3IqAudQPDnEnlH7hHQzst4S2rPl3Mts12ht5Y-_SbdPQUu1ub7GUcjjeYWFhomHxPINBqpxAJBKO90Kswd3b-3rivbPXBAgoRs_1GjMw7pxg8GwrO_1Xbaj96ZaNyENfufKBpOtyMNO8himPTyt-B8P8C6IoXm4_AFO45XaoFL_OjYQdCZP053oRa4BQhctwEdru2Sq18tQtzpUlRRrtCpnf1nIIrF_",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      "https://lh3.googleusercontent.com/aida/ADBb0uie9aXo1SLfhg9oUGqFi4nj1R8WsE7bT8hS8vdtDW1ECX8pNL-Rs-qEps1ft0cRqFODMqLGSDXutWEiHblqTxlePbkM7J1ag0U1jYhlT6NzJ91Um7oobtKxw1OsJxhJQ_7_9VfA-LFK1hQHzAgQy9y6yiGGW1MGZGnFnws73dmYfLqbK30MdXcUhAZ1WGfR1gUjpbzN19DA1IAVrbZN_jgFGMYwIMofXIqznfNk3_ib9SomYPmsyKJkn1iqRjorMszaPyTriM1KZQ",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// DIÁLOGOS Y SIMULACIONES
  void _simulatePdfExport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (!context.mounted) return;
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text("PDF Exportado Exitosamente", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }
            });

            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                    SizedBox(height: 20),
                    Text(
                      "Generando reporte de caja...",
                      style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFinishClosureDialog(BuildContext context) {
    final isMatched = _difference.abs() < 0.01;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isMatched ? Icons.verified_user : Icons.warning_amber_rounded,
                color: isMatched ? Color(0xFF10B981) : Color(0xFFFBBF24),
                size: 28,
              ),
              SizedBox(width: 12),
              Text("Confirmar Cierre de Caja", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "¿Está seguro de que desea finalizar el cierre de caja de hoy? A continuación el desglose final:",
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
              SizedBox(height: 16),
              _buildDialogSummaryRow("Efectivo Esperado:", "L. ${_expectedBalance.toStringAsFixed(2)}"),
              _buildDialogSummaryRow("Total Contado:", "L. ${_totalCounted.toStringAsFixed(2)}"),
              Divider(height: 16),
              _buildDialogSummaryRow(
                "Diferencia:",
                "L. ${_difference.toStringAsFixed(2)}",
                valueColor: isMatched ? Color(0xFF10B981) : Color(0xFFBA1A1A),
                isBold: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    content: const Row(
                      children: [
                        Icon(Icons.cloud_done, color: Colors.white),
                        SizedBox(width: 12),
                        Text("Cierre guardado y sincronizado exitosamente", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: Text("Finalizar y Sincronizar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogSummaryRow(String label, String value, {Color valueColor = AppColors.onSurface, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

