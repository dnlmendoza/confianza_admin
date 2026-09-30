import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ServicioCatalogos {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Streams genéricos para no repetir código
  Stream<List<MapEntry<String, String>>> _streamColeccion(
    String collectionPath, {
    String fieldName = 'Nombre',
  }) {
    return _firestore
        .collection(collectionPath)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final String? nombre = data[fieldName] as String?;
            final String nameVal = (nombre != null && nombre.isNotEmpty)
                ? nombre
                : doc.id;
            return MapEntry(doc.id, nameVal);
          }).toList()..sort(
            (a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()),
          );
        })
        .handleError((error) {
          debugPrint("DEBUG: ERROR en stream $collectionPath: $error");
          return <MapEntry<String, String>>[];
        });
  }

  // Streams
  Stream<List<MapEntry<String, String>>> streamCategorias() =>
      _streamColeccion('Categorias');
  Stream<List<MapEntry<String, String>>> streamProveedores() =>
      _streamColeccion('Proveedores');

  // Devuelve la data completa para poder filtrar por el booleano 'mayor'
  Stream<List<Map<String, dynamic>>> streamUnidadesData() {
    return _firestore
        .collection('Unidades')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            final String? nombre = data['nombre'] as String?;
            data['nameVal'] = (nombre != null && nombre.isNotEmpty)
                ? nombre
                : doc.id;
            return data;
          }).toList();
          list.sort(
            (a, b) => (a['nameVal'] as String).toLowerCase().compareTo(
              (b['nameVal'] as String).toLowerCase(),
            ),
          );
          return list;
        })
        .handleError((error) {
          debugPrint("DEBUG: ERROR en stream Unidades: $error");
          return <Map<String, dynamic>>[];
        });
  }

  // Operaciones genéricas
  Future<void> _addDoc(
    String collectionPath,
    String nombre, {
    String fieldName = 'Nombre',
  }) async {
    try {
      if (nombre.trim().isEmpty) return;
      // Usamos .add() para generar un ID aleatorio y guardamos el nombre en el documento
      await _firestore.collection(collectionPath).add({
        fieldName: nombre.trim(),
        'fecha_creacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("DEBUG: Error al agregar a $collectionPath: $e");
      rethrow;
    }
  }

  Future<void> _deleteDoc(
    String collectionPath,
    String nombre, {
    String fieldName = 'Nombre',
  }) async {
    try {
      // Buscamos el documento por su campo 'Nombre' o 'Tipo'
      final snapshot = await _firestore
          .collection(collectionPath)
          .where(fieldName, isEqualTo: nombre)
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Fallback por si acaso fue creado usando el nombre como ID directamente
      final docById = await _firestore
          .collection(collectionPath)
          .doc(nombre)
          .get();
      if (docById.exists) {
        await docById.reference.delete();
      }
    } catch (e) {
      debugPrint("DEBUG: Error al eliminar de $collectionPath: $e");
      rethrow;
    }
  }

  Future<void> _renameDoc(
    String collectionPath,
    String oldName,
    String newName, {
    String fieldName = 'Nombre',
  }) async {
    try {
      if (newName.trim().isEmpty || oldName == newName) return;

      // Buscamos el documento por su antiguo valor
      final snapshot = await _firestore
          .collection(collectionPath)
          .where(fieldName, isEqualTo: oldName)
          .get();
      bool updated = false;

      for (var doc in snapshot.docs) {
        await doc.reference.update({fieldName: newName.trim()});
        updated = true;
      }

      // Fallback
      if (!updated) {
        final docById = await _firestore
            .collection(collectionPath)
            .doc(oldName)
            .get();
        if (docById.exists) {
          // Si el ID era el nombre, creamos uno nuevo con ID aleatorio para migrarlo
          await _firestore.collection(collectionPath).add({
            fieldName: newName.trim(),
            'fecha_creacion': FieldValue.serverTimestamp(),
          });
          await docById.reference.delete();
        }
      }
    } catch (e) {
      debugPrint("DEBUG: Error al renombrar en $collectionPath: $e");
      rethrow;
    }
  }

  // Categorías
  Future<void> addCategoria(String nombre) => _addDoc('Categorias', nombre);
  Future<void> deleteCategoria(String nombre) async {
    await _updateInventoryField('categoria', nombre, 'General');
    await _deleteDoc('Categorias', nombre);
  }

  Future<void> renameCategoria(String oldName, String newName) async {
    await _renameDoc('Categorias', oldName, newName);
    await _updateInventoryField('categoria', oldName, newName);
  }

  // Proveedores
  Future<void> addProveedor(String nombre) => _addDoc('Proveedores', nombre);
  Future<void> deleteProveedor(String nombre) async {
    await _updateInventoryField('proveedor', nombre, 'Bodega');
    await _deleteDoc('Proveedores', nombre);
  }

  Future<void> renameProveedor(String oldName, String newName) async {
    await _renameDoc('Proveedores', oldName, newName);
    await _updateInventoryField('proveedor', oldName, newName);
  }

  Future<void> _updateInventoryField(
    String fieldName,
    String oldName,
    String newName,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('Inventario')
          .where(fieldName, isEqualTo: oldName)
          .get();
      if (snapshot.docs.isEmpty) return;

      WriteBatch batch = _firestore.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final updates = <String, dynamic>{fieldName: newName};

        // Update inside 'productos' array as well
        if (data.containsKey('productos') && data['productos'] is List) {
          final productos = List<Map<String, dynamic>>.from(data['productos']);
          bool changed = false;
          for (var p in productos) {
            if (p[fieldName] == oldName) {
              p[fieldName] = newName;
              changed = true;
            }
          }
          if (changed) {
            updates['productos'] = productos;
          }
        }

        batch.update(doc.reference, updates);
        count++;

        // Firebase limits batch to 500
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

  // Unidades
  Future<void> addUnidad(String nombre, String tipo, bool menorMayor) async {
    try {
      if (nombre.trim().isEmpty) return;
      await _firestore.collection('Unidades').add({
        'nombre': nombre.trim(),
        'tipo': tipo.trim(),
        'mayor': menorMayor,
        'fecha_creacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("DEBUG: Error al agregar a Unidades: $e");
      rethrow;
    }
  }

  Future<void> updateUnidad(
    String id,
    String nombre,
    String tipo,
    bool menorMayor,
  ) async {
    try {
      if (nombre.trim().isEmpty) return;
      await _firestore.collection('Unidades').doc(id).update({
        'nombre': nombre.trim(),
        'tipo': tipo.trim(),
        'mayor': menorMayor,
      });
    } catch (e) {
      debugPrint("DEBUG: Error al actualizar Unidad: $e");
      rethrow;
    }
  }

  Future<void> deleteUnidad(String nombre) =>
      _deleteDoc('Unidades', nombre, fieldName: 'nombre');
  // Se mantiene renameUnidad por si acaso hay referencias, pero updateUnidad es la preferida ahora
  Future<void> renameUnidad(String oldName, String newName) =>
      _renameDoc('Unidades', oldName, newName, fieldName: 'nombre');
}
