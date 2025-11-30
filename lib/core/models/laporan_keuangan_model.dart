import 'package:cloud_firestore/cloud_firestore.dart';

class LaporanKeuanganModel {
  final String id;
  final String judul;
  final String keterangan;
  final PeriodeLaporan periode;
  final String jenisLaporan; // 'pemasukan' | 'pengeluaran' | 'gabungan'
  final DateTime createdAt;
  final CreatedBy createdBy;
  final StatistikLaporan statistik;
  final List<TransaksiLaporan> dataPemasukan;
  final List<TransaksiLaporan> dataPengeluaran;
  final bool isPublished;
  final int viewsCount;

  LaporanKeuanganModel({
    required this.id,
    required this.judul,
    required this.keterangan,
    required this.periode,
    required this.jenisLaporan,
    required this.createdAt,
    required this.createdBy,
    required this.statistik,
    required this.dataPemasukan,
    required this.dataPengeluaran,
    this.isPublished = true,
    this.viewsCount = 0,
  });

  factory LaporanKeuanganModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LaporanKeuanganModel(
      id: doc.id,
      judul: data['judul'] ?? '',
      keterangan: data['keterangan'] ?? '',
      periode: PeriodeLaporan.fromMap(data['periode'] ?? {}),
      jenisLaporan: data['jenis_laporan'] ?? 'gabungan',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: CreatedBy.fromMap(data['created_by'] ?? {}),
      statistik: StatistikLaporan.fromMap(data['statistik'] ?? {}),
      dataPemasukan: (data['data_pemasukan'] as List<dynamic>?)
              ?.map((e) => TransaksiLaporan.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      dataPengeluaran: (data['data_pengeluaran'] as List<dynamic>?)
              ?.map((e) => TransaksiLaporan.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      isPublished: data['is_published'] ?? true,
      viewsCount: data['views_count'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'judul': judul,
      'keterangan': keterangan,
      'periode': periode.toMap(),
      'jenis_laporan': jenisLaporan,
      'created_at': Timestamp.fromDate(createdAt),
      'created_by': createdBy.toMap(),
      'statistik': statistik.toMap(),
      'data_pemasukan': dataPemasukan.map((e) => e.toMap()).toList(),
      'data_pengeluaran': dataPengeluaran.map((e) => e.toMap()).toList(),
      'is_published': isPublished,
      'views_count': viewsCount,
    };
  }
}

class PeriodeLaporan {
  final int bulan;
  final int tahun;
  final String label;

  PeriodeLaporan({
    required this.bulan,
    required this.tahun,
    required this.label,
  });

  factory PeriodeLaporan.fromMap(Map<String, dynamic> map) {
    return PeriodeLaporan(
      bulan: map['bulan'] ?? 1,
      tahun: map['tahun'] ?? DateTime.now().year,
      label: map['label'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bulan': bulan,
      'tahun': tahun,
      'label': label,
    };
  }
}

class CreatedBy {
  final String id;
  final String nama;
  final String role;

  CreatedBy({
    required this.id,
    required this.nama,
    required this.role,
  });

  factory CreatedBy.fromMap(Map<String, dynamic> map) {
    return CreatedBy(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      role: map['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'role': role,
    };
  }
}

class StatistikLaporan {
  final double totalPemasukan;
  final double totalPengeluaran;
  final double saldo;
  final int jumlahTransaksi;
  final Map<String, double> kategoriBreakdown;

  StatistikLaporan({
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.saldo,
    required this.jumlahTransaksi,
    required this.kategoriBreakdown,
  });

  factory StatistikLaporan.fromMap(Map<String, dynamic> map) {
    return StatistikLaporan(
      totalPemasukan: (map['total_pemasukan'] ?? 0).toDouble(),
      totalPengeluaran: (map['total_pengeluaran'] ?? 0).toDouble(),
      saldo: (map['saldo'] ?? 0).toDouble(),
      jumlahTransaksi: map['jumlah_transaksi'] ?? 0,
      kategoriBreakdown: Map<String, double>.from(map['kategori_breakdown'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_pemasukan': totalPemasukan,
      'total_pengeluaran': totalPengeluaran,
      'saldo': saldo,
      'jumlah_transaksi': jumlahTransaksi,
      'kategori_breakdown': kategoriBreakdown,
    };
  }
}

class TransaksiLaporan {
  final String tanggal;
  final String nama;
  final String kategori;
  final double nominal;
  final String status;
  final String deskripsi;

  TransaksiLaporan({
    required this.tanggal,
    required this.nama,
    required this.kategori,
    required this.nominal,
    required this.status,
    required this.deskripsi,
  });

  factory TransaksiLaporan.fromMap(Map<String, dynamic> map) {
    return TransaksiLaporan(
      tanggal: map['tanggal'] ?? '',
      nama: map['nama'] ?? '',
      kategori: map['kategori'] ?? '',
      nominal: (map['nominal'] ?? 0).toDouble(),
      status: map['status'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tanggal': tanggal,
      'nama': nama,
      'kategori': kategori,
      'nominal': nominal,
      'status': status,
      'deskripsi': deskripsi,
    };
  }
}

