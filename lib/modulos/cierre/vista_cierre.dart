import 'package:flutter/material.dart';
import 'package:confianza_admin/main.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                    _Header(
                      scaffoldKey: _scaffoldKey,
                      isDesktop: isDesktop,
                      searchController: _searchController,
                      onSearchChanged: (val) {
                        setState(() {});
                      },
                    ),

                    // Cuerpo de Cierre de Caja
                    Expanded(
                      child: isDesktop
                          ? Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Panel izquierdo: Bento de Métricas e Historial de transacciones
                                  Expanded(
                                    flex: 7,
                                    child: _buildLeftRecordsPanel(context),
                                  ),
                                  const SizedBox(width: 24),
                                  // Panel derecho: Contador de Billetes y Respaldo
                                  Expanded(
                                    flex: 5,
                                    child: _buildRightBillCounterPanel(context),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildLeftRecordsPanel(context, shrinkWrap: true),
                                  const SizedBox(height: 24),
                                  _buildRightBillCounterPanel(context, shrinkWrap: true),
                                ],
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

  /// PANEL IZQUIERDO: Bento de Resumen y Tabla de Detalle
  Widget _buildLeftRecordsPanel(BuildContext context, {bool shrinkWrap = false}) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick Summary Bento Grid
        _buildBentoGrid(context),
        const SizedBox(height: 24),

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
          value: "\$4,852.50",
          subtitle: "12% vs ayer",
          icon: Icons.trending_up,
          iconColor: const Color(0xFF10B981),
          subtitleColor: const Color(0xFF10B981),
        ),
        _buildBentoCard(
          title: "Egresos / Gastos",
          value: "\$342.20",
          subtitle: "8 comprobantes",
          icon: Icons.receipt_long,
          iconColor: const Color(0xFFBA1A1A),
          subtitleColor: colorOnSurfaceVariant,
        ),
        _buildBentoCard(
          title: "Balance Neto",
          value: "\$4,510.30",
          subtitle: "Efectivo esperado",
          icon: Icons.account_balance_wallet,
          iconColor: colorPrimary,
          subtitleColor: colorPrimary,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
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
            style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          Text(
            value,
            style: const TextStyle(color: colorOnSurface, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 4),
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
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colorSurfaceContainerLow.withValues(alpha: 0.5),
              border: const Border(bottom: BorderSide(color: colorOutlineVariant, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Detalle de Movimientos",
                  style: TextStyle(color: colorOnSurface, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () => _simulatePdfExport(),
                      icon: const Icon(Icons.picture_as_pdf, size: 16, color: colorPrimary),
                      label: const Text("Exportar PDF", style: TextStyle(color: colorPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    // Menú de Filtro Interactivo
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list, size: 20, color: colorOnSurfaceVariant),
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
                    decoration: const BoxDecoration(
                      color: colorSurfaceContainerLow,
                      border: Border(bottom: BorderSide(color: colorOutlineVariant, width: 1)),
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
                        const SizedBox(),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 40, color: colorOutlineVariant),
                              SizedBox(height: 8),
                              Text(
                                "No se encontraron movimientos",
                                style: TextStyle(color: colorOnSurfaceVariant, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(),
                        const SizedBox(),
                      ],
                    )
                  else
                    ...filtered.map((item) {
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: colorOutlineVariant, width: 0.5)),
                        ),
                        children: [
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Text(
                                item.time,
                                style: const TextStyle(fontFamily: 'monospace', color: colorOnSurfaceVariant, fontSize: 13),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                item.description,
                                style: const TextStyle(color: colorOnSurface, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: UnconstrainedBox(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: item.isIngreso
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFDF2F2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.isIngreso ? "INGRESO" : "EGRESO",
                                    style: TextStyle(
                                      color: item.isIngreso
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFBA1A1A),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                "${item.isIngreso ? '' : '-'}\$${item.amount.toStringAsFixed(2)}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: item.isIngreso ? colorOnSurface : const Color(0xFFBA1A1A),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        label,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          color: colorOnSurfaceVariant,
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorInverseSurface,
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
                          style: TextStyle(color: colorOutlineVariant, fontSize: 12),
                        ),
                      ],
                    ),
                    Icon(Icons.payments, color: colorPrimaryContainer, size: 28),
                  ],
                ),
                const SizedBox(height: 20),

                // Lista de Denominaciones Escroleable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDenominationRow(label: "100", title: "Billetes de \$100", subtitle: "Denominación Alta", controller: _cnt100Controller, factor: 100),
                        _buildDenominationRow(label: "50", title: "Billetes de \$50", controller: _cnt50Controller, factor: 50),
                        _buildDenominationRow(label: "20", title: "Billetes de \$20", controller: _cnt20Controller, factor: 20),
                        _buildDenominationRow(label: "10", title: "Billetes de \$10", controller: _cnt10Controller, factor: 10),
                        _buildDenominationRow(label: "5", title: "Billetes de \$5", controller: _cnt5Controller, factor: 5),
                        _buildCoinRow(controller: _coinsController),
                      ],
                    ),
                  ),
                ),
                const Divider(color: Colors.white10, height: 24),

                // Footer Actions y Sumas
                _buildCounterFooter(context),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  color: colorPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(color: colorPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: colorOutlineVariant.withValues(alpha: 0.7), fontSize: 10)),
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
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimaryContainer)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 76,
                child: Text(
                  "\$${computedVal.toStringAsFixed(2)}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: colorOutlineVariant, fontWeight: FontWeight.bold, fontSize: 13),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  color: colorOnSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.toll, color: colorOutlineVariant, size: 20),
              ),
              const SizedBox(width: 14),
              const Text("Monedas y Otros", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimaryContainer)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 76,
                child: Text(
                  "\$${computedVal.toStringAsFixed(2)}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: colorOutlineVariant, fontWeight: FontWeight.bold, fontSize: 13),
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
                const Text(
                  "TOTAL CONTADO",
                  style: TextStyle(color: colorOutlineVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "\$${_totalCounted.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                      style: const TextStyle(color: colorPrimaryContainer, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isMatched ? Icons.check_circle : Icons.error_outline,
                      color: isMatched ? const Color(0xFF10B981) : const Color(0xFFFBBF24),
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Diferencia",
                  style: TextStyle(color: colorOutlineVariant, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  "\$${_difference.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: isMatched ? const Color(0xFF10B981) : const Color(0xFFFBBF24),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _showFinishClosureDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 52),
            elevation: 2,
          ),
          icon: const Icon(Icons.verified, size: 20),
          label: const Text("Finish Closure", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildSyncCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorSurfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cloud_sync, color: colorOnSurfaceVariant, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sincronización en la Nube",
                  style: TextStyle(color: colorOnSurface, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "Último respaldo hace 2 minutos",
                  style: TextStyle(color: colorOnSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
                      border: Border.all(color: colorSurfaceContainerLowest, width: 2),
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
                      border: Border.all(color: colorSurfaceContainerLowest, width: 2),
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
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(24),
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
              backgroundColor: colorSurfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(strokeWidth: 3, color: colorPrimary),
                    SizedBox(height: 20),
                    Text(
                      "Generando reporte de caja...",
                      style: TextStyle(color: colorOnSurface, fontWeight: FontWeight.bold, fontSize: 14),
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
          backgroundColor: colorSurfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isMatched ? Icons.verified_user : Icons.warning_amber_rounded,
                color: isMatched ? const Color(0xFF10B981) : const Color(0xFFFBBF24),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text("Confirmar Cierre de Caja", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "¿Está seguro de que desea finalizar el cierre de caja de hoy? A continuación el desglose final:",
                style: TextStyle(color: colorOnSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildDialogSummaryRow("Efectivo Esperado:", "\$${_expectedBalance.toStringAsFixed(2)}"),
              _buildDialogSummaryRow("Total Contado:", "\$${_totalCounted.toStringAsFixed(2)}"),
              const Divider(height: 16),
              _buildDialogSummaryRow(
                "Diferencia:",
                "\$${_difference.toStringAsFixed(2)}",
                valueColor: isMatched ? const Color(0xFF10B981) : const Color(0xFFBA1A1A),
                isBold: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: colorOnSurfaceVariant, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(24),
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
              style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, foregroundColor: Colors.white),
              child: const Text("Finalizar y Sincronizar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogSummaryRow(String label, String value, {Color valueColor = colorOnSurface, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: colorOnSurfaceVariant, fontSize: 13)),
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

/// CABECERA SUPERIOR (Búsqueda y Perfil)
class _Header extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isDesktop;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _Header({
    required this.scaffoldKey,
    required this.isDesktop,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: _VistaCierreState.colorSurfaceContainerLowest,
        border: Border(bottom: BorderSide(color: _VistaCierreState.colorOutlineVariant, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop) ...[
                IconButton(
                  icon: const Icon(Icons.menu, color: _VistaCierreState.colorOnSurface),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              const Text(
                "RetailAdmin Pro",
                style: TextStyle(color: _VistaCierreState.colorPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 32),
              if (isDesktop)
                Container(
                  width: 320,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _VistaCierreState.colorSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: "Buscar transacción...",
                      hintStyle: TextStyle(color: _VistaCierreState.colorOnSurfaceVariant, fontSize: 13),
                      prefixIcon: Icon(Icons.search, size: 18, color: _VistaCierreState.colorOnSurfaceVariant),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 22, color: _VistaCierreState.colorOnSurfaceVariant),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22, color: _VistaCierreState.colorOnSurfaceVariant),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _VistaCierreState.colorPrimaryContainer, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida/ADBb0uj8I9f53CpSj40cca_fxt6KDo57B4z5FBtDqrwX6YOaNbbsU1WX7mEhu5cunyifZXLih2dswdROV7dw0Js73dJ6-qs5F2VgSeZBUVN4YFIaVu_oLsBL2c-rstYiGoQhE-uY0TM2gcuR09ryDxDAHAGOxRwKRDsshuF-3NnsAIx7hHyVwi16RaRRLlSy9jG1gnABu5nQv53OELiPWAR5XPkb_VxkSsTmeuvRyhFfaZfhzRVU6MflDLaPguo-x9gcLMgro1_ligRf5Q',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _VistaCierreState.colorPrimary,
                      child: const Icon(Icons.person, color: Colors.white, size: 18),
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
}

/// BARRA LATERAL (Sidebar)
class _SidebarContent extends StatelessWidget {
  final bool isDrawer;
  final VoidCallback? onToggleCollapse;

  const _SidebarContent({required this.isDrawer, this.onToggleCollapse});

  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabecera del Sidebar
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SidebarState.isCollapsed && !isDrawer ? 12.0 : 24.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: SidebarState.isCollapsed && !isDrawer ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                SidebarState.isCollapsed && !isDrawer ? "LC" : "La Confianza admin",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (!(SidebarState.isCollapsed && !isDrawer)) ...[
                const SizedBox(height: 4),
                const Text(
                  "PANEL DE CONTROL",
                  style: TextStyle(color: colorOutlineVariant, fontSize: 11),
                ),
              ],
            ],
          ),
        ),

        // Items de Navegación del Sidebar
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
                isActive: true,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
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
                isActive: false,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/generador');
                },
                isCollapsed: SidebarState.isCollapsed && !isDrawer,
              ),
            ],
          ),
        ),

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
                  icon: SidebarState.isCollapsed ? Icons.chevron_right : Icons.chevron_left,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: isActive ? colorPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 8.0 : 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : colorOutlineVariant,
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : colorOutlineVariant,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
