// ============================================================================
// GENERATE DUMMY DATA PENDUDUK
// ============================================================================
// Script untuk generate data dummy penduduk ke Firestore
// Jalankan dengan: flutter run lib/generate_dummy_penduduk.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GenerateDummyPendudukApp());
}

class GenerateDummyPendudukApp extends StatelessWidget {
  const GenerateDummyPendudukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generate Dummy Penduduk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const GenerateDummyPendudukPage(),
    );
  }
}

class GenerateDummyPendudukPage extends StatefulWidget {
  const GenerateDummyPendudukPage({super.key});

  @override
  State<GenerateDummyPendudukPage> createState() => _GenerateDummyPendudukPageState();
}

class _GenerateDummyPendudukPageState extends State<GenerateDummyPendudukPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isGenerating = false;
  String _statusMessage = 'Siap untuk generate data dummy';
  int _totalGenerated = 0;

  // Data dummy untuk randomisasi
  final List<String> _namaPriaList = [
    'Ahmad Sudirman', 'Budi Santoso', 'Cahyo Prasetyo', 'Dedi Kurniawan',
    'Eko Wijaya', 'Fajar Ramadhan', 'Gilang Permana', 'Hendra Gunawan',
    'Irfan Hakim', 'Joko Widodo', 'Kurnia Adi', 'Lutfi Rahman',
    'Muhammad Ali', 'Nanda Pratama', 'Oscar Wijaya', 'Putra Mahendra',
    'Rizki Firmansyah', 'Sandi Surya', 'Teguh Prasetyo', 'Umar Bakri',
  ];

  final List<String> _namaWanitaList = [
    'Ani Suryani', 'Budi Rahayu', 'Citra Dewi', 'Dwi Lestari',
    'Eka Putri', 'Fitri Handayani', 'Gita Permata', 'Heni Kusuma',
    'Indah Sari', 'Julianti', 'Kartika Sari', 'Lina Marlina',
    'Maya Sari', 'Novi Astuti', 'Octavia Putri', 'Putri Rahma',
    'Rina Wati', 'Siti Nurhaliza', 'Tina Wijaya', 'Uswatun Hasanah',
  ];

  final List<String> _namaAnakList = [
    'Andi', 'Bayu', 'Candra', 'Dika', 'Eka', 'Faiz', 'Gian', 'Haikal',
    'Ivan', 'Jihan', 'Kirana', 'Liana', 'Mawar', 'Nadia', 'Omar', 'Putri',
    'Qiana', 'Rafi', 'Salsabila', 'Tari', 'Umar', 'Vera', 'Wulan', 'Yusuf', 'Zahra',
  ];

  final List<String> _tempatLahirList = [
    'Jakarta', 'Bandung', 'Surabaya', 'Medan', 'Semarang', 'Makassar',
    'Palembang', 'Tangerang', 'Depok', 'Bekasi', 'Bogor', 'Yogyakarta',
  ];

  final List<String> _agamaList = ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'];

  final List<String> _golonganDarahList = ['A', 'B', 'AB', 'O', '-'];

  final List<String> _pendidikanList = [
    'Tidak/Belum Sekolah', 'SD', 'SMP', 'SMA/SMK', 'D3', 'S1', 'S2', 'S3',
  ];

  final List<String> _pekerjaanList = [
    'Wiraswasta', 'PNS', 'Pegawai Swasta', 'Buruh', 'Guru', 'Dokter',
    'Petani', 'Pedagang', 'Ibu Rumah Tangga', 'Belum/Tidak Bekerja',
    'Mahasiswa', 'Pelajar',
  ];

  final List<String> _statusPerkawinanList = ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'];

  final List<String> _alamatList = [
    'Jl. Merdeka', 'Jl. Sudirman', 'Jl. Thamrin', 'Jl. Gatot Subroto',
    'Jl. Ahmad Yani', 'Jl. Diponegoro', 'Jl. Pahlawan', 'Jl. Veteran',
  ];

  // Generate NIK random (16 digit)
  String _generateNIK() {
    final random = Random();
    String nik = '';
    for (int i = 0; i < 16; i++) {
      nik += random.nextInt(10).toString();
    }
    return nik;
  }

  // Generate nomor KK random (16 digit)
  String _generateNomorKK() {
    final random = Random();
    String kk = '';
    for (int i = 0; i < 16; i++) {
      kk += random.nextInt(10).toString();
    }
    return kk;
  }

  // Generate nomor telepon
  String _generatePhone() {
    final random = Random();
    String phone = '08';
    for (int i = 0; i < 10; i++) {
      phone += random.nextInt(10).toString();
    }
    return phone;
  }

  // Generate tanggal lahir random
  DateTime _generateBirthDate({int? minAge, int? maxAge}) {
    final random = Random();
    final minAgeVal = minAge ?? 1;
    final maxAgeVal = maxAge ?? 70;
    final age = minAgeVal + random.nextInt(maxAgeVal - minAgeVal);
    final now = DateTime.now();
    return DateTime(
      now.year - age,
      random.nextInt(12) + 1,
      random.nextInt(28) + 1,
    );
  }

  // Generate satu keluarga
  Future<void> _generateKeluarga(int familyIndex, String rt, String rw) async {
    final random = Random();
    final nomorKK = _generateNomorKK();

    // Pilih alamat
    final alamat = '${_alamatList[random.nextInt(_alamatList.length)]} No. ${familyIndex + random.nextInt(100)}';

    // Generate kepala keluarga (suami)
    final namaKepala = _namaPriaList[random.nextInt(_namaPriaList.length)];
    final keluargaName = namaKepala.split(' ').last;

    await _addWarga(
      nik: _generateNIK(),
      nomorKK: nomorKK,
      name: namaKepala,
      tempatLahir: _tempatLahirList[random.nextInt(_tempatLahirList.length)],
      birthDate: _generateBirthDate(minAge: 30, maxAge: 60),
      jenisKelamin: 'Laki-laki',
      agama: _agamaList[random.nextInt(_agamaList.length)],
      golonganDarah: _golonganDarahList[random.nextInt(_golonganDarahList.length)],
      pendidikan: _pendidikanList[random.nextInt(_pendidikanList.length - 3) + 3], // SMA ke atas
      pekerjaan: _pekerjaanList[random.nextInt(_pekerjaanList.length - 2)], // Bukan pelajar/mahasiswa
      statusPerkawinan: 'Kawin',
      peranKeluarga: 'Kepala Keluarga',
      namaKeluarga: keluargaName,
      rt: rt,
      rw: rw,
      alamat: alamat,
    );

    // Generate istri (60% kemungkinan)
    if (random.nextDouble() > 0.4) {
      final namaIstri = _namaWanitaList[random.nextInt(_namaWanitaList.length)];
      await _addWarga(
        nik: _generateNIK(),
        nomorKK: nomorKK,
        name: namaIstri,
        tempatLahir: _tempatLahirList[random.nextInt(_tempatLahirList.length)],
        birthDate: _generateBirthDate(minAge: 25, maxAge: 55),
        jenisKelamin: 'Perempuan',
        agama: _agamaList[random.nextInt(_agamaList.length)],
        golonganDarah: _golonganDarahList[random.nextInt(_golonganDarahList.length)],
        pendidikan: _pendidikanList[random.nextInt(_pendidikanList.length - 2) + 2],
        pekerjaan: random.nextBool() ? 'Ibu Rumah Tangga' : _pekerjaanList[random.nextInt(_pekerjaanList.length - 2)],
        statusPerkawinan: 'Kawin',
        peranKeluarga: 'Istri',
        namaKeluarga: keluargaName,
        rt: rt,
        rw: rw,
        alamat: alamat,
        namaAyah: '-',
        namaIbu: '-',
      );
    }

    // Generate anak (0-4 anak)
    final jumlahAnak = random.nextInt(5);
    for (int i = 0; i < jumlahAnak; i++) {
      final isLakiLaki = random.nextBool();
      final namaAnak = '${_namaAnakList[random.nextInt(_namaAnakList.length)]} $keluargaName';
      final umur = random.nextInt(20) + 1;

      await _addWarga(
        nik: _generateNIK(),
        nomorKK: nomorKK,
        name: namaAnak,
        tempatLahir: _tempatLahirList[random.nextInt(_tempatLahirList.length)],
        birthDate: _generateBirthDate(minAge: 1, maxAge: 25),
        jenisKelamin: isLakiLaki ? 'Laki-laki' : 'Perempuan',
        agama: _agamaList[random.nextInt(_agamaList.length)],
        golonganDarah: _golonganDarahList[random.nextInt(_golonganDarahList.length)],
        pendidikan: umur < 6 ? 'Tidak/Belum Sekolah' :
                   umur < 12 ? 'SD' :
                   umur < 15 ? 'SMP' :
                   umur < 18 ? 'SMA/SMK' :
                   _pendidikanList[random.nextInt(_pendidikanList.length)],
        pekerjaan: umur < 6 ? 'Belum/Tidak Bekerja' :
                  umur < 18 ? 'Pelajar' :
                  umur < 23 ? 'Mahasiswa' :
                  _pekerjaanList[random.nextInt(_pekerjaanList.length)],
        statusPerkawinan: umur < 17 ? 'Belum Kawin' : _statusPerkawinanList[random.nextInt(_statusPerkawinanList.length)],
        peranKeluarga: 'Anak',
        namaKeluarga: keluargaName,
        rt: rt,
        rw: rw,
        alamat: alamat,
        namaAyah: namaKepala,
        namaIbu: '-',
      );
    }
  }

  // Add warga ke Firestore
  Future<void> _addWarga({
    required String nik,
    required String nomorKK,
    required String name,
    required String tempatLahir,
    required DateTime birthDate,
    required String jenisKelamin,
    required String agama,
    required String golonganDarah,
    required String pendidikan,
    required String pekerjaan,
    required String statusPerkawinan,
    required String peranKeluarga,
    required String namaKeluarga,
    required String rt,
    required String rw,
    required String alamat,
    String namaAyah = '-',
    String namaIbu = '-',
  }) async {
    try {
      await _firestore.collection('warga').add({
        'nik': nik,
        'nomorKK': nomorKK,
        'name': name,
        'tempatLahir': tempatLahir,
        'birthDate': Timestamp.fromDate(birthDate),
        'jenisKelamin': jenisKelamin,
        'agama': agama,
        'golonganDarah': golonganDarah,
        'pendidikan': pendidikan,
        'pekerjaan': pekerjaan,
        'statusPerkawinan': statusPerkawinan,
        'statusPenduduk': 'Aktif',
        'statusHidup': 'Hidup',
        'peranKeluarga': peranKeluarga,
        'namaIbu': namaIbu,
        'namaAyah': namaAyah,
        'rt': rt,
        'rw': rw,
        'alamat': alamat,
        'phone': _generatePhone(),
        'kewarganegaraan': 'Indonesia',
        'namaKeluarga': namaKeluarga,
        'photoUrl': '',
        'createdBy': 'system',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _totalGenerated++;
        _statusMessage = 'Generated $_totalGenerated warga: $name';
      });
    } catch (e) {
      print('❌ Error adding warga: $e');
    }
  }

  // Main generate function
  Future<void> _generateDummyData() async {
    setState(() {
      _isGenerating = true;
      _totalGenerated = 0;
      _statusMessage = 'Memulai generate data...';
    });

    try {
      // Generate untuk beberapa RT/RW
      final rts = ['001', '002', '003', '004', '005'];
      final rws = ['001', '002', '003'];

      int familyCounter = 1;

      for (String rw in rws) {
        for (String rt in rts) {
          // Generate 5-8 keluarga per RT
          final jumlahKeluarga = 5 + Random().nextInt(4);

          setState(() {
            _statusMessage = 'Generate data untuk RT $rt RW $rw...';
          });

          for (int i = 0; i < jumlahKeluarga; i++) {
            await _generateKeluarga(familyCounter++, rt, rw);

            // Delay sedikit agar tidak overload
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }

      setState(() {
        _isGenerating = false;
        _statusMessage = '✅ Berhasil generate $_totalGenerated data warga!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Berhasil generate $_totalGenerated data warga!'),
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

  // Delete all warga data
  Future<void> _deleteAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Konfirmasi'),
        content: const Text('Hapus semua data warga yang ada?\nTindakan ini tidak dapat dibatalkan!'),
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
      final snapshot = await _firestore.collection('warga').get();
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
        _statusMessage = '✅ Berhasil menghapus $deleted data warga';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Berhasil menghapus $deleted data warga'),
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
        title: const Text('Generate Dummy Data Penduduk'),
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
                Icons.people_alt_rounded,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              Text(
                'Generator Data Dummy Penduduk',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Generate data dummy warga dengan berbagai variasi\nkeluarga, RT, dan RW secara otomatis',
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (_totalGenerated > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total: $_totalGenerated warga',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              const SizedBox(height: 48),
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
                '• Generate keluarga lengkap (Kepala, Istri, Anak)\n'
                '• Data tersebar di beberapa RT/RW\n'
                '• Variasi umur, pekerjaan, pendidikan\n'
                '• NIK dan Nomor KK unik',
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

