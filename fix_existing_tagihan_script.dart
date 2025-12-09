import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// Script untuk fix tagihan yang sudah ada di database
/// Menambahkan field yang missing
Future<void> fixExistingTagihan() async {
  print('\n' + '=' * 70);
  print('🔧 FIXING EXISTING TAGIHAN');
  print('=' * 70);

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('❌ No user logged in');
    return;
  }

  // Get all tagihan
  final allTagihan = await FirebaseFirestore.instance
      .collection('tagihan')
      .get();

  print('📊 Found ${allTagihan.docs.length} tagihan to check');

  int fixed = 0;
  int skipped = 0;
  int errors = 0;

  for (var tagihanDoc in allTagihan.docs) {
    try {
      final data = tagihanDoc.data();
      final tagihanId = tagihanDoc.id;

      // Check if needs fixing
      final needsFix = data['status'] == 'belum_bayar' ||
                       data['kodeTagihan'] == null ||
                       data['jenisIuranId'] == null ||
                       data['periode'] == null ||
                       data['periodeTanggal'] == null ||
                       data['createdBy'] == null ||
                       data['keluargaName'] == null;

      if (!needsFix) {
        skipped++;
        continue;
      }

      print('\n🔧 Fixing tagihan: ${data['jenisIuranName']}');

      // Prepare updates
      final Map<String, dynamic> updates = {};

      // Fix status
      if (data['status'] == 'belum_bayar') {
        updates['status'] = 'Belum Dibayar';
        print('   ✅ Status: "belum_bayar" → "Belum Dibayar"');
      } else if (data['status'] == 'sudah_bayar') {
        updates['status'] = 'Lunas';
        print('   ✅ Status: "sudah_bayar" → "Lunas"');
      } else if (data['status'] == 'terlambat') {
        updates['status'] = 'Terlambat';
        print('   ✅ Status: "terlambat" → "Terlambat"');
      }

      // Generate kodeTagihan if missing
      if (data['kodeTagihan'] == null) {
        final now = DateTime.now();
        final kode = 'TGH-${now.year}${now.month.toString().padLeft(2, '0')}-${fixed.toString().padLeft(3, '0')}';
        updates['kodeTagihan'] = kode;
        print('   ✅ Generated kodeTagihan: $kode');
      }

      // Get jenisIuranId from iuranId if exists
      if (data['jenisIuranId'] == null && data['iuranId'] != null) {
        updates['jenisIuranId'] = data['iuranId'];
        print('   ✅ Set jenisIuranId from iuranId');
      }

      // Get keluargaName
      if (data['keluargaName'] == null && data['keluargaId'] != null) {
        try {
          final keluargaDoc = await FirebaseFirestore.instance
              .collection('keluarga')
              .doc(data['keluargaId'])
              .get();

          if (keluargaDoc.exists) {
            final keluargaName = keluargaDoc.data()?['namaKepalaKeluarga'] ?? 'Keluarga';
            updates['keluargaName'] = keluargaName;
            print('   ✅ Set keluargaName: $keluargaName');
          } else {
            // Get from user name
            if (data['userId'] != null) {
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['userId'])
                  .get();
              final userName = userDoc.data()?['nama'] ?? 'Unknown';
              updates['keluargaName'] = 'Keluarga $userName';
              print('   ✅ Set keluargaName from user: Keluarga $userName');
            } else {
              updates['keluargaName'] = 'Keluarga';
              print('   ⚠️ Set default keluargaName');
            }
          }
        } catch (e) {
          updates['keluargaName'] = 'Keluarga';
          print('   ⚠️ Error getting keluarga, using default');
        }
      }

      // Set periode if missing
      if (data['periode'] == null) {
        final now = DateTime.now();
        final periode = DateFormat('MMMM yyyy', 'id_ID').format(now);
        updates['periode'] = periode;
        print('   ✅ Set periode: $periode');
      }

      // Set periodeTanggal if missing
      if (data['periodeTanggal'] == null) {
        final now = DateTime.now();
        final lastDay = DateTime(now.year, now.month + 1, 0);
        updates['periodeTanggal'] = Timestamp.fromDate(lastDay);
        print('   ✅ Set periodeTanggal: ${lastDay.toString()}');
      }

      // Set createdBy if missing
      if (data['createdBy'] == null) {
        updates['createdBy'] = currentUser.uid;
        print('   ✅ Set createdBy: ${currentUser.uid}');
      }

      // Set updatedAt
      updates['updatedAt'] = FieldValue.serverTimestamp();

      // Apply updates
      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('tagihan')
            .doc(tagihanId)
            .update(updates);

        fixed++;
        print('   ✅ FIXED!');
      }

    } catch (e) {
      print('   ❌ Error: $e');
      errors++;
    }
  }

  print('\n' + '=' * 70);
  print('📊 SUMMARY:');
  print('   ✅ Fixed: $fixed');
  print('   ⏭️  Skipped (already OK): $skipped');
  print('   ❌ Errors: $errors');
  print('=' * 70);

  if (fixed > 0) {
    print('\n🎉 SUCCESS! $fixed tagihan have been fixed!');
    print('   Warga should now see their tagihan.');
  } else {
    print('\n✅ All tagihan are already correct.');
  }

  print('\n');
}

