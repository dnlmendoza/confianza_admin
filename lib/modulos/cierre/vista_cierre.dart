import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'viewmodel_cierre.dart';

class VistaCierre extends StatefulWidget {
  const VistaCierre({super.key});

  @override
  State<VistaCierre> createState() => _VistaCierreState();
}

class _VistaCierreState extends State<VistaCierre> {
  late final ViewModelCierre vm;

  @override
  void initState() {
    super.initState();
    vm = ViewModelCierre()..addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    vm.removeListener(_onViewModelChanged);
    vm.dispose();
    super.dispose();
  }

  // Getters y métodos delegados al ViewModelCierre
  int get _activeTab => vm.activeTab;
  Map<String, dynamic>? get _selectedRecibo => vm.selectedRecibo;
  Future<DocumentSnapshot>? get _usuarioFuture => vm.usuarioFuture;
  String get _nombreUsuarioActual => vm.nombreUsuarioActual;
  String get _idUsuarioActual => vm.idUsuarioActual;

  static const List<int> _billetesFila1 = ViewModelCierre.billetesFila1;
  static const List<int> _billetesFila2 = ViewModelCierre.billetesFila2;

  Map<int, int> get _conteoBilletes => vm.conteoBilletes;
  int get _selectedDenominacion => vm.selectedDenominacion;
  TextEditingController get _stepperController => vm.stepperController;
  TextEditingController get _proveedorController => vm.proveedorController;
  FocusNode get _proveedorFocusNode => vm.proveedorFocusNode;
  String? get _proveedorSeleccionadoActivo => vm.proveedorSeleccionadoActivo;
  set _proveedorSeleccionadoActivo(String? val) =>
      vm.proveedorSeleccionadoActivo = val;
  TextEditingController get _totalEgresoController => vm.totalEgresoController;
  FocusNode get _totalEgresoFocusNode => vm.totalEgresoFocusNode;

  Stream<QuerySnapshot> get _ventasStream => vm.ventasStream;
  Stream<QuerySnapshot> get _cierreStream => vm.cierreStream;

  String get _fechaHoy => vm.fechaHoy;
  String get _horaActual => vm.horaActual;
  double get _totalConteo => vm.totalConteo;

  String _formatCurrency(double amount) => vm.formatCurrency(amount);
  void _selectDenominacion(int denom) => vm.selectDenominacion(denom);
  void _incrementSelected() => vm.incrementSelected();
  void _decrementSelected() => vm.decrementSelected();
  void _resetConteo() => vm.resetConteo();
  Color _getDenomBaseColor(int denom) => vm.getDenomBaseColor(denom);
  Color _getDenomColor(int denom) => vm.getDenomColor(denom);
  void _seleccionarRecibo(Map<String, dynamic> data) =>
      vm.seleccionarRecibo(data);

  Widget _buildBilletesChip(int denom, double width) {
    final isSelected = _selectedDenominacion == denom;
    final color = _getDenomColor(denom);
    final circleColor = _getDenomBaseColor(denom);
    final count = _conteoBilletes[denom] ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectDenominacion(denom),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              width: isSelected ? 2.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: circleColor.withValues(alpha: 0.55),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$denom',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: denom >= 100 ? 12 : 13.5,
                  ),
                ),
              ),
              if (count > 0)
                Positioned(
                  top: 2,
                  right: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _decrementSelected,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Icon(
                Icons.remove,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Container(width: 1, height: 18, color: AppColors.outlineVariant),
          SizedBox(
            width: 44,
            child: TextField(
              controller: _stepperController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              cursorColor: AppColors.primary,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                final count = int.tryParse(val) ?? 0;
                vm.setDenominacionCount(_selectedDenominacion, count);
              },
            ),
          ),
          Container(width: 1, height: 18, color: AppColors.outlineVariant),
          InkWell(
            onTap: _incrementSelected,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Icon(
                Icons.add,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteoBilletesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepper(),
              Text(
                "Total: L. ${_formatCurrency(_totalConteo)}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              InkWell(
                onTap: _resetConteo,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    "LIMPIAR",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final buttonWidth = ((constraints.maxWidth - (4 * 8)) / 5).clamp(
                38.0,
                84.0,
              );
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _billetesFila1.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        _buildBilletesChip(_billetesFila1[i], buttonWidth),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _billetesFila2.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        _buildBilletesChip(_billetesFila2[i], buttonWidth),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        vm.setActiveTab(index);
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
            child: IndexedStack(
              index: _activeTab,
              children: [_buildIngresosList(), _buildEgresosList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngresosList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _ventasStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
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

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final recibo = data['recibo']?.toString().trim();
          return recibo != null && recibo.isNotEmpty && recibo != 'S/N';
        }).toList();

        if (docs.isEmpty) {
          return const Center(
            child: Text("No hay ventas registradas el día de hoy."),
          );
        }

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

            final isSelected =
                _selectedRecibo?['recibo'] == recibo &&
                !vm.isReceiptEgreso(_selectedRecibo);

            return ListTile(
              selected: isSelected,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
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
                  '$horaFormateada • Artículos: $cantidadArticulos',
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
                final mapData = Map<String, dynamic>.from(data);
                mapData['isEgreso'] = false;
                _seleccionarRecibo(mapData);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNuevoReciboTile(String nextReciboCode) {
    final isSelected =
        _selectedRecibo?['recibo'] == nextReciboCode &&
        _selectedRecibo?['isNuevo'] == true &&
        vm.isReceiptEgreso(_selectedRecibo);

    final int nuevoArticulosCount =
        (isSelected && _selectedRecibo?['articulos'] is List)
        ? (_selectedRecibo!['articulos'] as List).length
        : 0;
    final double nuevoTotal = (isSelected && _selectedRecibo?['total'] is num)
        ? (_selectedRecibo!['total'] as num).toDouble()
        : 0.0;
    final String nuevoProveedor =
        (isSelected && _selectedRecibo?['proveedor'] is String)
        ? (_selectedRecibo!['proveedor'] as String)
        : '';

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.035),
        border: Border(
          left: BorderSide(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.6),
            width: 3.5,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Recibo $nextReciboCode',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "NUEVO",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            '$_horaActual • $nuevoArticulosCount ${nuevoArticulosCount == 1 ? 'artículo' : 'artículos'}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (nuevoProveedor.isNotEmpty) ...[
                  Text(
                    nuevoProveedor,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  'L. ${nuevoTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
        onTap: () {
          final currentUser = FirebaseAuth.instance.currentUser;
          final userUid = currentUser?.uid ?? _idUsuarioActual;
          final userName = _nombreUsuarioActual.isNotEmpty
              ? _nombreUsuarioActual
              : (currentUser?.displayName ?? 'Donald Mendoza');

          _seleccionarRecibo({
            'recibo': nextReciboCode,
            'hora': _horaActual,
            'total': 0.0,
            'proveedor': '',
            'articulos': [],
            'fecha': _fechaHoy,
            'isNuevo': true,
            'isEgreso': true,
            'id_usuario': userUid,
            'usuario': userName,
          });
        },
      ),
    );
  }

  Widget _buildEgresosList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _cierreStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error al cargar egresos: ${snapshot.error}",
              textAlign: TextAlign.center,
            ),
          );
        }

        final List<Map<String, dynamic>> egresosList = [];
        for (final doc in snapshot.data?.docs ?? []) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final rawRecibos = data['recibos_egresos'];
          if (rawRecibos is List) {
            for (final item in rawRecibos) {
              if (item is Map) {
                final mapItem = Map<String, dynamic>.from(item);
                if (!mapItem.containsKey('fecha') || mapItem['fecha'] == null) {
                  mapItem['fecha'] = data['fecha'];
                }
                egresosList.add(mapItem);
              }
            }
          }
        }

        // Calcular siguiente número correlativo (ej. E-001, E-002, etc.)
        int maxReciboNum = 0;
        for (final item in egresosList) {
          final rec = item['recibo']?.toString() ?? '';
          final match = RegExp(r'\d+').firstMatch(rec);
          if (match != null) {
            final numVal = int.tryParse(match.group(0) ?? '') ?? 0;
            if (numVal > maxReciboNum) {
              maxReciboNum = numVal;
            }
          }
        }
        final nextReciboNum = maxReciboNum + 1;
        final nextReciboCode = "E-${nextReciboNum.toString().padLeft(3, '0')}";

        // Ordenar en orden descendente (el más reciente arriba, ej: E-003, E-002, E-001)
        egresosList.sort((a, b) {
          final recA = a['recibo']?.toString() ?? '';
          final recB = b['recibo']?.toString() ?? '';
          final cmpRec = recB.compareTo(recA);
          if (cmpRec != 0) return cmpRec;
          final horaA = a['hora']?.toString() ?? '';
          final horaB = b['hora']?.toString() ?? '';
          return horaB.compareTo(horaA);
        });

        // 1 elemento para el nuevo recibo en blanco + los existentes
        final totalCount = egresosList.length + 1;

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: totalCount,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outlineVariant,
            indent: 0,
            endIndent: 0,
          ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildNuevoReciboTile(nextReciboCode);
            }

            final data = egresosList[index - 1];

            final rawRecibo = (data['recibo']?.toString() ?? 'S/N').trim();
            final String reciboTitulo =
                rawRecibo.toLowerCase().startsWith('recibo')
                ? rawRecibo
                : 'Recibo $rawRecibo';

            final isSelected =
                _selectedRecibo?['recibo'] == rawRecibo &&
                _selectedRecibo?['isNuevo'] != true &&
                vm.isReceiptEgreso(_selectedRecibo);

            int cantidadArticulos = 0;
            final articulosRaw =
                (isSelected && _selectedRecibo?['articulos'] is List)
                ? _selectedRecibo!['articulos']
                : data['articulos'];
            if (articulosRaw is List) {
              cantidadArticulos = articulosRaw.length;
            }

            final String hora = (data['hora']?.toString() ?? 'Sin hora').trim();

            final String proveedor =
                (((isSelected && _selectedRecibo?['proveedor'] != null)
                            ? _selectedRecibo!['proveedor']?.toString()
                            : data['proveedor']?.toString()) ??
                        '')
                    .trim();

            final rawTotal = (isSelected && _selectedRecibo?['total'] != null)
                ? _selectedRecibo!['total']
                : data['total'];
            final double totalNum = rawTotal is num
                ? rawTotal.toDouble()
                : (double.tryParse(rawTotal?.toString() ?? '') ?? 0.0);

            return ListTile(
              selected: isSelected,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 2,
              ),
              title: Text(
                reciboTitulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.onSurface,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  '$hora • $cantidadArticulos artículos',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (proveedor.isNotEmpty) ...[
                        Text(
                          proveedor,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        'L. ${totalNum.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  if (totalNum == 0 && proveedor.isEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      size: 22,
                    ),
                  ],
                ],
              ),
              onTap: () {
                final mapData = Map<String, dynamic>.from(data);
                if (mapData['articulos'] is List) {
                  mapData['articulos'] = List<dynamic>.from(
                    mapData['articulos'] as List,
                  );
                }
                mapData['isEgreso'] = true;
                _seleccionarRecibo(mapData);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMetadataItem(String label, String value, [IconData? icon]) {
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
                  value.isEmpty ? "---" : value,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: value.isEmpty
                        ? AppColors.onSurfaceVariant.withValues(alpha: 0.3)
                        : AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(
              icon,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              size: 18,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReceiptArticleItem(
    String qty,
    String name, [
    String? unitPrice,
    String? total,
  ]) {
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
        if (unitPrice != null && unitPrice.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            unitPrice,
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
        ],
        if (total != null && total.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            total,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
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

  Future<List<String>> _obtenerSearchIdsParaProveedor(String proveedor) =>
      vm.obtenerSearchIdsParaProveedor(proveedor);

  Future<void> _mostrarDialogoProveedor(String proveedor) async {
    _proveedorFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    final proveedorTrim = proveedor.trim();
    if (proveedorTrim.isEmpty) return;

    final errorProveedor = vm.validarAsignacionProveedor(proveedorTrim);
    if (errorProveedor != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorProveedor),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final Set<String> articulosSeleccionados = {};
    if (_selectedRecibo?['articulos'] is List) {
      for (final a in _selectedRecibo!['articulos']) {
        if (a is Map) {
          final code =
              a['codigo_barras']?.toString() ?? a['id']?.toString() ?? '';
          if (code.isNotEmpty) {
            articulosSeleccionados.add(code);
          }
        }
      }
    }
    final idsFuture = _obtenerSearchIdsParaProveedor(proveedor);
    bool isGuardando = false;

    await showDialog(
      context: context,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return FutureBuilder<List<String>>(
              future: idsFuture,
              builder: (context, idSnapshot) {
                final searchIds = idSnapshot.data ?? [proveedor.trim()];

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Inventario')
                      .where('proveedor', whereIn: searchIds)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    final totalArticulos = docs.length;
                    final seleccionados = articulosSeleccionados.length;
                    final isLoading =
                        (idSnapshot.connectionState ==
                                ConnectionState.waiting &&
                            !idSnapshot.hasData) ||
                        (snapshot.connectionState == ConnectionState.waiting &&
                            !snapshot.hasData);

                    final String infoConteo = isLoading
                        ? "Cargando artículos..."
                        : "$seleccionados seleccionados de $totalArticulos";

                    return Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 550,
                          maxHeight: screenHeight * 0.75,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.storefront_outlined,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                proveedor.isNotEmpty
                                                    ? proveedor
                                                    : "Detalle de Proveedor",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Text(
                                                    infoConteo,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: seleccionados > 0
                                                          ? AppColors.primary
                                                          : AppColors
                                                                .onSurfaceVariant,
                                                      fontWeight:
                                                          seleccionados > 0
                                                          ? FontWeight.w600
                                                          : FontWeight.w500,
                                                    ),
                                                  ),
                                                  if (!isLoading &&
                                                      docs.isNotEmpty) ...[
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "•",
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .onSurfaceVariant
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    InkWell(
                                                      onTap: () {
                                                        setDialogState(() {
                                                          if (articulosSeleccionados
                                                                  .length ==
                                                              docs.length) {
                                                            articulosSeleccionados
                                                                .clear();
                                                          } else {
                                                            articulosSeleccionados
                                                                .addAll(
                                                                  docs.map(
                                                                    (d) => d.id,
                                                                  ),
                                                                );
                                                          }
                                                        });
                                                      },
                                                      child: Text(
                                                        articulosSeleccionados
                                                                    .length ==
                                                                docs.length
                                                            ? "Deseleccionar todos"
                                                            : "Seleccionar todos",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    splashRadius: 20,
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              // Lista de artículos del inventario asociados
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    if (isLoading) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text(
                                          "Error al cargar artículos: ${snapshot.error}",
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }
                                    if (docs.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              size: 46,
                                              color: AppColors.onSurfaceVariant
                                                  .withValues(alpha: 0.35),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              "No hay artículos registrados para este proveedor.",
                                              style: TextStyle(
                                                color:
                                                    AppColors.onSurfaceVariant,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    String extraerFoto(
                                      Map<String, dynamic> data,
                                    ) {
                                      final keys = [
                                        'imagen',
                                        'foto',
                                        'image',
                                        'url_imagen',
                                        'imageUrl',
                                        'FotoUrl',
                                        'fotoUrl',
                                        'url',
                                        'Foto',
                                        'Imagen',
                                      ];
                                      for (final k in keys) {
                                        final v = data[k];
                                        if (v != null &&
                                            v.toString().trim().isNotEmpty) {
                                          return v.toString().trim();
                                        }
                                      }
                                      return '';
                                    }

                                    return ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount: docs.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: AppColors.outlineVariant,
                                          ),
                                      itemBuilder: (context, index) {
                                        final doc = docs[index];
                                        final data =
                                            doc.data()
                                                as Map<String, dynamic>? ??
                                            {};
                                        final docId = doc.id;
                                        final bool isSelected =
                                            articulosSeleccionados.contains(
                                              docId,
                                            );

                                        String nombre =
                                            (data['nombre'] ??
                                                    data['name'] ??
                                                    data['articulo'] ??
                                                    data['producto'] ??
                                                    '')
                                                .toString()
                                                .trim();
                                        String descripcion =
                                            (data['descripcion'] ??
                                                    data['detalle'] ??
                                                    '')
                                                .toString()
                                                .trim();

                                        if (nombre.isEmpty) {
                                          nombre = 'Artículo sin nombre';
                                        }
                                        final fotoUrl = extraerFoto(data);

                                        return ListTile(
                                          selected: isSelected,
                                          selectedTileColor: AppColors.primary
                                              .withValues(alpha: 0.05),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          onTap: () {
                                            setDialogState(() {
                                              if (isSelected) {
                                                articulosSeleccionados.remove(
                                                  docId,
                                                );
                                              } else {
                                                articulosSeleccionados.add(
                                                  docId,
                                                );
                                              }
                                            });
                                          },
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 4,
                                              ),
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: isSelected,
                                                activeColor: AppColors.primary,
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                side: BorderSide(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : AppColors
                                                            .outlineVariant,
                                                  width: 1.5,
                                                ),
                                                onChanged: (bool? val) {
                                                  setDialogState(() {
                                                    if (val == true) {
                                                      articulosSeleccionados
                                                          .add(docId);
                                                    } else {
                                                      articulosSeleccionados
                                                          .remove(docId);
                                                    }
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .surfaceContainerLow,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: AppColors
                                                        .outlineVariant
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                ),
                                                child: fotoUrl.isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: Image.network(
                                                          fotoUrl,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) => const Icon(
                                                                Icons
                                                                    .image_not_supported_outlined,
                                                                size: 22,
                                                                color: AppColors
                                                                    .onSurfaceVariant,
                                                              ),
                                                        ),
                                                      )
                                                    : const Icon(
                                                        Icons.image_outlined,
                                                        size: 22,
                                                        color: AppColors
                                                            .onSurfaceVariant,
                                                      ),
                                              ),
                                            ],
                                          ),
                                          title: Text(
                                            nombre,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.onSurface,
                                            ),
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2.0,
                                            ),
                                            child: Text(
                                              descripcion.isNotEmpty
                                                  ? descripcion
                                                  : "Sin descripción",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: isGuardando
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          AppColors.onSurfaceVariant,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text("Cancelar"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed:
                                        (isGuardando ||
                                            articulosSeleccionados.isEmpty)
                                        ? null
                                        : () async {
                                            setDialogState(() {
                                              isGuardando = true;
                                            });

                                            final Map<String, double>
                                            cantidadesExistentes = {};
                                            if (_selectedRecibo?['articulos']
                                                is List) {
                                              for (final a
                                                  in _selectedRecibo!['articulos']) {
                                                if (a is Map) {
                                                  final code =
                                                      a['codigo_barras']
                                                          ?.toString() ??
                                                      a['id']?.toString() ??
                                                      '';
                                                  final qty =
                                                      (a['cantidad'] as num?)
                                                          ?.toDouble() ??
                                                      1.0;
                                                  if (code.isNotEmpty) {
                                                    cantidadesExistentes[code] =
                                                        qty;
                                                  }
                                                }
                                              }
                                            }

                                            final selectedDocs = docs
                                                .where(
                                                  (d) => articulosSeleccionados
                                                      .contains(d.id),
                                                )
                                                .toList();

                                            final List<Map<String, dynamic>>
                                            nuevosArticulos = [];

                                            for (final doc in selectedDocs) {
                                              final data =
                                                  doc.data()
                                                      as Map<
                                                        String,
                                                        dynamic
                                                      >? ??
                                                  {};

                                              final nombre =
                                                  (data['nombre'] ??
                                                          data['name'] ??
                                                          data['articulo'] ??
                                                          data['producto'] ??
                                                          'Artículo')
                                                      .toString()
                                                      .trim();

                                              final cantidad =
                                                  cantidadesExistentes[doc
                                                      .id] ??
                                                  1.0;

                                              nuevosArticulos.add({
                                                'codigo_barras': doc.id,
                                                'nombre': nombre,
                                                'cantidad': cantidad,
                                                'proveedor': proveedor,
                                              });
                                            }

                                            vm.actualizarArticulosRecibo(
                                              nuevosArticulos,
                                              proveedor,
                                            );

                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isGuardando
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.add, size: 18),
                                              const SizedBox(width: 6),
                                              Text(
                                                articulosSeleccionados.isEmpty
                                                    ? "Añadir al recibo"
                                                    : "Añadir ${articulosSeleccionados.length} ${articulosSeleccionados.length == 1 ? 'artículo' : 'artículos'}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
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
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );

    if (mounted) {
      _proveedorFocusNode.unfocus();
      FocusScope.of(context).unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {});
    }
  }

  Widget _buildRecibosSection() {
    if (_selectedRecibo == null) {
      return Center(
        child: Text(
          _activeTab == 0 ? "Seleccione una venta" : "Seleccione un egreso",
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    final data = _selectedRecibo!;
    final bool receiptIsEgreso = vm.isReceiptEgreso(data);
    final bool currentTabIsEgreso = _activeTab == 1;

    if (receiptIsEgreso != currentTabIsEgreso) {
      return Center(
        child: Text(
          currentTabIsEgreso ? "Seleccione un egreso" : "Seleccione una venta",
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    final bool isEgreso = receiptIsEgreso;
    final recibo = data['recibo']?.toString() ?? 'S/N';
    final hora = data['hora']?.toString() ?? 'Sin hora';

    final articulosList = data['articulos'] is List
        ? (data['articulos'] as List)
        : [];
    final articulosCount = articulosList.length;
    final total = data['total'] ?? 0.0;

    final String usuarioActualNombre = _nombreUsuarioActual.isNotEmpty
        ? _nombreUsuarioActual
        : (FirebaseAuth.instance.currentUser?.displayName ??
              FirebaseAuth.instance.currentUser?.email?.split('@').first ??
              'Donald Mendoza');

    final rawUsuario = (data['isNuevo'] == true)
        ? usuarioActualNombre
        : (data['usuario'] ??
              data['vendedor'] ??
              data['id_usuario'] ??
              usuarioActualNombre);

    final fallbackUsuario =
        (rawUsuario != null &&
            rawUsuario.toString().trim().isNotEmpty &&
            rawUsuario.toString().trim() != 'Caja')
        ? rawUsuario.toString().trim()
        : usuarioActualNombre;
    final rawCliente =
        data['cliente']?.toString() ?? data['nombre']?.toString() ?? '';
    final nombreCliente = rawCliente.trim().isNotEmpty
        ? rawCliente.trim()
        : '---';
    final rawRtn = data['rtn']?.toString() ?? '';
    final rtn = rawRtn.trim().isNotEmpty ? rawRtn.trim() : '---';
    final pagoRecibido = data['pagoRecibido'] ?? data['efectivo'] ?? total;
    final cambio = data['cambio'] ?? data['vuelto'] ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
        left: 0.0,
        right: 0.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recibo.toLowerCase().startsWith('recibo')
                          ? recibo
                          : "Recibo $recibo",
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
              ),
              const SizedBox(width: 8),
              if (isEgreso)
                SizedBox(
                  width: 118,
                  child: TextField(
                    controller: _totalEgresoController,
                    focusNode: _totalEgresoFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onTap: () {
                      if (_totalEgresoController.text == '0.00' ||
                          _totalEgresoController.text == '0') {
                        _totalEgresoController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _totalEgresoController.text.length,
                        );
                      }
                    },
                    onTapOutside: (_) {
                      _totalEgresoFocusNode.unfocus();
                      vm.formatearTotalEgresoMonetario();
                    },
                    onSubmitted: (_) {
                      vm.formatearTotalEgresoMonetario();
                    },
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      labelText: "Total",
                      prefixText: "L. ",
                      prefixStyle: const TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      hintText: "0.00",
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      floatingLabelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      vm.onTotalEgresoChanged(val);
                    },
                  ),
                )
              else
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
                      nombreUsuario = fallbackUsuario;
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      nombreUsuario = _nombreUsuarioActual.isNotEmpty
                          ? _nombreUsuarioActual
                          : fallbackUsuario;
                    } else if (snapshot.hasError) {
                      nombreUsuario = fallbackUsuario;
                    } else if (snapshot.hasData && snapshot.data!.exists) {
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>? ?? {};
                      final nombres =
                          (userData['Nombres'] ??
                                  userData['nombres'] ??
                                  userData['Nombre'] ??
                                  userData['nombre'] ??
                                  '')
                              .toString()
                              .trim();
                      final apellidos =
                          (userData['Apellidos'] ??
                                  userData['apellidos'] ??
                                  userData['Apellido'] ??
                                  userData['apellido'] ??
                                  '')
                              .toString()
                              .trim();

                      final primerNombre = nombres.isNotEmpty
                          ? nombres.split(RegExp(r'\s+')).first
                          : '';
                      final primerApellido = apellidos.isNotEmpty
                          ? apellidos.split(RegExp(r'\s+')).first
                          : '';

                      final nombreCompleto = "$primerNombre $primerApellido"
                          .trim();
                      if (nombreCompleto.isNotEmpty) {
                        nombreUsuario = nombreCompleto;
                      } else if (nombres.isNotEmpty) {
                        nombreUsuario = nombres;
                      } else {
                        nombreUsuario =
                            userData['displayName']?.toString() ??
                            userData['name']?.toString() ??
                            userData['correo']?.toString() ??
                            fallbackUsuario;
                      }
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        (!snapshot.hasData || !snapshot.data!.exists)) {
                      nombreUsuario = fallbackUsuario;
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
                if (isEgreso) ...[
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool tieneArticulos = articulosList.isNotEmpty;
                      final String proveedorFijado =
                          (_selectedRecibo?['proveedor']?.toString() ?? '')
                              .trim();

                      return RawAutocomplete<String>(
                        key: ValueKey(
                          'prov_ac_${_selectedRecibo?['id'] ?? ''}_${_proveedorSeleccionadoActivo ?? ''}_$tieneArticulos',
                        ),
                        textEditingController: _proveedorController,
                        focusNode: _proveedorFocusNode,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          return vm.filtrarProveedores(textEditingValue.text);
                        },
                        onSelected: (String selection) {
                          final error = vm.validarAsignacionProveedor(
                            selection,
                          );
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          vm.onProveedorSelected(selection);
                          _mostrarDialogoProveedor(selection);
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                readOnly: tieneArticulos,
                                onTap: tieneArticulos
                                    ? () {
                                        focusNode.unfocus();
                                        if (proveedorFijado.isNotEmpty) {
                                          _mostrarDialogoProveedor(
                                            proveedorFijado,
                                          );
                                        }
                                      }
                                    : null,
                                onTapOutside: (_) {
                                  focusNode.unfocus();
                                },
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Proveedor",
                                  helperText: tieneArticulos
                                      ? "Artículos seleccionados de este proveedor"
                                      : null,
                                  helperStyle: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                  ),
                                  floatingLabelStyle: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (controller.text.trim().isNotEmpty)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.inventory_2_outlined,
                                            color: AppColors.primary,
                                            size: 18,
                                          ),
                                          tooltip: tieneArticulos
                                              ? "Ver / modificar artículos de $proveedorFijado"
                                              : "Ver artículos del proveedor",
                                          splashRadius: 18,
                                          onPressed: () {
                                            focusNode.unfocus();
                                            _mostrarDialogoProveedor(
                                              tieneArticulos
                                                  ? proveedorFijado
                                                  : controller.text.trim(),
                                            );
                                          },
                                        ),
                                      if (tieneArticulos)
                                        Tooltip(
                                          message:
                                              "Proveedor bloqueado: elimine los artículos para cambiar de proveedor",
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            child: Icon(
                                              Icons.lock_outline,
                                              size: 16,
                                              color: AppColors.onSurfaceVariant
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  filled: true,
                                  fillColor: tieneArticulos
                                      ? AppColors.surfaceContainerLow
                                      : AppColors.surfaceContainerLowest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: tieneArticulos
                                          ? AppColors.outlineVariant
                                          : AppColors.primary,
                                      width: tieneArticulos ? 1.0 : 1.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  vm.onProveedorChanged(val);
                                },
                              );
                            },
                        optionsViewBuilder: (context, onSelected, options) {
                          if (tieneArticulos) {
                            return const SizedBox.shrink();
                          }
                          final currentText = _proveedorController.text
                              .trim()
                              .toLowerCase();
                          final hasSelection =
                              _proveedorSeleccionadoActivo != null &&
                              currentText ==
                                  _proveedorSeleccionadoActivo!
                                      .trim()
                                      .toLowerCase();
                          if (hasSelection || !_proveedorFocusNode.hasFocus) {
                            return const SizedBox.shrink();
                          }
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 6,
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              shadowColor: Colors.black26,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: 180,
                                  maxWidth: constraints.maxWidth,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.outlineVariant.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: AppColors.outlineVariant,
                                      ),
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () {
                                        _proveedorSeleccionadoActivo = option;
                                        _proveedorFocusNode.unfocus();
                                        FocusScope.of(context).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        onSelected(option);
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 9,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.storefront_outlined,
                                              size: 16,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ] else ...[
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Articles List
          Expanded(
            child: articulosList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 38,
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['isNuevo'] == true
                              ? "Recibo en blanco listo para registrar artículos"
                              : "No hay artículos en este recibo",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: articulosList.length,
                    itemBuilder: (context, index) {
                      final art = articulosList[index];
                      final artMap = art as Map<String, dynamic>? ?? {};
                      final dynamic rawQty = artMap['cantidad'];
                      String qtyStr = '1x';
                      double qtyNum = 1.0;
                      if (rawQty is num) {
                        qtyNum = rawQty.toDouble();
                        qtyStr = rawQty % 1 == 0
                            ? "${rawQty.toInt()}x"
                            : "${rawQty}x";
                      } else if (rawQty != null) {
                        final parsed = double.tryParse(rawQty.toString());
                        if (parsed != null) {
                          qtyNum = parsed;
                          qtyStr = parsed % 1 == 0
                              ? "${parsed.toInt()}x"
                              : "${parsed}x";
                        } else {
                          qtyStr = "${rawQty}x";
                        }
                      }
                      final name =
                          artMap['nombre']?.toString() ??
                          artMap['producto']?.toString() ??
                          artMap['articulo']?.toString() ??
                          'Artículo';
                      final unitPrice =
                          (artMap['precio'] as num?)?.toDouble() ?? 0.0;
                      final artTotal =
                          (artMap['total'] as num?)?.toDouble() ??
                          (artMap['subtotal'] as num?)?.toDouble() ??
                          (unitPrice * qtyNum);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildReceiptArticleItem(
                                qtyStr,
                                name,
                                isEgreso
                                    ? null
                                    : "L. ${unitPrice.toStringAsFixed(2)}",
                                isEgreso
                                    ? null
                                    : "L. ${artTotal.toStringAsFixed(2)}",
                              ),
                            ),
                            if (isEgreso) ...[
                              const SizedBox(width: 6),
                              Tooltip(
                                message: "Eliminar de la lista",
                                child: InkWell(
                                  onTap: () {
                                    vm.removerArticuloRecibo(index);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.close,
                                      size: 15,
                                      color: AppColors.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (!isEgreso) ...[
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
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    final metadataBar = StreamBuilder<QuerySnapshot>(
      stream: _ventasStream,
      builder: (context, snapshot) {
        final docs = (snapshot.data?.docs ?? []).where((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final recibo = data['recibo']?.toString().trim();
          return recibo != null && recibo.isNotEmpty && recibo != 'S/N';
        }).toList();

        final totalVentas = docs.length;
        final cantidadTexto =
            "$totalVentas ${totalVentas == 1 ? 'venta' : 'ventas'}";

        return Container(
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
                  "CANTIDAD DE VENTAS",
                  cantidadTexto,
                  Icons.receipt_long_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
              ),
              Expanded(child: _buildMetadataItem("ESPACIO VACIO", "")),
              Container(
                width: 1,
                height: 48,
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
              ),
              Expanded(child: _buildMetadataItem("ESPACIO VACIO", "")),
              Container(
                width: 1,
                height: 48,
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
              ),
              Expanded(
                child: _buildMetadataItem(
                  "FECHA",
                  _fechaHoy,
                  Icons.calendar_month_outlined,
                ),
              ),
            ],
          ),
        );
      },
    );

    return Card(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
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
                        _buildConteoBilletesCard(),
                        const SizedBox(height: 16),
                        const Expanded(child: SizedBox()),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // Lógica para finalizar
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
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
