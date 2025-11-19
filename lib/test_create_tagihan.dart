import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/models/tagihan_model.dart';
import 'core/services/tagihan_service.dart';

/// Test script untuk debug create tagihan
/// Jalankan dari debug console atau terminal
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  testCreateTagihan();
}

Future<void> testCreateTagihan() async {
  print('🔵 ========== TEST CREATE TAGIHAN ==========');

  try {
    // Test Firebase connection
    print('🔵 Step 1: Testing Firebase connection...');
    final firestore = FirebaseFirestore.instance;

    // Try to get collection
    final testSnapshot = await firestore.collection('tagihan').limit(1).get();
    print('✅ Firebase connected! Collection exists: ${testSnapshot.docs.isNotEmpty}');

    // Test create tagihan
    print('🔵 Step 2: Creating test tagihan...');
    final service = TagihanService();

    final testTagihan = TagihanModel(
      id: '',
      kodeTagihan: '', // Will be auto-generated
      jenisIuranId: 'test_jiuran_001',
      jenisIuranName: 'Test Iuran Bulanan',
      keluargaId: 'test_kel_001',
      keluargaName: 'Test Keluarga Budi',
      nominal: 50000,
      periode: 'November 2025',
      periodeTanggal: DateTime(2025, 11, 30),
      status: 'Belum Dibayar',
      createdBy: 'test@example.com',
      isActive: true,
    );

    print('🔵 Step 3: Converting to Map...');
    final dataMap = testTagihan.toMap();
    print('📊 Data Map: $dataMap');

    print('🔵 Step 4: Calling service.createTagihan()...');
    final docId = await service.createTagihan(testTagihan);
    print('✅ SUCCESS! Document created with ID: $docId');

    // Verify data
    print('🔵 Step 5: Verifying data in Firestore...');
    final doc = await firestore.collection('tagihan').doc(docId).get();
    if (doc.exists) {
      print('✅ Data verified!');
      print('📊 Stored data: ${doc.data()}');
    } else {
      print('❌ Document not found!');
    }

    print('🔵 ========== TEST COMPLETED ==========');

  } catch (e, stackTrace) {
    print('❌ ========== ERROR ==========');
    print('Error: $e');
    print('StackTrace: $stackTrace');
  }
}

