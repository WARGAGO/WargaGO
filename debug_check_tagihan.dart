import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Script untuk debug - Check tagihan di Firestore
Future<void> debugCheckTagihan() async {
  print('\n' + '=' * 70);
  print('🔍 DEBUG: Checking Tagihan in Firestore');
  print('=' * 70);

  // Get current user
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('❌ No user logged in');
    return;
  }

  print('✅ Current user: ${currentUser.email}');

  // Get user's keluargaId
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();

  final userData = userDoc.data();
  final keluargaId = userData?['keluargaId'] as String?;

  print('✅ User keluargaId: $keluargaId');

  if (keluargaId == null) {
    print('❌ User has no keluargaId!');
    return;
  }

  // Query ALL tagihan
  print('\n1️⃣ Querying ALL tagihan...');
  final allTagihan = await FirebaseFirestore.instance
      .collection('tagihan')
      .get();

  print('📊 Total tagihan in database: ${allTagihan.docs.length}');

  // Query tagihan by keluargaId
  print('\n2️⃣ Querying tagihan by keluargaId...');
  final tagihanByKeluarga = await FirebaseFirestore.instance
      .collection('tagihan')
      .where('keluargaId', isEqualTo: keluargaId)
      .get();

  print('📊 Tagihan for keluargaId "$keluargaId": ${tagihanByKeluarga.docs.length}');

  if (tagihanByKeluarga.docs.isEmpty) {
    print('❌ NO TAGIHAN FOUND for this keluargaId!');
    print('\nPossible issues:');
    print('1. Admin belum generate tagihan');
    print('2. keluargaId tidak match');
    print('3. Data corrupt');

    // Show all keluargaIds in tagihan
    print('\n3️⃣ All keluargaIds in tagihan collection:');
    final allKeluargaIds = <String>{};
    for (var doc in allTagihan.docs) {
      final data = doc.data();
      final kid = data['keluargaId'];
      if (kid != null) allKeluargaIds.add(kid.toString());
    }
    print('Unique keluargaIds: $allKeluargaIds');

    return;
  }

  // Print details of each tagihan
  print('\n4️⃣ Tagihan details:');
  for (var i = 0; i < tagihanByKeluarga.docs.length; i++) {
    final doc = tagihanByKeluarga.docs[i];
    final data = doc.data();

    print('\n📄 Tagihan ${i + 1}:');
    print('   ID: ${doc.id}');
    print('   kodeTagihan: ${data['kodeTagihan']}');
    print('   jenisIuranId: ${data['jenisIuranId']}');
    print('   jenisIuranName: ${data['jenisIuranName']}');
    print('   keluargaId: ${data['keluargaId']}');
    print('   keluargaName: ${data['keluargaName']}');
    print('   nominal: ${data['nominal']}');
    print('   periode: ${data['periode']}');
    print('   periodeTanggal: ${data['periodeTanggal']}');
    print('   status: "${data['status']}" (type: ${data['status']?.runtimeType})');
    print('   isActive: ${data['isActive']}');
    print('   createdBy: ${data['createdBy']}');
    print('   createdAt: ${data['createdAt']}');

    // Check if all required fields exist
    final requiredFields = [
      'kodeTagihan',
      'jenisIuranId',
      'jenisIuranName',
      'keluargaId',
      'keluargaName',
      'nominal',
      'periode',
      'periodeTanggal',
      'status',
      'isActive',
      'createdBy'
    ];

    final missingFields = <String>[];
    for (var field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        missingFields.add(field);
      }
    }

    if (missingFields.isNotEmpty) {
      print('   ❌ MISSING FIELDS: ${missingFields.join(', ')}');
    } else {
      print('   ✅ All required fields present');
    }
  }

  print('\n' + '=' * 70);
  print('✅ Debug check complete');
  print('=' * 70 + '\n');
}

