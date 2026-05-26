import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'vista_generador.dart'; // Para BarcodeEntry

class ServicioGenerador {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> guardarCodigo(BarcodeEntry entry) async {
    try {
      final docRef = _firestore.collection('Codigos').doc(entry.barcode);

      // Verificamos si el código ya existe en Codigos
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        throw Exception(
          'El código de barras ya existe en la lista de Códigos Generados.',
        );
      }

      // Verificamos si el código ya existe en Inventario
      final inventarioRef = _firestore
          .collection('Inventario')
          .doc(entry.barcode);
      final inventarioSnapshot = await inventarioRef.get();
      if (inventarioSnapshot.exists) {
        throw Exception(
          'Este código de barras ya pertenece a un artículo en el Inventario.',
        );
      }

      final now = entry.createdAt;
      final fechaStr =
          "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

      // Guardamos el código de manera eficiente
      await docRef.set({
        'nombre': entry.name,
        'codigo': entry.hasOriginalCode,
        'precio': entry.price,
        'Creado': fechaStr,
      });

      debugPrint("DEBUG: Código guardado exitosamente: ${entry.barcode}");
    } catch (e) {
      debugPrint("DEBUG: ERROR en guardarCodigo: $e");
      rethrow;
    }
  }

  Future<void> actualizarCodigo(BarcodeEntry entry) async {
    try {
      final docRef = _firestore.collection('Codigos').doc(entry.barcode);

      await docRef.update({'nombre': entry.name, 'precio': entry.price});

      debugPrint("DEBUG: Código actualizado exitosamente: ${entry.barcode}");
    } catch (e) {
      debugPrint("DEBUG: ERROR en actualizarCodigo: $e");
      rethrow;
    }
  }

  Future<void> eliminarCodigo(String barcode) async {
    try {
      await _firestore.collection('Codigos').doc(barcode).delete();
      debugPrint("DEBUG: Código eliminado exitosamente: $barcode");
    } catch (e) {
      debugPrint("DEBUG: ERROR en eliminarCodigo: $e");
      rethrow;
    }
  }

  DateTime _parseFecha(Map<String, dynamic> data) {
    final val = data['Creado'] ?? data['fechaCreado'];
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is String) {
      try {
        final parts = val.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } catch (_) {}
      return DateTime.tryParse(val) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Stream<List<BarcodeEntry>> listenToCodigos() {
    return _firestore.collection('Codigos').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        final codigoVal = data['codigo'];
        
        final String barcodeStr;
        final bool esOriginalVal;
        
        if (codigoVal is bool) {
          barcodeStr = doc.id;
          esOriginalVal = codigoVal;
        } else {
          barcodeStr = (codigoVal is String && codigoVal.isNotEmpty) ? codigoVal : doc.id;
          final esOrig = data['esOriginal'];
          esOriginalVal = esOrig is bool ? esOrig : false;
        }

        return BarcodeEntry(
          id: doc.id,
          name: data['nombre'] ?? '',
          barcode: barcodeStr,
          price: data['precio'] ?? '0.00',
          createdAt: _parseFecha(data),
          hasOriginalCode: esOriginalVal,
        );
      }).toList();
      // Ordenar cronológicamente descendente en memoria
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
