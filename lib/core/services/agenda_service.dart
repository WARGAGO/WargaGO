import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/agenda_model.dart';

class AgendaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'agenda';

  Future<String> createAgenda(AgendaModel agenda) async {
    try {
      final data = agenda.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      final docRef = await _firestore.collection(_collection).add(data);
      debugPrint('Agenda created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating agenda: $e');
      rethrow;
    }
  }

  Stream<List<AgendaModel>> getAgendaStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AgendaModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<AgendaModel>> getAgendaByTypeStream(String type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type)
        .where('isActive', isEqualTo: true)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AgendaModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<AgendaModel?> getAgendaById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return AgendaModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting agenda: $e');
      return null;
    }
  }

  Future<void> updateAgenda(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collection).doc(id).update(data);
      debugPrint('Agenda updated: $id');
    } catch (e) {
      debugPrint('Error updating agenda: $e');
      rethrow;
    }
  }

  Future<void> deleteAgenda(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Agenda deleted: $id');
    } catch (e) {
      debugPrint('Error deleting agenda: $e');
      rethrow;
    }
  }

  Future<void> hardDeleteAgenda(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      debugPrint('Agenda hard deleted: $id');
    } catch (e) {
      debugPrint('Error hard deleting agenda: $e');
      rethrow;
    }
  }

  Stream<List<AgendaModel>> getUpcomingAgendaStream() {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: 'kegiatan')
        .where('isActive', isEqualTo: true)
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('tanggal', descending: false)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AgendaModel.fromFirestore(doc))
          .toList();
    });
  }
}

