import 'package:cloud_firestore/cloud_firestore.dart';
import 'modelos_inventario.dart';

class ServicioInventario {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ArticuloInventario>> streamArticulos() {
    return _firestore.collection('Inventario').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
        return ArticuloInventario.fromMap(doc.id, data);
      }).toList();
    });
  }

  Future<List<LoteArticulo>> getLotesPorArticulo(String articuloId) async {
    try {
      final lotesSnapshot = await _firestore
          .collection('Inventario')
          .doc(articuloId)
          .collection('lote')
          .get();
      return lotesSnapshot.docs.map((loteDoc) {
        final Map<String, dynamic> loteData = Map<String, dynamic>.from(
          loteDoc.data(),
        );
        loteData['id'] = loteDoc.id;
        return LoteArticulo.fromMap(loteData);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<LoteArticulo>> streamLotesPorArticulo(String articuloId) {
    return _firestore
        .collection('Inventario')
        .doc(articuloId)
        .collection('lote')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((loteDoc) {
            final Map<String, dynamic> loteData = Map<String, dynamic>.from(
              loteDoc.data(),
            );
            loteData['id'] = loteDoc.id;
            return LoteArticulo.fromMap(loteData);
          }).toList();
        });
  }

  Future<void> updateLote(
    String articuloId,
    String loteId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('Inventario')
          .doc(articuloId)
          .collection('lote')
          .doc(loteId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      // Manejo de errores básico
    }
  }

  Future<void> updateArticulo(
    String articuloId,
    Map<String, dynamic> data,
  ) async {
    try {

      await _firestore.collection('Inventario').doc(articuloId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createArticulo(
    String articuloId,
    Map<String, dynamic> data,
    Map<String, dynamic> loteData,
  ) async {
    try {
      // El articuloId ES el código de barras
      if (articuloId.isNotEmpty) {
        final existingDoc = await _firestore.collection('Inventario').doc(articuloId).get();
        if (existingDoc.exists) {
          throw Exception(
            'El código de barras ya está registrado en otro artículo.',
          );
        }
      }

      final batch = _firestore.batch();

      final articuloRef = _firestore.collection('Inventario').doc(articuloId);
      batch.set(articuloRef, data);

      final newLoteId = _firestore
          .collection('Inventario')
          .doc(articuloId)
          .collection('lote')
          .doc()
          .id;
      final loteRef = _firestore
          .collection('Inventario')
          .doc(articuloId)
          .collection('lote')
          .doc(newLoteId);
      batch.set(loteRef, loteData);

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
