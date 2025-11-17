// ============================================================================
// CLEAN DASH VALUES FROM FIRESTORE
// ============================================================================
// Script untuk membersihkan nilai '-' dari database Firestore
// Jalankan sekali saja untuk clean up data yang ada
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Clean dash values dari collection warga
Future<void> cleanDashValuesFromWarga() async {
  print('🚀 Starting clean up dash values...');

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firestore = FirebaseFirestore.instance;

    // Get all warga documents
    final wargas = await firestore.collection('warga').get();

    int updatedCount = 0;
    int skippedCount = 0;

    print('📊 Found ${wargas.docs.length} warga documents');

    for (var doc in wargas.docs) {
      final data = doc.data();
      final updates = <String, dynamic>{};

      // List of fields to check for dash values
      final fieldsToCheck = [
        'jenisKelamin',
        'agama',
        'golonganDarah',
        'pendidikan',
        'pekerjaan',
        'statusPerkawinan',
        'peranKeluarga',
        'namaIbu',
        'namaAyah',
        'tempatLahir',
        'rt',
        'rw',
        'alamat',
        'phone',
        'namaKeluarga',
        'nomorKK',
        'kewarganegaraan',
      ];

      // Check each field
      for (var field in fieldsToCheck) {
        final value = data[field];

        // Replace '-' with empty string
        if (value == '-' || value == '--' || value == '---') {
          updates[field] = '';
          print('  🔧 ${doc.id}: $field = "$value" → ""');
        }
      }

      // Update document if needed
      if (updates.isNotEmpty) {
        await doc.reference.update(updates);
        updatedCount++;
        print('  ✅ Updated ${doc.id} (${updates.length} fields)');
      } else {
        skippedCount++;
      }
    }

    print('\n✅ Clean up completed!');
    print('📈 Statistics:');
    print('   - Total documents: ${wargas.docs.length}');
    print('   - Updated: $updatedCount');
    print('   - Skipped (no changes): $skippedCount');

  } catch (e) {
    print('❌ Error during clean up: $e');
    rethrow;
  }
}

/// Clean dash values dari collection keluarga (jika ada)
Future<void> cleanDashValuesFromKeluarga() async {
  print('\n🚀 Starting clean up dash values from keluarga...');

  try {
    final firestore = FirebaseFirestore.instance;

    // Get all keluarga documents
    final keluargas = await firestore.collection('keluarga').get();

    if (keluargas.docs.isEmpty) {
      print('ℹ️  No keluarga collection found or empty');
      return;
    }

    int updatedCount = 0;
    int skippedCount = 0;

    print('📊 Found ${keluargas.docs.length} keluarga documents');

    for (var doc in keluargas.docs) {
      final data = doc.data();
      final updates = <String, dynamic>{};

      // List of fields to check
      final fieldsToCheck = [
        'namaKeluarga',
        'kepalaKeluarga',
        'rumahSaatIni',
        'statusKepemilikan',
        'statusKeluarga',
      ];

      // Check each field
      for (var field in fieldsToCheck) {
        final value = data[field];

        if (value == '-' || value == '--' || value == '---') {
          updates[field] = '';
          print('  🔧 ${doc.id}: $field = "$value" → ""');
        }
      }

      // Update document if needed
      if (updates.isNotEmpty) {
        await doc.reference.update(updates);
        updatedCount++;
        print('  ✅ Updated ${doc.id} (${updates.length} fields)');
      } else {
        skippedCount++;
      }
    }

    print('\n✅ Clean up keluarga completed!');
    print('📈 Statistics:');
    print('   - Total documents: ${keluargas.docs.length}');
    print('   - Updated: $updatedCount');
    print('   - Skipped: $skippedCount');

  } catch (e) {
    print('❌ Error during keluarga clean up: $e');
  }
}

/// Main function
void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║         CLEAN DASH VALUES FROM FIRESTORE                   ║');
  print('║         Script untuk membersihkan nilai \'-\' dari DB        ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  try {
    // Clean warga collection
    await cleanDashValuesFromWarga();

    // Clean keluarga collection (optional)
    await cleanDashValuesFromKeluarga();

    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║                    ✅ ALL DONE!                            ║');
    print('╚════════════════════════════════════════════════════════════╝');

  } catch (e) {
    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║                    ❌ FAILED!                              ║');
    print('╚════════════════════════════════════════════════════════════╝');
    print('Error: $e');
  }
}

