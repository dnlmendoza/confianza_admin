import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ServicioCatalogos {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> _streamConfiguracion() {
    debugPrint("DEBUG: _streamConfiguracion escuchando Catalogos/configuracion");
    return _firestore.collection('Catalogos').doc('configuracion').snapshots();
  }

  // Categóricas
  Stream<List<MapEntry<String, String>>> streamCategorias() {
    return _streamConfiguracion().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        debugPrint("DEBUG: Catalogos/configuracion NO EXISTE o data es null (categorias)");
        return <MapEntry<String, String>>[];
      }
      final data = snapshot.data()!;
      final categoriasRaw = data['categorias'] as List<dynamic>? ?? [];
      debugPrint("DEBUG: categoriasRaw length: ${categoriasRaw.length}");
      
      final result = categoriasRaw.map((item) {
        final map = item as Map<String, dynamic>? ?? {};
        final id = map['id']?.toString() ?? '';
        final nombre = map['nombre']?.toString() ?? '';
        return MapEntry(id, nombre.isEmpty ? id : nombre);
      }).toList();
      
      result.sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
      return result;
    });
  }

  // Proveedores
  Stream<List<MapEntry<String, String>>> streamProveedores() {
    return _streamConfiguracion().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        debugPrint("DEBUG: Catalogos/configuracion NO EXISTE (proveedores)");
        return <MapEntry<String, String>>[];
      }
      final data = snapshot.data()!;
      final proveedoresRaw = data['proveedores'] as List<dynamic>? ?? [];
      debugPrint("DEBUG: proveedoresRaw length: ${proveedoresRaw.length}");
      
      final result = proveedoresRaw.map((item) {
        final map = item as Map<String, dynamic>? ?? {};
        final id = map['id']?.toString() ?? '';
        final nombre = map['nombre']?.toString() ?? '';
        return MapEntry(id, nombre.isEmpty ? id : nombre);
      }).toList();
      
      result.sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
      return result;
    });
  }

  // Unidades
  Stream<List<Map<String, dynamic>>> streamUnidadesData() {
    return _streamConfiguracion().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        debugPrint("DEBUG: Catalogos/configuracion NO EXISTE (unidades)");
        return <Map<String, dynamic>>[];
      }
      final data = snapshot.data()!;
      final unidadesRaw = data['unidades'] as List<dynamic>? ?? [];
      debugPrint("DEBUG: unidadesRaw length: ${unidadesRaw.length}");
      
      final list = unidadesRaw.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final nombre = map['nombre']?.toString() ?? '';
        map['nameVal'] = nombre;
        map['id'] = map['id']?.toString() ?? '';
        return map;
      }).toList();
      
      list.sort((a, b) => (a['nameVal'] as String).toLowerCase().compareTo((b['nameVal'] as String).toLowerCase()));
      return list;
    });
  }

  // Helper para generar IDs aleatorios si no los manda el backend (simula comportamiento de .add)
  String _generateId() {
    return _firestore.collection('_dummy_').doc().id;
  }

  // Categorías
  Future<void> addCategoria(String nombre) async {
    if (nombre.trim().isEmpty) return;
    final docRef = _firestore.collection('Catalogos').doc('configuracion');
    await docRef.update({
      'categorias': FieldValue.arrayUnion([{
        'id': _generateId(),
        'nombre': nombre.trim()
      }])
    });
  }

  Future<void> deleteCategoria(String nombre) async {
    // 1. Update Inventario (solo si es necesario, pero como ahora leemos de configuracion, igual lo hacemos)
    await _updateInventoryField('categoria', nombre, 'General');
    
    // 2. Remove from Array
    final docRef = _firestore.collection('Catalogos').doc('configuracion');
    final doc = await docRef.get();
    if (!doc.exists) return;
    
    final data = doc.data()!;
    final categorias = List<dynamic>.from(data['categorias'] ?? []);
    final itemToRemove = categorias.firstWhere((c) => c['nombre'] == nombre, orElse: () => null);
    
    if (itemToRemove != null) {
      await docRef.update({
        'categorias': FieldValue.arrayRemove([itemToRemove])
      });
    }
  }

  Future<void> renameCategoria(String oldName, String newName) async {
    if (newName.trim().isEmpty || oldName == newName) return;
    
    final docRef = _firestore.collection('Catalogos').doc('configuracion');
    final doc = await docRef.get();
    if (!doc.exists) return;
    
    final data = doc.data()!;
    final categorias = List<dynamic>.from(data['categorias'] ?? []);
    
    bool updated = false;
    for (int i = 0; i < categorias.length; i++) {
      if (categorias[i]['nombre'] == oldName) {
        categorias[i]['nombre'] = newName.trim();
        updated = true;
      }
    }
    
    if (updated) {
      await docRef.update({'categorias': categorias});
      await _updateInventoryField('categoria', oldName, newName);
    }
  }

  // Proveedores
  Future<void> addProveedor(String nombre) async {
    if (nombre.trim().isEmpty) return;
    final docRef = _firestore.collection('Catalogos').doc('configuracion');
    await docRef.update({
      'proveedores': FieldValue.arrayUnion([{
        'id': _generateId(),
        'nombre': nombre.trim()
      }])
    });
  }

  Future<void> deleteProveedor(String nombre) async {
    await _updateInventoryField('proveedor', nombre, 'Bodega');
    
    final docRef = _firestore.collection('Catalogos').doc('configuracion');
    final doc = await docRef.get();
    if (!doc.exists) return;
    
    final data = doc.data()!;
    final proveedores = List<dynamic>.from(data['proveedores'] ?? []);
    final itemToRemove = proveedores.firstWhere((p) => p['nombre'] == nombre, orElse: () => null);
    
    if (itemToRemove != null) {
      await docRef.update({
        'proveedores': FieldValue.arrayRemove([itemToRemove])
      });
    }
  }

  Future<void> renameProveedor(String oldName, String newName) async {
    if (newName.trim().isEmpty || oldName == newName) return;
    
    final docRef = _firestore.collection('Catalogos').doc('configuracion');
    final doc = await docRef.get();
    if (!doc.exists) return;
    
    final data = doc.data()!;
    final proveedores = List<dynamic>.from(data['proveedores'] ?? []);
    
    bool updated = false;
    for (int i = 0; i < proveedores.length; i++) {
      if (proveedores[i]['nombre'] == oldName) {
        proveedores[i]['nombre'] = newName.trim();
        updated = true;
      }
    }
    
    if (updated) {
      await docRef.update({'proveedores': proveedores});
      await _updateInventoryField('proveedor', oldName, newName);
    }
  }

  // Unidades
  // Nota: Unidades ya no tiene 'tipo'. Ahora tiene 'abreviado'.
  Future<void> addUnidad(String nombre, String abreviado, bool menorMayor) async {
    if (nombre.trim().isEmpty) return;
    final docRef = _firestore.collection('Catalogos').doc('configuracion');
    await docRef.update({
      'unidades': FieldValue.arrayUnion([{
        'id': _generateId(),
        'nombre': nombre.trim(),
        'abreviado': abreviado.trim(),
        'menor_mayor': menorMayor,
      }])
    });
  }

  Future<void> updateUnidad(String id, String nombre, String abreviado, bool menorMayor) async {
    if (nombre.trim().isEmpty) return;
    final docRef = _firestore.collection('Catalogos').doc('configuracion');
    final doc = await docRef.get();
    if (!doc.exists) return;
    
    final data = doc.data()!;
    final unidades = List<dynamic>.from(data['unidades'] ?? []);
    
    bool updated = false;
    for (int i = 0; i < unidades.length; i++) {
      if (unidades[i]['id'] == id) {
        unidades[i]['nombre'] = nombre.trim();
        unidades[i]['abreviado'] = abreviado.trim();
        unidades[i]['menor_mayor'] = menorMayor;
        updated = true;
        break;
      }
    }
    
    if (updated) {
      await docRef.update({'unidades': unidades});
    }
  }

  Future<void> deleteUnidad(String nombre) async {
    final docRef = _firestore.collection('Catalogos').doc('configuracion');
    final doc = await docRef.get();
    if (!doc.exists) return;
    
    final data = doc.data()!;
    final unidades = List<dynamic>.from(data['unidades'] ?? []);
    final itemToRemove = unidades.firstWhere((u) => u['nombre'] == nombre, orElse: () => null);
    
    if (itemToRemove != null) {
      await docRef.update({
        'unidades': FieldValue.arrayRemove([itemToRemove])
      });
    }
  }

  Future<void> renameUnidad(String oldName, String newName) async {
    if (newName.trim().isEmpty || oldName == newName) return;
    final docRef = _firestore.collection('Catalogos').doc('configuracion');
    final doc = await docRef.get();
    if (!doc.exists) return;
    
    final data = doc.data()!;
    final unidades = List<dynamic>.from(data['unidades'] ?? []);
    
    bool updated = false;
    for (int i = 0; i < unidades.length; i++) {
      if (unidades[i]['nombre'] == oldName) {
        unidades[i]['nombre'] = newName.trim();
        updated = true;
      }
    }
    
    if (updated) {
      await docRef.update({'unidades': unidades});
    }
  }

  // Update Inventory Field
  Future<void> _updateInventoryField(String fieldName, String oldName, String newName) async {
    try {
      final snapshot = await _firestore.collection('Inventario').where(fieldName, isEqualTo: oldName).get();
      if (snapshot.docs.isEmpty) return;

      WriteBatch batch = _firestore.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {fieldName: newName});
        count++;

        if (count == 490) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint("DEBUG: Error al actualizar inventario para $fieldName: $e");
    }
  }
}
