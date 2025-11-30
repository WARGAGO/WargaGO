import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// ============================================================================
// ADMIN SETUP SERVICE
// ============================================================================
// Service untuk inisialisasi admin pertama kali
// Gunakan hanya untuk development/setup awal
// ============================================================================

/// Konstanta untuk admin default
class AdminConstants {
  static const String defaultEmail = 'admin@jawara.com';
  static const String defaultPassword = 'admin123';
  static const String defaultName = 'Admin WargaGo';
  static const String defaultNik = '1234567890123456';
  static const String defaultPhone = '081234567890';
  static const String defaultAddress = 'Jl. Contoh No. 123';

  // Collection name
  static const String usersCollection = 'users';

  // Role & Status
  static const String adminRole = 'admin';
  static const String approvedStatus = 'approved';
}

/// Model data untuk admin user
class AdminUserData {
  final String email;
  final String password;
  final String nama;
  final String nik;
  final String jenisKelamin;
  final String noTelepon;
  final String alamat;
  final String role;
  final String status;

  AdminUserData({
    required this.email,
    required this.password,
    required this.nama,
    required this.nik,
    required this.jenisKelamin,
    required this.noTelepon,
    required this.alamat,
    this.role = AdminConstants.adminRole,
    this.status = AdminConstants.approvedStatus,
  });

  /// Convert ke Map untuk Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'email': email,
      'password': password,
      'nama': nama,
      'nik': nik,
      'jenisKelamin': jenisKelamin,
      'noTelepon': noTelepon,
      'alamat': alamat,
      'role': role,
      'status': status,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': null,
    };
  }
}

/// Service untuk manage admin users
class AdminSetupService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AdminSetupService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Hash password menggunakan SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Cek apakah user dengan email tertentu sudah ada di Firebase Auth
  Future<bool> _isUserExistsInAuth(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('❌ Error checking user in Firebase Auth: $e');
      return false;
    }
  }

  /// Cek apakah user dengan email tertentu sudah ada di Firestore
  Future<bool> _isUserExistsInFirestore(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(AdminConstants.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking user in Firestore: $e');
      return false;
    }
  }

  /// Buat admin user baru di Firebase Auth DAN Firestore
  /// Document ID di Firestore akan sama dengan Firebase Auth UID
  Future<bool> createAdminWithAuth(AdminUserData adminData) async {
    try {
      print('🔧 Membuat admin: ${adminData.email}');

      // 1. Cek apakah sudah ada di Firebase Auth
      final existsInAuth = await _isUserExistsInAuth(adminData.email);
      if (existsInAuth) {
        print('⚠️  User sudah ada di Firebase Auth');
        return false;
      }

      // 2. Cek apakah sudah ada di Firestore
      final existsInFirestore = await _isUserExistsInFirestore(adminData.email);
      if (existsInFirestore) {
        print('⚠️  User sudah ada di Firestore');
        return false;
      }

      print('📝 Creating user in Firebase Auth...');

      // 3. Buat user di Firebase Auth terlebih dahulu
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: adminData.email,
        password: adminData.password,
      );

      if (userCredential.user == null) {
        print('❌ Gagal membuat user di Firebase Auth');
        return false;
      }

      final firebaseUid = userCredential.user!.uid;
      print('✅ User created in Firebase Auth!');
      print('   Firebase UID: $firebaseUid');

      // 4. Hash password untuk disimpan di Firestore
      final hashedPassword = _hashPassword(adminData.password);

      // 5. Siapkan data untuk Firestore
      final adminDataMap = adminData.toFirestoreMap();
      adminDataMap['password'] = hashedPassword;

      print('📝 Creating user in Firestore...');

      // 6. Simpan ke Firestore menggunakan Firebase UID sebagai document ID
      await _firestore
          .collection(AdminConstants.usersCollection)
          .doc(firebaseUid)  // ✨ Gunakan Firebase UID sebagai document ID
          .set(adminDataMap);

      print('✅ User created in Firestore!');
      print('   Document ID: $firebaseUid');
      print('');
      print('🎉 Admin berhasil dibuat!');
      print('📧 Email: ${adminData.email}');
      print('🔑 Password: ${adminData.password}');
      print('🆔 Firebase UID: $firebaseUid');
      print('✨ Status: ${adminData.status}');
      print('👤 Nama: ${adminData.nama}');
      print('');

      return true;
    } catch (e) {
      print('❌ Error creating admin: $e');
      return false;
    }
  }

  /// [DEPRECATED] Method lama - hanya membuat di Firestore
  Future<bool> _createAdmin(AdminUserData adminData) async {
    try {
      // Hash password sebelum disimpan
      final hashedPassword = _hashPassword(adminData.password);

      // Create admin data dengan password yang sudah di-hash
      final adminDataMap = adminData.toFirestoreMap();
      adminDataMap['password'] = hashedPassword;

      await _firestore
          .collection(AdminConstants.usersCollection)
          .add(adminDataMap);

      return true;
    } catch (e) {
      print('❌ Error creating admin: $e');
      return false;
    }
  }

  /// Buat admin default (admin@jawara.com)
  Future<void> createDefaultAdmin() async {
    print('🔧 Membuat admin default...');

    final defaultAdmin = AdminUserData(
      email: AdminConstants.defaultEmail,
      password: AdminConstants.defaultPassword,
      nama: AdminConstants.defaultName,
      nik: AdminConstants.defaultNik,
      jenisKelamin: 'Laki-laki',
      noTelepon: AdminConstants.defaultPhone,
      alamat: AdminConstants.defaultAddress,
    );

    // Gunakan method baru yang membuat di Firebase Auth + Firestore
    await createAdminWithAuth(defaultAdmin);
  }

  /// Buat multiple admin sekaligus
  Future<void> createMultipleAdmins(List<AdminUserData> admins) async {
    print('🔧 Membuat ${admins.length} admin...\n');

    int created = 0;
    int skipped = 0;

    for (var adminData in admins) {
      // Gunakan method baru
      final success = await createAdminWithAuth(adminData);
      if (success) {
        created++;
      } else {
        skipped++;
      }
    }

    print('\n📊 Summary:');
    print('   ✅ Created: $created');
    print('   ⏭️  Skipped: $skipped');
  }
}

// ============================================================================
// HELPER FUNCTIONS (untuk backward compatibility)
// ============================================================================

/// Helper untuk membuat admin default
/// [DEPRECATED] Gunakan AdminSetupService.createDefaultAdmin() sebagai gantinya
Future<void> createAdminUser() async {
  final service = AdminSetupService();
  await service.createDefaultAdmin();
}

/// Helper untuk membuat demo admins
/// [DEPRECATED] Gunakan AdminSetupService.createMultipleAdmins() sebagai gantinya
Future<void> createDemoAdmins() async {
  final demoAdmins = [
    AdminUserData(
      email: 'admin1@jawara.com',
      password: 'admin123',
      nama: 'Admin 1',
      nik: '1234567890123457',
      jenisKelamin: 'Laki-laki',
      noTelepon: '081234567891',
      alamat: 'Jl. Demo No. 1',
    ),
    AdminUserData(
      email: 'admin2@jawara.com',
      password: 'admin123',
      nama: 'Admin 2',
      nik: '1234567890123458',
      jenisKelamin: 'Perempuan',
      noTelepon: '081234567892',
      alamat: 'Jl. Demo No. 2',
    ),
  ];
  
  final service = AdminSetupService();
  await service.createMultipleAdmins(demoAdmins);
}

/// Helper untuk membuat admin2@jawara.com
Future<void> createAdmin2() async {
  print('========================================');
  print('🔧 MEMBUAT ADMIN2@JAWARA.COM');
  print('========================================\n');

  final service = AdminSetupService();

  final admin2 = AdminUserData(
    email: 'admin2@jawara.com',
    password: 'admin123',
    nama: 'Admin 2 Jawara',
    nik: '3201234567890123',
    jenisKelamin: 'Laki-laki',
    noTelepon: '081234567899',
    alamat: 'Jl. Admin 2 No. 123',
  );

  final success = await service.createAdminWithAuth(admin2);

  if (success) {
    print('\n========================================');
    print('✅ ADMIN2 BERHASIL DIBUAT!');
    print('========================================');
    print('📧 Email:    admin2@jawara.com');
    print('🔑 Password: admin123');
    print('========================================\n');
  } else {
    print('\n========================================');
    print('⚠️  ADMIN2 SUDAH ADA');
    print('========================================');
    print('Gunakan kredensial berikut untuk login:');
    print('📧 Email:    admin2@jawara.com');
    print('🔑 Password: admin123');
    print('========================================\n');
  }
}

