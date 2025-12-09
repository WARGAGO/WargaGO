import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/providers/iuran_warga_provider.dart';
import '../widgets/iuran_header_card.dart';
import '../widgets/iuran_menu_grid.dart';
import '../widgets/iuran_list_section.dart';

// Import debug script
Future<void> debugCheckTagihan() async {
  print('\n' + '=' * 70);
  print('🔍 DEBUG: Checking Tagihan in Firestore');
  print('=' * 70);

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('❌ No user logged in');
    return;
  }

  print('✅ Current user: ${currentUser.email}');

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

  // Query tagihan by keluargaId
  print('\n📊 Querying tagihan by keluargaId...');
  final tagihanByKeluarga = await FirebaseFirestore.instance
      .collection('tagihan')
      .where('keluargaId', isEqualTo: keluargaId)
      .get();

  print('Found: ${tagihanByKeluarga.docs.length} tagihan');

  if (tagihanByKeluarga.docs.isEmpty) {
    print('❌ NO TAGIHAN FOUND!');

    // Check all tagihan
    final allTagihan = await FirebaseFirestore.instance
        .collection('tagihan')
        .get();
    print('\nTotal tagihan in DB: ${allTagihan.docs.length}');

    if (allTagihan.docs.isNotEmpty) {
      print('Example keluargaId in DB: ${allTagihan.docs.first.data()['keluargaId']}');
    }
    return;
  }

  // Print details
  for (var i = 0; i < tagihanByKeluarga.docs.length; i++) {
    final doc = tagihanByKeluarga.docs[i];
    final data = doc.data();

    print('\n📄 Tagihan ${i + 1}:');
    print('   jenisIuranName: ${data['jenisIuranName']}');
    print('   nominal: ${data['nominal']}');
    print('   status: "${data['status']}"');
    print('   periode: ${data['periode']}');
    print('   isActive: ${data['isActive']}');

    // Check required fields
    final required = ['kodeTagihan', 'jenisIuranId', 'keluargaName', 'periodeTanggal', 'createdBy'];
    final missing = required.where((f) => !data.containsKey(f) || data[f] == null).toList();

    if (missing.isNotEmpty) {
      print('   ❌ MISSING: ${missing.join(', ')}');
    } else {
      print('   ✅ All fields OK');
    }
  }

  print('\n' + '=' * 70);
}

// Fix existing tagihan script
Future<void> fixExistingTagihan() async {
  print('\n' + '=' * 70);
  print('🔧 FIXING EXISTING TAGIHAN');
  print('=' * 70);

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('❌ No user logged in');
    return;
  }

  final allTagihan = await FirebaseFirestore.instance
      .collection('tagihan')
      .get();

  print('📊 Found ${allTagihan.docs.length} tagihan to check');

  int fixed = 0;
  int skipped = 0;

  for (var tagihanDoc in allTagihan.docs) {
    try {
      final data = tagihanDoc.data();

      final needsFix = data['status'] == 'belum_bayar' ||
                       data['kodeTagihan'] == null ||
                       data['jenisIuranId'] == null ||
                       data['periode'] == null;

      if (!needsFix) {
        skipped++;
        continue;
      }

      print('\n🔧 Fixing: ${data['jenisIuranName']}');

      final Map<String, dynamic> updates = {};

      // Fix status
      if (data['status'] == 'belum_bayar') {
        updates['status'] = 'Belum Dibayar';
      } else if (data['status'] == 'sudah_bayar') {
        updates['status'] = 'Lunas';
      } else if (data['status'] == 'terlambat') {
        updates['status'] = 'Terlambat';
      }

      // Generate kodeTagihan
      if (data['kodeTagihan'] == null) {
        final now = DateTime.now();
        updates['kodeTagihan'] = 'TGH-${now.year}${now.month.toString().padLeft(2, '0')}-${fixed.toString().padLeft(3, '0')}';
      }

      // Set jenisIuranId
      if (data['jenisIuranId'] == null && data['iuranId'] != null) {
        updates['jenisIuranId'] = data['iuranId'];
      }

      // Set keluargaName
      if (data['keluargaName'] == null) {
        updates['keluargaName'] = 'Keluarga';
      }

      // Set periode
      if (data['periode'] == null) {
        final now = DateTime.now();
        final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                       'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
        updates['periode'] = '${months[now.month - 1]} ${now.year}';
      }

      // Set periodeTanggal
      if (data['periodeTanggal'] == null) {
        final now = DateTime.now();
        final lastDay = DateTime(now.year, now.month + 1, 0);
        updates['periodeTanggal'] = Timestamp.fromDate(lastDay);
      }

      // Set createdBy
      if (data['createdBy'] == null) {
        updates['createdBy'] = currentUser.uid;
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('tagihan')
            .doc(tagihanDoc.id)
            .update(updates);

        fixed++;
        print('   ✅ FIXED!');
      }

    } catch (e) {
      print('   ❌ Error: $e');
    }
  }

  print('\n📊 Fixed: $fixed, Skipped: $skipped');
  print('=' * 70 + '\n');
}

class IuranWargaPage extends StatefulWidget {
  const IuranWargaPage({super.key});

  @override
  State<IuranWargaPage> createState() => _IuranWargaPageState();
}

class _IuranWargaPageState extends State<IuranWargaPage> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    if (_isInitialized) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'Anda belum login';
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _errorMessage = 'Data user tidak ditemukan';
        });
        return;
      }

      final userData = userDoc.data();
      final keluargaId = userData?['keluargaId'] as String?;

      if (keluargaId == null || keluargaId.isEmpty) {
        setState(() {
          _errorMessage = 'Anda belum memiliki Keluarga ID.\nSilakan hubungi admin.';
        });
        return;
      }

      if (mounted) {
        final provider = context.read<IuranWargaProvider>();
        await provider.initialize(keluargaId);

        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Iuran Warga',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        actions: [
          // FIX button - untuk fix tagihan yang ada
          IconButton(
            icon: const Icon(Icons.build, color: Colors.green),
            tooltip: 'Fix Tagihan',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fixing tagihan... Check console')),
              );
              await fixExistingTagihan();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Done! Refresh page to see changes'),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh provider
              if (context.mounted) {
                await context.read<IuranWargaProvider>().refresh();
              }
            },
          ),
          // Debug button
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.red),
            onPressed: () async {
              await debugCheckTagihan();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Check console log for debug info')),
              );
            },
          ),
        ],
      ),
      body: Consumer<IuranWargaProvider>(
        builder: (context, provider, child) {
          // Loading
          if (provider.isLoading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (_errorMessage != null || provider.errorMessage != null) {
            return _buildErrorScreen(_errorMessage ?? provider.errorMessage!);
          }

          // Empty
          if (provider.totalTagihan == 0 && _isInitialized) {
            return _buildEmptyScreen();
          }

          // Main Content
          return RefreshIndicator(
            onRefresh: () async {
              await provider.refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  IuranHeaderCard(provider: provider),
                  const SizedBox(height: 20),
                  IuranMenuGrid(provider: provider),
                  const SizedBox(height: 24),
                  IuranListSection(provider: provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isInitialized = false;
                  _errorMessage = null;
                });
                _initializeProvider();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: Colors.blue.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Tagihan',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Saat ini Anda belum memiliki tagihan iuran',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _isInitialized = false);
                _initializeProvider();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

