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
        throw Exception('El código de barras ya existe en la lista de Códigos Generados.');
      }

      // Verificamos si el código ya existe en Inventario
      final inventarioRef = _firestore.collection('Inventario').doc(entry.barcode);
      final inventarioSnapshot = await inventarioRef.get();
      if (inventarioSnapshot.exists) {
        throw Exception('Este código de barras ya pertenece a un artículo en el Inventario.');
      }

      // Guardamos el código de manera eficiente
      await docRef.set({
        'nombre': entry.name,
        'codigo': entry.barcode,
        'precio': entry.price,
        'esOriginal': entry.hasOriginalCode,
        'fechaCreado': FieldValue.serverTimestamp(),
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
      
      await docRef.update({
        'nombre': entry.name,
        'precio': entry.price,
      });
      
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

  Stream<List<BarcodeEntry>> listenToCodigos() {
    return _firestore
        .collection('Codigos')
        .orderBy('fechaCreado', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BarcodeEntry(
          id: doc.id,
          name: data['nombre'] ?? '',
          barcode: data['codigo'] ?? '',
          price: data['precio'] ?? '0.00',
          createdAt: (data['fechaCreado'] as Timestamp?)?.toDate() ?? DateTime.now(),
          hasOriginalCode: data['esOriginal'] ?? false,
        );
      }).toList();
    });
  }
}
