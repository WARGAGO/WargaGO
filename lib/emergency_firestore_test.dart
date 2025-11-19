import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// EMERGENCY FIX - Direct Firestore Write Test
/// Gunakan function ini untuk test langsung tanpa UI
Future<void> emergencyFirestoreTest() async {
  print('\n🚨 ===== EMERGENCY FIRESTORE TEST =====');
  print('Testing direct write to Firestore...\n');

  try {
    final firestore = FirebaseFirestore.instance;

    // Test 1: Connection test
    print('🔵 Test 1: Testing Firestore connection...');
    try {
      await firestore.collection('_test').doc('connection').set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Connection OK!\n');
    } catch (e) {
      print('❌ Connection FAILED: $e\n');
      return;
    }

    // Test 2: Write to tagihan collection
    print('🔵 Test 2: Writing to tagihan collection...');
    final tagihanData = {
      'kodeTagihan': 'TGH_TEST_${DateTime.now().millisecondsSinceEpoch}',
      'jenisIuranId': 'emergency_test',
      'jenisIuranName': 'Emergency Test Iuran',
      'keluargaId': 'emergency_kel',
      'keluargaName': 'Emergency Test Family',
      'nominal': 99999,
      'periode': 'Emergency Test ${DateTime.now()}',
      'periodeTanggal': Timestamp.now(),
      'status': 'Belum Dibayar',
      'createdBy': 'emergency_test',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await firestore.collection('tagihan').add(tagihanData);
    print('✅ SUCCESS! Document created!');
    print('📋 Document ID: ${docRef.id}');
    print('📋 Path: tagihan/${docRef.id}\n');

    // Test 3: Verify document exists
    print('🔵 Test 3: Verifying document...');
    final doc = await docRef.get();
    if (doc.exists) {
      print('✅ VERIFIED! Document exists in Firestore');
      print('📊 Data: ${doc.data()}\n');
    } else {
      print('❌ ERROR: Document not found!\n');
      return;
    }

    // Test 4: Read from tagihan collection
    print('🔵 Test 4: Reading tagihan collection...');
    final snapshot = await firestore.collection('tagihan').limit(5).get();
    print('✅ Found ${snapshot.docs.length} documents');
    for (var doc in snapshot.docs) {
      print('   - ${doc.id}: ${doc.data()['kodeTagihan']}');
    }
    print('');

    print('🎉 ===== ALL TESTS PASSED! =====');
    print('✅ Firestore connection: OK');
    print('✅ Write permission: OK');
    print('✅ Read permission: OK');
    print('✅ Data format: OK');
    print('\n💡 CONCLUSION: Firebase is working correctly!');
    print('   If your app still not saving, problem is in app code layer.\n');

  } catch (e, stackTrace) {
    print('❌ ===== TEST FAILED =====');
    print('Error: $e');
    print('StackTrace: $stackTrace');
    print('\n💡 CONCLUSION: Firebase connection or rules issue!');
    print('   Check:');
    print('   1. Internet connection');
    print('   2. Firebase project ID');
    print('   3. Firestore rules deployed');
    print('');
  }
}

/// Simple test - just write one document
Future<String?> quickFirestoreTest() async {
  try {
    final docRef = await FirebaseFirestore.instance.collection('tagihan').add({
      'kodeTagihan': 'QUICK_TEST_${DateTime.now().millisecondsSinceEpoch}',
      'jenisIuranId': 'test',
      'jenisIuranName': 'Quick Test',
      'keluargaId': 'test',
      'keluargaName': 'Test',
      'nominal': 10000,
      'periode': 'Test',
      'periodeTanggal': Timestamp.now(),
      'status': 'Belum Dibayar',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Quick test SUCCESS! Doc ID: ${docRef.id}');
    return docRef.id;
  } catch (e) {
    debugPrint('❌ Quick test FAILED: $e');
    return null;
  }
}

