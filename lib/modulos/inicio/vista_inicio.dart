import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:confianza_admin/core/widgets/admin_layout.dart';
import 'package:confianza_admin/core/theme/app_colors.dart';

class VistaInicio extends StatefulWidget {
  const VistaInicio({super.key});

  @override
  State<VistaInicio> createState() => _VistaInicioState();
}

class _VistaInicioState extends State<VistaInicio> {
  bool _isAuditing = false;
  bool _isRepairing = false;

  final _expectedFields = const [
    'nombre',
    'descripcion',
    'proveedor',
    'categoria',
    'estado',
    'imagen',
    'cantidad_minima',
    'tipo_producto',
    'menor_mayor',
    'fecha'
  ];

  void _runAudit() async {
    setState(() => _isAuditing = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Inventario').get();
      Map<String, Map<String, dynamic>> anomalies = {};
      int totalAudited = 0;

      for (var doc in snapshot.docs) {
        totalAudited++;
        final data = doc.data();
        
        List<String> missingFields = [];
        for (String field in _expectedFields) {
          if (!data.containsKey(field) || data[field] == null) {
            missingFields.add(field);
          }
        }
        
        if (missingFields.isNotEmpty) {
          anomalies[doc.id] = {
            'nombre': data['nombre'] ?? 'Sin nombre',
            'faltan': missingFields,
          };
        }
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: Text("Auditoría de Campos Faltantes ($totalAudited artículos)"),
            content: SizedBox(
              width: double.maxFinite,
              child: anomalies.isEmpty
                  ? const Text("✅ ¡Excelente! Todos los artículos tienen sus 10 campos completos.")
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: anomalies.length,
                      itemBuilder: (ctx, idx) {
                        final docId = anomalies.keys.elementAt(idx);
                        final itemData = anomalies[docId]!;
                        final nombre = itemData['nombre'];
                        final faltan = itemData['faltan'] as List<String>;
                        
                        return ListTile(
                          title: Text("Artículo: $nombre"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ID: $docId", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              Text("Faltan (${faltan.length}): ${faltan.join(', ')}", 
                                   style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text("Entendido"))
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isAuditing = false);
      }
    }
  }

  void _runRepair() async {
    setState(() => _isRepairing = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Inventario').get();
      int totalReparados = 0;
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        Map<String, dynamic> updates = {};
        
        for (String field in _expectedFields) {
          if (!data.containsKey(field) || data[field] == null) {
            // Asignar valor por defecto dependiendo del tipo esperado
            if (field == 'cantidad_minima') {
              updates[field] = 0;
            } else if (field == 'menor_mayor') {
              updates[field] = false;
            } else if (field == 'estado') {
              updates[field] = 'Activo';
            } else {
              updates[field] = '';
            }
          }
        }
        
        if (updates.isNotEmpty) {
          totalReparados++;
          batch.update(doc.reference, updates);
        }
      }

      if (totalReparados > 0) {
        await batch.commit();
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text("Reparación Masiva Completada"),
            content: SizedBox(
              width: double.maxFinite,
              child: Text(
                totalReparados == 0 
                  ? "✅ ¡Todo está perfecto! Ningún artículo necesita campos."
                  : "🚀 ¡Éxito! Se rellenaron los campos faltantes a $totalReparados artículos."
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text("Genial"))
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isRepairing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      activeRoute: '/inicio',
      title: 'Inicio',
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction_rounded,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  "Módulo en Desarrollo",
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Por favor, seleccione otros módulos en el menú lateral para continuar.",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: (_isAuditing || _isRepairing) ? null : _runAudit,
                      icon: _isAuditing 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.analytics),
                      label: const Text("Auditar Campos Faltantes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: (_isAuditing || _isRepairing) ? null : _runRepair,
                      icon: _isRepairing 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.build),
                      label: const Text("Reparar Campos (Rellenar Vacíos)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
