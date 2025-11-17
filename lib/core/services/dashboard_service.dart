import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

/// Dashboard Service
/// Service untuk fetch data statistik dashboard dari Firestore
class DashboardService {
  final FirebaseService _firebaseService = FirebaseService();

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  // ============================================================================
  // KEUANGAN (FINANCE) DATA
  // ============================================================================

  /// Get total kas masuk (pemasukan)
  Future<double> getTotalKasMasuk() async {
    try {
      final querySnapshot = await _firestore
          .collection('keuangan')
          .where('type', isEqualTo: 'pemasukan')
          .get();

      double total = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final amount = data['amount'] ?? 0;
        total += (amount is int) ? amount.toDouble() : amount;
      }

      return total;
    } catch (e) {
      print('Error getTotalKasMasuk: $e');
      return 0;
    }
  }

  /// Get total kas keluar (pengeluaran)
  Future<double> getTotalKasKeluar() async {
    try {
      final querySnapshot = await _firestore
          .collection('keuangan')
          .where('type', isEqualTo: 'pengeluaran')
          .get();

      double total = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final amount = data['amount'] ?? 0;
        total += (amount is int) ? amount.toDouble() : amount;
      }

      return total;
    } catch (e) {
      print('Error getTotalKasKeluar: $e');
      return 0;
    }
  }

  /// Get total semua transaksi
  Future<int> getTotalTransaksi() async {
    try {
      final querySnapshot = await _firestore
          .collection('keuangan')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getTotalTransaksi: $e');
      return 0;
    }
  }

  /// Get saldo akhir (kas masuk - kas keluar)
  Future<double> getSaldoAkhir() async {
    try {
      final kasMasuk = await getTotalKasMasuk();
      final kasKeluar = await getTotalKasKeluar();
      return kasMasuk - kasKeluar;
    } catch (e) {
      print('Error getSaldoAkhir: $e');
      return 0;
    }
  }

  // ============================================================================
  // KEGIATAN (AGENDA) DATA
  // ============================================================================

  /// Get total kegiatan
  Future<int> getTotalKegiatan() async {
    try {
      final querySnapshot = await _firestore
          .collection('agenda')
          .where('type', isEqualTo: 'kegiatan')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getTotalKegiatan: $e');
      return 0;
    }
  }

  /// Get kegiatan berdasarkan status waktu
  Future<Map<String, int>> getKegiatanByTimeline() async {
    try {
      final querySnapshot = await _firestore
          .collection('agenda')
          .where('type', isEqualTo: 'kegiatan')
          .get();

      int sudahLewat = 0;
      int hariIni = 0;
      int akanDatang = 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['tanggal'] != null) {
          final tanggal = (data['tanggal'] as Timestamp).toDate();
          final kegiatanDate = DateTime(tanggal.year, tanggal.month, tanggal.day);

          if (kegiatanDate.isBefore(today)) {
            sudahLewat++;
          } else if (kegiatanDate.isAtSameMomentAs(today)) {
            hariIni++;
          } else {
            akanDatang++;
          }
        }
      }

      return {
        'sudah_lewat': sudahLewat,
        'hari_ini': hariIni,
        'akan_datang': akanDatang,
      };
    } catch (e) {
      print('Error getKegiatanByTimeline: $e');
      return {
        'sudah_lewat': 0,
        'hari_ini': 0,
        'akan_datang': 0,
      };
    }
  }

  /// Get top penanggung jawab (by jumlah kegiatan)
  Future<Map<String, dynamic>> getTopPenanggungJawab() async {
    try {
      final querySnapshot = await _firestore
          .collection('agenda')
          .where('type', isEqualTo: 'kegiatan')
          .get();

      // Count kegiatan per PJ
      Map<String, int> pjCount = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final pj = data['penanggungJawab'] ?? 'Unknown';
        pjCount[pj] = (pjCount[pj] ?? 0) + 1;
      }

      // Find top PJ
      if (pjCount.isEmpty) {
        return {'nama': 'Belum ada', 'jumlah': 0};
      }

      String topPJ = pjCount.keys.first;
      int maxCount = pjCount[topPJ]!;

      pjCount.forEach((nama, count) {
        if (count > maxCount) {
          topPJ = nama;
          maxCount = count;
        }
      });

      return {'nama': topPJ, 'jumlah': maxCount};
    } catch (e) {
      print('Error getTopPenanggungJawab: $e');
      return {'nama': 'Error', 'jumlah': 0};
    }
  }

  /// Get kegiatan by kategori (untuk chart)
  Future<Map<String, int>> getKegiatanByKategori() async {
    try {
      final querySnapshot = await _firestore
          .collection('agenda')
          .where('type', isEqualTo: 'kegiatan')
          .get();

      Map<String, int> kategoriCount = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final kategori = data['kategori'] ?? 'Lainnya';
        kategoriCount[kategori] = (kategoriCount[kategori] ?? 0) + 1;
      }

      return kategoriCount;
    } catch (e) {
      print('Error getKegiatanByKategori: $e');
      return {};
    }
  }

  /// Get kegiatan by month (untuk monthly chart)
  Future<Map<int, int>> getKegiatanByMonth() async {
    try {
      final now = DateTime.now();
      final currentYear = now.year;

      final querySnapshot = await _firestore
          .collection('agenda')
          .where('type', isEqualTo: 'kegiatan')
          .get();

      // Initialize all months dengan 0
      Map<int, int> monthCount = {
        for (int i = 1; i <= 12; i++) i: 0,
      };

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['tanggal'] != null) {
          final tanggal = (data['tanggal'] as Timestamp).toDate();

          // Only count current year
          if (tanggal.year == currentYear) {
            monthCount[tanggal.month] = (monthCount[tanggal.month] ?? 0) + 1;
          }
        }
      }

      return monthCount;
    } catch (e) {
      print('Error getKegiatanByMonth: $e');
      return {for (int i = 1; i <= 12; i++) i: 0};
    }
  }

  // ============================================================================
  // DATA WARGA
  // ============================================================================

  /// Get total warga
  Future<int> getTotalWarga() async {
    try {
      final querySnapshot = await _firestore
          .collection('warga')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getTotalWarga: $e');
      return 0;
    }
  }

  /// Get warga by gender
  Future<Map<String, int>> getWargaByGender() async {
    try {
      final querySnapshot = await _firestore
          .collection('warga')
          .get();

      int lakiLaki = 0;
      int perempuan = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final gender = data['jenisKelamin'] ?? data['gender'] ?? '';

        if (gender.toLowerCase().contains('laki')) {
          lakiLaki++;
        } else if (gender.toLowerCase().contains('perempuan')) {
          perempuan++;
        }
      }

      return {
        'laki_laki': lakiLaki,
        'perempuan': perempuan,
      };
    } catch (e) {
      print('Error getWargaByGender: $e');
      return {
        'laki_laki': 0,
        'perempuan': 0,
      };
    }
  }

  // ============================================================================
  // LOG AKTIVITAS (RECENT ACTIVITIES)
  // ============================================================================

  /// Get recent activities (5 terakhir)
  Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 5}) async {
    try {
      // Get from multiple collections dan combine
      List<Map<String, dynamic>> activities = [];

      // Get dari keuangan
      final keuanganSnapshot = await _firestore
          .collection('keuangan')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      for (var doc in keuanganSnapshot.docs) {
        final data = doc.data();
        activities.add({
          'type': 'keuangan',
          'subtype': data['type'],
          'title': data['keterangan'] ?? 'Transaksi ${data['type']}',
          'amount': data['amount'],
          'timestamp': data['createdAt'],
          'icon': data['type'] == 'pemasukan'
              ? 'arrow_upward'
              : 'arrow_downward',
        });
      }

      // Get dari agenda
      final agendaSnapshot = await _firestore
          .collection('agenda')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      for (var doc in agendaSnapshot.docs) {
        final data = doc.data();
        activities.add({
          'type': 'agenda',
          'subtype': data['type'],
          'title': data['title'] ?? data['judul'] ?? 'Kegiatan baru',
          'timestamp': data['createdAt'],
          'icon': 'event',
        });
      }

      // Sort by timestamp descending
      activities.sort((a, b) {
        final aTime = a['timestamp'] as Timestamp?;
        final bTime = b['timestamp'] as Timestamp?;

        if (aTime == null) return 1;
        if (bTime == null) return -1;

        return bTime.compareTo(aTime);
      });

      // Return top limit
      return activities.take(limit).toList();
    } catch (e) {
      print('Error getRecentActivities: $e');
      return [];
    }
  }

  // ============================================================================
  // DASHBOARD SUMMARY (ALL DATA AT ONCE)
  // ============================================================================

  /// Get semua data dashboard dalam satu call
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final results = await Future.wait([
        getTotalKasMasuk(),
        getTotalKasKeluar(),
        getTotalTransaksi(),
        getTotalKegiatan(),
        getKegiatanByTimeline(),
        getTopPenanggungJawab(),
        getTotalWarga(),
        getRecentActivities(),
      ]);

      return {
        'kasMasuk': results[0],
        'kasKeluar': results[1],
        'totalTransaksi': results[2],
        'totalKegiatan': results[3],
        'timeline': results[4],
        'topPJ': results[5],
        'totalWarga': results[6],
        'recentActivities': results[7],
        'saldo': (results[0] as double) - (results[1] as double),
      };
    } catch (e) {
      print('Error getDashboardSummary: $e');
      rethrow;
    }
  }
}

