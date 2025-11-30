import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/laporan_keuangan_model.dart';

class LaporanKeuanganService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Publish laporan keuangan
  Future<bool> publishLaporan({
    required String judul,
    required String keterangan,
    required int bulan,
    required int tahun,
    required String jenisLaporan,
    required List<Map<String, dynamic>> dataPemasukan,
    required List<Map<String, dynamic>> dataPengeluaran,
    required String adminId,
    required String adminNama,
    required String adminRole,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 PUBLISH LAPORAN KEUANGAN');
      debugPrint('   📝 Judul: $judul');
      debugPrint('   📅 Periode: ${_getBulanLabel(bulan)} $tahun');
      debugPrint('   📁 Jenis: $jenisLaporan');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Calculate statistics
      double totalPemasukan = 0;
      double totalPengeluaran = 0;
      Map<String, double> kategoriBreakdown = {};

      // Process pemasukan
      for (var item in dataPemasukan) {
        final nominal = (item['nominal'] ?? 0).toDouble();
        totalPemasukan += nominal;

        final kategori = item['category'] ?? 'Lainnya';
        kategoriBreakdown[kategori] = (kategoriBreakdown[kategori] ?? 0) + nominal;
      }

      // Process pengeluaran
      for (var item in dataPengeluaran) {
        final nominal = (item['nominal'] ?? 0).toDouble();
        totalPengeluaran += nominal;

        final kategori = item['category'] ?? 'Lainnya';
        kategoriBreakdown[kategori] = (kategoriBreakdown[kategori] ?? 0) + nominal;
      }

      final saldo = totalPemasukan - totalPengeluaran;
      final jumlahTransaksi = dataPemasukan.length + dataPengeluaran.length;

      // Convert to TransaksiLaporan format
      final List<Map<String, dynamic>> transaksiPemasukan = dataPemasukan.map((item) {
        return {
          'tanggal': item['tanggal'] ?? '',
          'nama': item['name'] ?? '',
          'kategori': item['category'] ?? '',
          'nominal': (item['nominal'] ?? 0).toDouble(),
          'status': item['status'] ?? '',
          'deskripsi': item['deskripsi'] ?? '',
        };
      }).toList();

      final List<Map<String, dynamic>> transaksiPengeluaran = dataPengeluaran.map((item) {
        return {
          'tanggal': item['tanggal'] ?? '',
          'nama': item['name'] ?? '',
          'kategori': item['category'] ?? '',
          'nominal': (item['nominal'] ?? 0).toDouble(),
          'status': item['status'] ?? '',
          'deskripsi': item['deskripsi'] ?? '',
        };
      }).toList();

      // Create laporan model
      final laporan = LaporanKeuanganModel(
        id: '',
        judul: judul,
        keterangan: keterangan,
        periode: PeriodeLaporan(
          bulan: bulan,
          tahun: tahun,
          label: '${_getBulanLabel(bulan)} $tahun',
        ),
        jenisLaporan: jenisLaporan,
        createdAt: DateTime.now(),
        createdBy: CreatedBy(
          id: adminId,
          nama: adminNama,
          role: adminRole,
        ),
        statistik: StatistikLaporan(
          totalPemasukan: totalPemasukan,
          totalPengeluaran: totalPengeluaran,
          saldo: saldo,
          jumlahTransaksi: jumlahTransaksi,
          kategoriBreakdown: kategoriBreakdown,
        ),
        dataPemasukan: transaksiPemasukan.map((e) => TransaksiLaporan.fromMap(e)).toList(),
        dataPengeluaran: transaksiPengeluaran.map((e) => TransaksiLaporan.fromMap(e)).toList(),
        isPublished: true,
        viewsCount: 0,
      );

      // Save to Firestore
      final docRef = await _firestore.collection('laporan_keuangan').add(laporan.toFirestore());

      debugPrint('✅ Laporan berhasil dipublish!');
      debugPrint('   📄 ID: ${docRef.id}');
      debugPrint('   💰 Total Pemasukan: ${currencyFormat.format(totalPemasukan)}');
      debugPrint('   💸 Total Pengeluaran: ${currencyFormat.format(totalPengeluaran)}');
      debugPrint('   📊 Saldo: ${currencyFormat.format(saldo)}');
      debugPrint('   📝 Total Transaksi: $jumlahTransaksi');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Error publishing laporan: $e');
      debugPrint('   Stack: $stackTrace');
      return false;
    }
  }

  /// Get all published laporan (for warga)
  Stream<List<LaporanKeuanganModel>> getLaporanStream() {
    return _firestore
        .collection('laporan_keuangan')
        .where('is_published', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LaporanKeuanganModel.fromFirestore(doc)).toList();
    });
  }

  /// Get laporan by ID
  Future<LaporanKeuanganModel?> getLaporanById(String id) async {
    try {
      final doc = await _firestore.collection('laporan_keuangan').doc(id).get();
      if (doc.exists) {
        return LaporanKeuanganModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting laporan: $e');
      return null;
    }
  }

  /// Increment views count
  Future<void> incrementViews(String laporanId) async {
    try {
      await _firestore.collection('laporan_keuangan').doc(laporanId).update({
        'views_count': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('❌ Error incrementing views: $e');
    }
  }

  /// Delete laporan (admin only)
  Future<bool> deleteLaporan(String id) async {
    try {
      await _firestore.collection('laporan_keuangan').doc(id).delete();
      debugPrint('✅ Laporan deleted: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting laporan: $e');
      return false;
    }
  }

  String _getBulanLabel(int bulan) {
    const bulanLabels = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanLabels[bulan - 1];
  }
}

