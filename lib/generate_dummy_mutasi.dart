// ============================================================================
// GENERATE DUMMY DATA MUTASI
// ============================================================================
// Script untuk generate data dummy mutasi ke Firestore
// Jalankan dengan: flutter run lib/generate_dummy_mutasi.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GenerateDummyMutasiApp());
}

class GenerateDummyMutasiApp extends StatelessWidget {
  const GenerateDummyMutasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generate Dummy Mutasi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const GenerateDummyMutasiPage(),
    );
  }
}

class GenerateDummyMutasiPage extends StatefulWidget {
  const GenerateDummyMutasiPage({super.key});

  @override
  State<GenerateDummyMutasiPage> createState() => _GenerateDummyMutasiPageState();
}

class _GenerateDummyMutasiPageState extends State<GenerateDummyMutasiPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isGenerating = false;
  String _statusMessage = 'Siap untuk generate data dummy';
  int _totalGenerated = 0;
  int _mutasiMasukCount = 0;
  int _mutasiKeluarCount = 0;

  // Data dummy untuk randomisasi
  final List<String> _namaList = [
    'Ahmad Sudirman', 'Budi Santoso', 'Cahyo Prasetyo', 'Dedi Kurniawan',
    'Eko Wijaya', 'Fajar Ramadhan', 'Gilang Permana', 'Hendra Gunawan',
    'Irfan Hakim', 'Joko Widodo', 'Kurnia Adi', 'Lutfi Rahman',
    'Muhammad Ali', 'Nanda Pratama', 'Oscar Wijaya', 'Putra Mahendra',
    'Rizki Firmansyah', 'Sandi Surya', 'Teguh Prasetyo', 'Umar Bakri',
    'Ani Suryani', 'Budi Rahayu', 'Citra Dewi', 'Dwi Lestari',
    'Eka Putri', 'Fitri Handayani', 'Gita Permata', 'Heni Kusuma',
    'Indah Sari', 'Julianti', 'Kartika Sari', 'Lina Marlina',
    'Maya Sari', 'Novi Astuti', 'Octavia Putri', 'Putri Rahma',
    'Rina Wati', 'Siti Nurhaliza', 'Tina Wijaya', 'Uswatun Hasanah',
  ];

  final List<String> _jenisMutasiList = [
    'Mutasi Masuk',
    'Keluar Perumahan',
    'Pindah Rumah',
  ];

  final List<String> _kotaList = [
    'Jakarta', 'Bandung', 'Surabaya', 'Medan', 'Semarang', 'Makassar',
    'Palembang', 'Tangerang', 'Depok', 'Bekasi', 'Bogor', 'Yogyakarta',
    'Malang', 'Denpasar', 'Balikpapan', 'Pontianak', 'Manado', 'Batam',
  ];

  final List<String> _alamatPerumahanList = [
    'Jl. Merdeka No. 12, RT 001 RW 001',
    'Jl. Sudirman No. 25, RT 002 RW 001',
    'Jl. Thamrin No. 8, RT 003 RW 001',
    'Jl. Gatot Subroto No. 45, RT 004 RW 001',
    'Jl. Ahmad Yani No. 33, RT 005 RW 001',
    'Jl. Diponegoro No. 19, RT 001 RW 002',
    'Jl. Pahlawan No. 67, RT 002 RW 002',
    'Jl. Veteran No. 54, RT 003 RW 002',
    'Jl. Kartini No. 21, RT 004 RW 002',
    'Jl. Imam Bonjol No. 88, RT 005 RW 002',
  ];

  final List<String> _alasanMutasiMasukList = [
    'Pindah kerja ke kota ini',
    'Mengikuti pasangan yang bekerja di sini',
    'Pulang kampung setelah pensiun',
    'Membuka usaha baru',
    'Dekat dengan keluarga',
    'Mencari lingkungan yang lebih baik',
    'Anak sekolah di daerah ini',
    'Merawat orang tua',
    'Investasi properti',
    'Kualitas hidup lebih baik',
  ];

  final List<String> _alasanMutasiKeluarList = [
    'Pindah kerja ke kota lain',
    'Mengikuti pasangan yang pindah tugas',
    'Melanjutkan pendidikan di luar kota',
    'Membuka usaha di kota lain',
    'Kembali ke kampung halaman',
    'Mencari peluang kerja lebih baik',
    'Alasan keluarga',
    'Perubahan karir',
    'Biaya hidup lebih terjangkau',
    'Merawat orang tua di kampung',
  ];

  final List<String> _alasanPindahRumahList = [
    'Rumah lebih luas',
    'Dekat dengan tempat kerja',
    'Lingkungan lebih nyaman',
    'Fasilitas lebih lengkap',
    'Harga sewa lebih terjangkau',
    'Dekat dengan sekolah anak',
    'Renovasi rumah lama',
    'Upgrade ke rumah lebih besar',
    'Keamanan lebih baik',
    'Akses transportasi lebih mudah',
  ];

  // Generate NIK random (16 digit)
  String _generateNIK() {
    final random = Random();
    String nik = '35'; // Kode provinsi Jawa Timur
    for (int i = 0; i < 14; i++) {
      nik += random.nextInt(10).toString();
    }
    return nik;
  }

  // Generate tanggal random dalam 6 bulan terakhir
  DateTime _generateRandomDate() {
    final random = Random();
    final now = DateTime.now();
    final daysAgo = random.nextInt(180); // 0-180 hari yang lalu (6 bulan)
    return now.subtract(Duration(days: daysAgo));
  }

  // Generate satu data mutasi
  Future<void> _generateMutasi() async {
    final random = Random();

    // Pilih nama random
    final nama = _namaList[random.nextInt(_namaList.length)];

    // Pilih jenis mutasi random
    final jenisMutasi = _jenisMutasiList[random.nextInt(_jenisMutasiList.length)];

    // Generate NIK
    final nik = _generateNIK();

    // Generate tanggal
    final tanggalMutasi = _generateRandomDate();

    String alamatAsal;
    String alamatTujuan;
    String alasanMutasi;

    // Set alamat dan alasan berdasarkan jenis mutasi
    if (jenisMutasi == 'Mutasi Masuk') {
      // Mutasi Masuk: dari kota lain ke perumahan
      alamatAsal = _kotaList[random.nextInt(_kotaList.length)];
      alamatTujuan = _alamatPerumahanList[random.nextInt(_alamatPerumahanList.length)];
      alasanMutasi = _alasanMutasiMasukList[random.nextInt(_alasanMutasiMasukList.length)];
      _mutasiMasukCount++;
    } else if (jenisMutasi == 'Keluar Perumahan') {
      // Keluar Perumahan: dari perumahan ke kota lain
      alamatAsal = _alamatPerumahanList[random.nextInt(_alamatPerumahanList.length)];
      alamatTujuan = _kotaList[random.nextInt(_kotaList.length)];
      alasanMutasi = _alasanMutasiKeluarList[random.nextInt(_alasanMutasiKeluarList.length)];
      _mutasiKeluarCount++;
    } else {
      // Pindah Rumah: dari satu alamat perumahan ke alamat perumahan lain
      final alamatList = List<String>.from(_alamatPerumahanList);
      alamatAsal = alamatList[random.nextInt(alamatList.length)];
      alamatList.remove(alamatAsal); // Pastikan alamat tujuan berbeda
      alamatTujuan = alamatList[random.nextInt(alamatList.length)];
      alasanMutasi = _alasanPindahRumahList[random.nextInt(_alasanPindahRumahList.length)];
      _mutasiKeluarCount++; // Pindah rumah dihitung sebagai keluar dari rumah lama
    }

    try {
      await _firestore.collection('mutasi').add({
        'nama': nama,
        'nik': nik,
        'jenisMutasi': jenisMutasi,
        'tanggalMutasi': Timestamp.fromDate(tanggalMutasi),
        'alamatAsal': alamatAsal,
        'alamatTujuan': alamatTujuan,
        'alasanMutasi': alasanMutasi,
        'status': 'Selesai', // Status: Pending, Diproses, Selesai
        'createdBy': 'system',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _totalGenerated++;
        _statusMessage = 'Generated $_totalGenerated mutasi: $nama ($jenisMutasi)';
      });
    } catch (e) {
      print('❌ Error adding mutasi: $e');
    }
  }

  // Main generate function
  Future<void> _generateDummyData() async {
    setState(() {
      _isGenerating = true;
      _totalGenerated = 0;
      _mutasiMasukCount = 0;
      _mutasiKeluarCount = 0;
      _statusMessage = 'Memulai generate data...';
    });

    try {
      // Generate 30-50 data mutasi
      final random = Random();
      final jumlahData = 30 + random.nextInt(21); // 30-50 data

      setState(() {
        _statusMessage = 'Generating $jumlahData data mutasi...';
      });

      for (int i = 0; i < jumlahData; i++) {
        await _generateMutasi();

        // Delay sedikit agar tidak overload
        await Future.delayed(const Duration(milliseconds: 100));
      }

      setState(() {
        _isGenerating = false;
        _statusMessage = '✅ Berhasil generate $_totalGenerated data mutasi!\n'
            'Mutasi Masuk: $_mutasiMasukCount\n'
            'Mutasi Keluar/Pindah: $_mutasiKeluarCount';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Berhasil generate $_totalGenerated data mutasi!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _statusMessage = '❌ Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Delete all mutasi data
  Future<void> _deleteAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Konfirmasi'),
        content: const Text('Hapus semua data mutasi yang ada?\nTindakan ini tidak dapat dibatalkan!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isGenerating = true;
      _statusMessage = 'Menghapus data...';
    });

    try {
      final snapshot = await _firestore.collection('mutasi').get();
      int deleted = 0;

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        deleted++;
        setState(() {
          _statusMessage = 'Menghapus... ($deleted/${snapshot.docs.length})';
        });
      }

      setState(() {
        _isGenerating = false;
        _totalGenerated = 0;
        _mutasiMasukCount = 0;
        _mutasiKeluarCount = 0;
        _statusMessage = '✅ Berhasil menghapus $deleted data mutasi';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Berhasil menghapus $deleted data mutasi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Dummy Data Mutasi'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.swap_horiz_rounded,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              Text(
                'Generator Data Dummy Mutasi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Generate data dummy mutasi masuk, keluar, dan pindah rumah\nsecara otomatis ke Firestore',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isGenerating)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        _totalGenerated > 0 ? Icons.check_circle : Icons.info_outline,
                        color: _totalGenerated > 0 ? Colors.green : Colors.blue,
                      ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (_totalGenerated > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total: $_totalGenerated mutasi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_circle_down, color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'Masuk: $_mutasiMasukCount',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.arrow_circle_up, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'Keluar: $_mutasiKeluarCount',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateDummyData,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'Generate Data Dummy',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isGenerating ? null : _deleteAllData,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    'Hapus Semua Data',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '📋 Fitur:\n'
                '• Generate 30-50 data mutasi\n'
                '• 3 jenis: Masuk, Keluar, Pindah Rumah\n'
                '• Data realistis dengan tanggal random\n'
                '• Alamat dan alasan yang sesuai',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

