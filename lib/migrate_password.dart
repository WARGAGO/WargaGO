import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// ============================================================================
// PASSWORD MIGRATION SCRIPT
// ============================================================================
// Script untuk migrate password yang plain text menjadi hashed
// Jalankan sekali saja untuk update existing users
// ============================================================================

class PasswordMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Hash password menggunakan SHA-256 (sama dengan AuthService)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Check apakah password sudah di-hash (panjang SHA-256 = 64 karakter)
  bool _isPasswordHashed(String password) {
    // SHA-256 hash selalu 64 karakter hexadecimal
    return password.length == 64 && RegExp(r'^[a-f0-9]+$').hasMatch(password);
  }

  /// Migrate semua password plain text ke hashed
  Future<void> migrateAllPasswords() async {
    print('🔧 Memulai migrasi password...\n');

    try {
      // Get all users
      final querySnapshot = await _firestore.collection('users').get();

      if (querySnapshot.docs.isEmpty) {
        print('⚠️  Tidak ada user ditemukan.');
        return;
      }

      print('📊 Total users: ${querySnapshot.docs.length}\n');

      int migrated = 0;
      int skipped = 0;
      int errors = 0;

      for (var doc in querySnapshot.docs) {
        try {
          final userData = doc.data();
          final userId = doc.id;
          final email = userData['email'] ?? 'unknown';
          final currentPassword = userData['password'] ?? '';

          // Skip jika password kosong
          if (currentPassword.isEmpty) {
            print('⏭️  ${email}: Password kosong, skip.');
            skipped++;
            continue;
          }

          // Skip jika sudah di-hash
          if (_isPasswordHashed(currentPassword)) {
            print('✅ ${email}: Password sudah di-hash, skip.');
            skipped++;
            continue;
          }

          // Hash password plain text
          final hashedPassword = _hashPassword(currentPassword);

          // Update di Firestore
          await _firestore.collection('users').doc(userId).update({
            'password': hashedPassword,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          print('🔐 ${email}: Migrated');
          print('   Plain: ${currentPassword}');
          print('   Hash:  ${hashedPassword}\n');
          migrated++;

        } catch (e) {
          print('❌ Error migrating user ${doc.id}: $e\n');
          errors++;
        }
      }

      // Summary
      print('\n' + '=' * 50);
      print('✨ MIGRASI SELESAI!');
      print('=' * 50);
      print('📊 Total users:     ${querySnapshot.docs.length}');
      print('🔐 Migrated:        $migrated');
      print('⏭️  Skipped:         $skipped');
      print('❌ Errors:          $errors');
      print('=' * 50);

      if (migrated > 0) {
        print('\n⚠️  PENTING: Password telah di-hash!');
        print('   Gunakan password ASLI untuk login.');
        print('   Contoh: admin123 (bukan hash-nya)');
      }

    } catch (e) {
      print('❌ Error saat migrasi: $e');
    }
  }

  /// Migrate password untuk user tertentu (by email)
  Future<void> migratePasswordByEmail(String email) async {
    print('🔧 Migrasi password untuk: $email\n');

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ User dengan email $email tidak ditemukan.');
        return;
      }

      final doc = querySnapshot.docs.first;
      final userData = doc.data();
      final currentPassword = userData['password'] ?? '';

      if (currentPassword.isEmpty) {
        print('❌ Password kosong, tidak bisa migrasi.');
        return;
      }

      if (_isPasswordHashed(currentPassword)) {
        print('✅ Password sudah di-hash:');
        print('   $currentPassword');
        return;
      }

      // Hash password
      final hashedPassword = _hashPassword(currentPassword);

      // Update
      await _firestore.collection('users').doc(doc.id).update({
        'password': hashedPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Password berhasil di-hash!');
      print('   Plain: $currentPassword');
      print('   Hash:  $hashedPassword');

    } catch (e) {
      print('❌ Error: $e');
    }
  }

  /// Reset password admin menjadi default (untuk testing)
  Future<void> resetAdminPassword({
    String email = 'admin@jawara.com',
    String newPassword = 'admin123',
  }) async {
    print('🔧 Reset password admin...\n');

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ Admin tidak ditemukan.');
        return;
      }

      final doc = querySnapshot.docs.first;
      final hashedPassword = _hashPassword(newPassword);

      await _firestore.collection('users').doc(doc.id).update({
        'password': hashedPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Password admin berhasil di-reset!');
      print('   Email:    $email');
      print('   Password: $newPassword');
      print('   Hash:     $hashedPassword');

    } catch (e) {
      print('❌ Error: $e');
    }
  }
}

// ============================================================================
// CARA PENGGUNAAN
// ============================================================================
//
// 1. Import di main.dart atau file lain:
//    import 'migrate_password.dart';
//
// 2. Jalankan migrasi semua user:
//    final migrationService = PasswordMigrationService();
//    await migrationService.migrateAllPasswords();
//
// 3. Atau migrate user tertentu:
//    await migrationService.migratePasswordByEmail('admin@jawara.com');
//
// 4. Atau reset password admin:
//    await migrationService.resetAdminPassword();
//
// ============================================================================

