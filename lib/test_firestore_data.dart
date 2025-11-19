import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Test script untuk check data di Firestore
/// Run dengan: flutter run lib/test_firestore_data.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  print('\n🔥 ========== FIRESTORE DATA CHECK ==========\n');
  
  final firestore = FirebaseFirestore.instance;
  
  // Check Jenis Iuran Collection
  print('📦 Checking jenis_iuran collection...');
  try {
    final jenisIuranSnapshot = await firestore
        .collection('jenis_iuran')
        .where('isActive', isEqualTo: true)
        .get();
    
    print('✅ Found ${jenisIuranSnapshot.docs.length} jenis iuran documents');
    
    if (jenisIuranSnapshot.docs.isEmpty) {
      print('⚠️  WARNING: No jenis iuran data found!');
    } else {
      for (var doc in jenisIuranSnapshot.docs) {
        final data = doc.data();
        print('   - ${doc.id}: ${data['nama']} (${data['kategori']})');
      }
    }
  } catch (e) {
    print('❌ Error getting jenis_iuran: $e');
  }
  
  print('\n');
  
  // Check Pemasukan Lain Collection
  print('📦 Checking pemasukan_lain collection...');
  try {
    final pemasukanSnapshot = await firestore
        .collection('pemasukan_lain')
        .where('isActive', isEqualTo: true)
        .get();
    
    print('✅ Found ${pemasukanSnapshot.docs.length} pemasukan_lain documents');
    
    if (pemasukanSnapshot.docs.isEmpty) {
      print('⚠️  WARNING: No pemasukan_lain data found!');
    } else {
      for (var doc in pemasukanSnapshot.docs) {
        final data = doc.data();
        print('   - ${doc.id}: ${data['name']} - Rp ${data['nominal']}');
      }
    }
  } catch (e) {
    print('❌ Error getting pemasukan_lain: $e');
  }
  
  print('\n');
  
  // Check Collections List
  print('📦 Listing all collections...');
  try {
    final collections = await firestore.collection('_test').get();
    print('Collections exist (if any were created)');
  } catch (e) {
    print('Note: Cannot list all collections in client');
  }
  
  print('\n🔥 ========================================\n');
}
