import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wargago/core/providers/instance_provider.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/warga_provider.dart';
import 'core/providers/rumah_provider.dart';
import 'core/providers/keluarga_provider.dart';
import 'core/providers/jenis_iuran_provider.dart';
import 'core/providers/iuran_warga_provider.dart'; // ⭐ Iuran Warga Provider
import 'core/providers/agenda_provider.dart';
import 'core/providers/pemasukan_lain_provider.dart';
import 'core/providers/pengeluaran_provider.dart';
import 'core/providers/laporan_keuangan_detail_provider.dart';
import 'core/providers/marketplace_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/order_provider.dart';
import 'create_admin.dart'; // ✨ TEMPORARY - Untuk membuat admin2

/// Request storage permissions for export features
Future<void> _requestStoragePermissions() async {
  try {
    print('\n📁 Requesting storage permissions...');

    // Request basic storage permission
    final status = await Permission.storage.request();

    if (status.isGranted) {
      print('✅ Storage permission granted');
    } else if (status.isDenied) {
      print('⚠️  Storage permission denied - Export features may be limited');
      print('   Files will be saved to app directory only');
    } else if (status.isPermanentlyDenied) {
      print('❌ Storage permission permanently denied');
      print('   User needs to enable it manually in Settings');
    }
  } catch (e) {
    print('⚠️  Error requesting storage permission: $e');
    print('   App will continue with limited storage access');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Firestore for real-time updates
  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true, // Keep offline support
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  if (kDebugMode) {
    print('✅ Firestore configured for real-time updates');

    // ⭐ AZURE SAS TOKEN CLEANUP - Uncomment to run ONCE
    // Cleans SAS token parameters from all product image URLs in Firestore
    // Run this ONCE after setting Azure container to PUBLIC
    //
    // await CleanAzureSasTokens.checkStatus();
    // await CleanAzureSasTokens.cleanAllProducts();
    // await CleanAzureSasTokens.cleanProductsCollection();
    //
    // After running successfully, COMMENT these lines again!
  }

  // Load .env only if file exists (for local development/testing)
  // In production APK, .env doesn't exist (for security reasons)
  try {
    await dotenv.load(fileName: ".env");
    print('✅ .env file loaded (development mode)');
  } catch (e) {
    print('ℹ️  .env file not found (production mode) - This is normal');
  }

  // ============================================================================
  // CONNECTION TEST DISABLED
  // Reason: Causes permission-denied error in production
  // Only enable for debugging if needed
  // ============================================================================
  /*
  print('\n🔥 ========== FIRESTORE CONNECTION TEST ==========');
  try {
    final firestore = FirebaseFirestore.instance;

    print('🔵 Testing write to Firestore...');
    final testDoc = await firestore.collection('_connection_test').add({
      'test': true,
      'timestamp': FieldValue.serverTimestamp(),
      'from': 'main.dart startup',
    });
    print('✅ CONNECTION TEST SUCCESS! Doc ID: ${testDoc.id}');

    print('🔵 Testing write to tagihan collection...');
    final tagihanDoc = await firestore.collection('tagihan').add({
      'kodeTagihan': 'TEST_MAIN_${DateTime.now().millisecondsSinceEpoch}',
      'jenisIuranId': 'test',
      'jenisIuranName': 'Test dari Main',
      'keluargaId': 'test_001',
      'keluargaName': 'Test Keluarga Main',
      'nominal': 99999,
      'periode': 'Test Main Startup',
      'periodeTanggal': Timestamp.now(),
      'status': 'Belum Dibayar',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('✅ TAGIHAN TEST SUCCESS! Doc ID: ${tagihanDoc.id}');
    print('🔥 ========== ALL TESTS PASSED! ==========\n');
  } catch (e, stackTrace) {
    print('❌ ========== CONNECTION TEST FAILED! ==========');
    print('❌ Error: $e');
    print('❌ StackTrace: $stackTrace');
    print('❌ ==========================================\n');
  }
  */

  print('✅ Firebase initialized successfully');

  // ============================================================================
  // 📁 REQUEST STORAGE PERMISSIONS
  // Untuk fitur export PDF/Excel/CSV di halaman Keuangan
  // ============================================================================
  await _requestStoragePermissions();

  // ============================================================================
  // ✨ TEMPORARY: CREATE ADMIN2@JAWARA.COM
  // ============================================================================
  // Uncomment kode di bawah ini untuk membuat admin2@jawara.com
  // Setelah admin berhasil dibuat, COMMENT KEMBALI kode ini
  // ============================================================================

  try {
    print('\n🔧 Checking/Creating admin2@jawara.com...');
    await createAdmin2();
  } catch (e) {
    print('⚠️  Error creating admin2: $e');
    print('   (Abaikan jika admin sudah ada)');
  }

  // ============================================================================

  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);

  final instanceProvider = await InstanceProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => instanceProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WargaProvider()),
        ChangeNotifierProvider(create: (_) => RumahProvider()),
        ChangeNotifierProvider(create: (_) => KeluargaProvider()),
        ChangeNotifierProvider(create: (_) => JenisIuranProvider()),
        ChangeNotifierProvider(create: (_) => IuranWargaProvider()), // ⭐ Iuran Warga Provider
        ChangeNotifierProvider(create: (_) => AgendaProvider()),
        ChangeNotifierProvider(create: (_) => PemasukanLainProvider()),
        ChangeNotifierProvider(create: (_) => PengeluaranProvider()),
        ChangeNotifierProvider(create: (_) => LaporanKeuanganDetailProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()), // 🛒 Cart Provider
        ChangeNotifierProvider(create: (_) => OrderProvider()), // 📦 Order Provider
      ],
      child: const JawaraApp(),
    ),
  );
}
