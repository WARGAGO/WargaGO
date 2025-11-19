import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
/// Model untuk Tagihan (Bills/Invoices)
/// Menyimpan informasi tagihan iuran untuk setiap keluarga
class TagihanModel {
  final String id;
  final String kodeTagihan;
  final String jenisIuranId;
  final String jenisIuranName;
  final String keluargaId;
  final String keluargaName;
  final double nominal;
  final String periode; // Format: "November 2025", "Minggu ke-1 November 2025"
  final DateTime periodeTanggal; // Tanggal jatuh tempo
  final String status; // 'Belum Dibayar', 'Lunas', 'Terlambat'
  final String? metodePembayaran; // 'Cash', 'Transfer', 'E-Wallet'
  final DateTime? tanggalBayar;
  final String? buktiPembayaran; // URL foto bukti transfer
  final String? catatan;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  TagihanModel({
    required this.id,
    required this.kodeTagihan,
    required this.jenisIuranId,
    required this.jenisIuranName,
    required this.keluargaId,
    required this.keluargaName,
    required this.nominal,
    required this.periode,
    required this.periodeTanggal,
    required this.status,
    this.metodePembayaran,
    this.tanggalBayar,
    this.buktiPembayaran,
    this.catatan,
    this.createdBy = '',
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  // From Firestore
  factory TagihanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TagihanModel(
      id: doc.id,
      kodeTagihan: data['kodeTagihan'] ?? '',
      jenisIuranId: data['jenisIuranId'] ?? '',
      jenisIuranName: data['jenisIuranName'] ?? '',
      keluargaId: data['keluargaId'] ?? '',
      keluargaName: data['keluargaName'] ?? '',
      nominal: (data['nominal'] as num?)?.toDouble() ?? 0.0,
      periode: data['periode'] ?? '',
      periodeTanggal: (data['periodeTanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'Belum Dibayar',
      metodePembayaran: data['metodePembayaran'],
      tanggalBayar: (data['tanggalBayar'] as Timestamp?)?.toDate(),
      buktiPembayaran: data['buktiPembayaran'],
      catatan: data['catatan'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // From Map
  factory TagihanModel.fromMap(Map<String, dynamic> map, String id) {
    return TagihanModel(
      id: id,
      kodeTagihan: map['kodeTagihan'] ?? '',
      jenisIuranId: map['jenisIuranId'] ?? '',
      jenisIuranName: map['jenisIuranName'] ?? '',
      keluargaId: map['keluargaId'] ?? '',
      keluargaName: map['keluargaName'] ?? '',
      nominal: (map['nominal'] as num?)?.toDouble() ?? 0.0,
      periode: map['periode'] ?? '',
      periodeTanggal: (map['periodeTanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'Belum Dibayar',
      metodePembayaran: map['metodePembayaran'],
      tanggalBayar: (map['tanggalBayar'] as Timestamp?)?.toDate(),
      buktiPembayaran: map['buktiPembayaran'],
      catatan: map['catatan'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'kodeTagihan': kodeTagihan,
      'jenisIuranId': jenisIuranId,
      'jenisIuranName': jenisIuranName,
      'keluargaId': keluargaId,
      'keluargaName': keluargaName,
      'nominal': nominal,
      'periode': periode,
      'periodeTanggal': Timestamp.fromDate(periodeTanggal),
      'status': status,
      'metodePembayaran': metodePembayaran,
      'tanggalBayar': tanggalBayar != null ? Timestamp.fromDate(tanggalBayar!) : null,
      'buktiPembayaran': buktiPembayaran,
      'catatan': catatan,
      'createdBy': createdBy,
      'isActive': isActive,
    };
  }

  // Copy with
  TagihanModel copyWith({
    String? kodeTagihan,
    String? jenisIuranId,
    String? jenisIuranName,
    String? keluargaId,
    String? keluargaName,
    double? nominal,
    String? periode,
    DateTime? periodeTanggal,
    String? status,
    String? metodePembayaran,
    DateTime? tanggalBayar,
    String? buktiPembayaran,
    String? catatan,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return TagihanModel(
      id: id,
      kodeTagihan: kodeTagihan ?? this.kodeTagihan,
      jenisIuranId: jenisIuranId ?? this.jenisIuranId,
      jenisIuranName: jenisIuranName ?? this.jenisIuranName,
      keluargaId: keluargaId ?? this.keluargaId,
      keluargaName: keluargaName ?? this.keluargaName,
      nominal: nominal ?? this.nominal,
      periode: periode ?? this.periode,
      periodeTanggal: periodeTanggal ?? this.periodeTanggal,
      status: status ?? this.status,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      tanggalBayar: tanggalBayar ?? this.tanggalBayar,
      buktiPembayaran: buktiPembayaran ?? this.buktiPembayaran,
      catatan: catatan ?? this.catatan,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case 'Lunas':
        return const Color(0xFF10B981); // Green
      case 'Belum Dibayar':
        return const Color(0xFFEF4444); // Red
      case 'Terlambat':
        return const Color(0xFFF59E0B); // Orange
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  // Format nominal
  String get formattedNominal {
    return 'Rp ${nominal.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  // Format periode tanggal
  String get formattedPeriodeTanggal {
    return '${periodeTanggal.day} ${_getMonthName(periodeTanggal.month)} ${periodeTanggal.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  // Check if overdue
  bool get isOverdue {
    if (status == 'Lunas') return false;
    return DateTime.now().isAfter(periodeTanggal);
  }

  // Get days until due
  int get daysUntilDue {
    return periodeTanggal.difference(DateTime.now()).inDays;
  }
}

