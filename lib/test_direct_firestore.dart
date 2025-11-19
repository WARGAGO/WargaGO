import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Direct Firestore Test - Bypass service layer
/// Run this from main or debug console
class DirectFirestoreTest extends StatelessWidget {
  const DirectFirestoreTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Direct Firestore Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _testDirectWrite(),
          child: const Text('TEST DIRECT WRITE TO FIRESTORE'),
        ),
      ),
    );
  }

  Future<void> _testDirectWrite() async {
    print('\n🔥 ===== DIRECT FIRESTORE TEST =====');

    try {
      final firestore = FirebaseFirestore.instance;

      // Test data - VERY SIMPLE
      final testData = {
        'kodeTagihan': 'TGH24110001',
        'jenisIuranId': 'test_iuran',
        'jenisIuranName': 'Test Iuran',
        'keluargaId': 'test_kel_001',
        'keluargaName': 'Test Keluarga',
        'nominal': 50000,
        'periode': 'November 2025',
        'periodeTanggal': Timestamp.fromDate(DateTime(2025, 11, 30)),
        'status': 'Belum Dibayar',
        'createdBy': 'test@test.com',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('📤 Attempting to write to Firestore...');
      print('📊 Data: $testData');

      // DIRECT WRITE - NO SERVICE, NO PROVIDER
      final docRef = await firestore.collection('tagihan').add(testData);

      print('✅ SUCCESS! Document ID: ${docRef.id}');
      print('✅ Document written to: tagihan/${docRef.id}');

      // Verify
      final doc = await docRef.get();
      if (doc.exists) {
        print('✅ VERIFIED! Document exists in Firestore');
        print('📊 Stored data: ${doc.data()}');
      }

      print('🔥 ===== TEST COMPLETED SUCCESSFULLY =====\n');

    } catch (e, stackTrace) {
      print('❌ ===== ERROR =====');
      print('❌ Error: $e');
      print('❌ StackTrace: $stackTrace');
      print('❌ ===== TEST FAILED =====\n');
    }
  }
}

/// Quick function to run from anywhere
Future<void> testFirestoreDirectWrite() async {
  print('\n🔥 ===== DIRECT FIRESTORE TEST =====');

  try {
    final firestore = FirebaseFirestore.instance;

    final testData = {
      'kodeTagihan': 'TGH24110001',
      'jenisIuranId': 'test_iuran',
      'jenisIuranName': 'Test Iuran',
      'keluargaId': 'test_kel_001',
      'keluargaName': 'Test Keluarga',
      'nominal': 50000,
      'periode': 'November 2025',
      'periodeTanggal': Timestamp.fromDate(DateTime(2025, 11, 30)),
      'status': 'Belum Dibayar',
      'createdBy': 'test@test.com',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    print('📤 Writing to Firestore...');
    final docRef = await firestore.collection('tagihan').add(testData);
    print('✅ SUCCESS! Document ID: ${docRef.id}');
    print('🔥 ===== TEST COMPLETED =====\n');

    return;
  } catch (e) {
    print('❌ ERROR: $e');
    rethrow;
  }
}

