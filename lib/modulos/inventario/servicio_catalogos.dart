import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ServicioCatalogos {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Streams genéricos para no repetir código
  Stream<List<MapEntry<String, String>>> _streamColeccion(String collectionPath, {String fieldName = 'Nombre'}) {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final String? nombre = data[fieldName] as String?;
        final String nameVal = (nombre != null && nombre.isNotEmpty) ? nombre : doc.id;
        return MapEntry(doc.id, nameVal);
      }).toList()..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    }).handleError((error) {
      debugPrint("DEBUG: ERROR en stream $collectionPath: $error");
      return <MapEntry<String, String>>[];
    });
  }

  // Streams
  Stream<List<MapEntry<String, String>>> streamCategorias() => _streamColeccion('Categorias');
  Stream<List<MapEntry<String, String>>> streamProveedores() => _streamColeccion('Proveedores');
  Stream<List<MapEntry<String, String>>> streamUnidades() => _streamColeccion('Unidades', fieldName: 'Tipo');

  // Operaciones genéricas
  Future<void> _addDoc(String collectionPath, String nombre, {String fieldName = 'Nombre'}) async {
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

  Future<void> _deleteDoc(String collectionPath, String nombre, {String fieldName = 'Nombre'}) async {
    try {
      // Buscamos el documento por su campo 'Nombre' o 'Tipo'
      final snapshot = await _firestore.collection(collectionPath).where(fieldName, isEqualTo: nombre).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      // Fallback por si acaso fue creado usando el nombre como ID directamente
      final docById = await _firestore.collection(collectionPath).doc(nombre).get();
      if (docById.exists) {
        await docById.reference.delete();
      }
    } catch (e) {
      debugPrint("DEBUG: Error al eliminar de $collectionPath: $e");
      rethrow;
    }
  }

  Future<void> _renameDoc(String collectionPath, String oldName, String newName, {String fieldName = 'Nombre'}) async {
    try {
      if (newName.trim().isEmpty || oldName == newName) return;
      
      // Buscamos el documento por su antiguo valor
      final snapshot = await _firestore.collection(collectionPath).where(fieldName, isEqualTo: oldName).get();
      bool updated = false;
      
      for (var doc in snapshot.docs) {
        await doc.reference.update({fieldName: newName.trim()});
        updated = true;
      }
      
      // Fallback
      if (!updated) {
        final docById = await _firestore.collection(collectionPath).doc(oldName).get();
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
  Future<void> deleteCategoria(String nombre) => _deleteDoc('Categorias', nombre);
  Future<void> renameCategoria(String oldName, String newName) => _renameDoc('Categorias', oldName, newName);

  // Proveedores
  Future<void> addProveedor(String nombre) => _addDoc('Proveedores', nombre);
  Future<void> deleteProveedor(String nombre) => _deleteDoc('Proveedores', nombre);
  Future<void> renameProveedor(String oldName, String newName) => _renameDoc('Proveedores', oldName, newName);

  // Unidades
  Future<void> addUnidad(String nombre) => _addDoc('Unidades', nombre, fieldName: 'Tipo');
  Future<void> deleteUnidad(String nombre) => _deleteDoc('Unidades', nombre, fieldName: 'Tipo');
  Future<void> renameUnidad(String oldName, String newName) => _renameDoc('Unidades', oldName, newName, fieldName: 'Tipo');
}
