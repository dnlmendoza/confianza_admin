import 'package:cloud_firestore/cloud_firestore.dart';
import 'modelos_inventario.dart';

class ServicioInventario {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PedidoInventario>> streamPedidos() {
    return _firestore.collection('Inventario').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
        return PedidoInventario.fromMap(doc.id, data);
      }).toList();
    });
  }

  Future<List<LotePedido>> getLotesPorPedido(String pedidoId) async {
    try {
      final lotesSnapshot = await _firestore.collection('Inventario').doc(pedidoId).collection('lote').get();
      return lotesSnapshot.docs.map((loteDoc) {
        final Map<String, dynamic> loteData = Map<String, dynamic>.from(loteDoc.data());
        loteData['id'] = loteDoc.id;
        return LotePedido.fromMap(loteData);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateLote(String pedidoId, String loteId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('Inventario')
          .doc(pedidoId)
          .collection('lote')
          .doc(loteId)
          .update(data);
    } catch (e) {
      // Manejo de errores básico
    }
  }
}
