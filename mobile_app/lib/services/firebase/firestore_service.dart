import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generic method to add document
  Future<String?> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      var docRef = await _db.collection(collection).add(data);
      print('✅ Added document to $collection');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding document: $e');
      rethrow;
    }
  }

  // Generic method to update document
  Future<bool> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collection).doc(docId).update(data);
      print('✅ Updated document $docId in $collection');
      return true;
    } catch (e) {
      print('❌ Error updating document: $e');
      rethrow;
    }
  }

  // Generic method to delete document
  Future<bool> deleteDocument(String collection, String docId) async {
    try {
      await _db.collection(collection).doc(docId).delete();
      print('✅ Deleted document $docId from $collection');
      return true;
    } catch (e) {
      print('❌ Error deleting document: $e');
      rethrow;
    }
  }

  // Generic method to get document
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    try {
      var doc = await _db.collection(collection).doc(docId).get();
      return doc.data();
    } catch (e) {
      print('❌ Error getting document: $e');
      rethrow;
    }
  }

  // Generic method to get collection
  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      var snapshot = await _db.collection(collection).get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('❌ Error getting collection: $e');
      rethrow;
    }
  }

  // Query collection with where clause
  Future<List<Map<String, dynamic>>> queryCollection(
    String collection,
    String field,
    dynamic value,
  ) async {
    try {
      var snapshot = await _db
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('❌ Error querying collection: $e');
      rethrow;
    }
  }

  // Stream of collection changes
  Stream<List<Map<String, dynamic>>> streamCollection(String collection) {
    return _db.collection(collection).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList(),
        );
  }

  // Stream of document changes
  Stream<Map<String, dynamic>?> streamDocument(
    String collection,
    String docId,
  ) {
    return _db.collection(collection).doc(docId).snapshots().map(
          (doc) => doc.exists ? {'id': doc.id, ...doc.data()!} : null,
        );
  }
}








