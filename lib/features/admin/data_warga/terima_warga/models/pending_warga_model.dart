import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk warga yang menunggu persetujuan
class PendingWargaModel {
  final String? id;
  final String name;
  final String nik;
  final String jenisKelamin;
  final DateTime tanggalLahir;
  final String tempatLahir;
  final String agama;
  final String statusPerkawinan;
  final String pekerjaan;
  final String kewarganegaraan;
  final String golonganDarah;
  final String alamat;
  final String rt;
  final String rw;
  final String nomorKK;
  final String hubunganKeluarga;
  final String pendidikan;
  final String noTelepon;
  final String email;
  final String status; // 'pending', 'approved', 'rejected'
  final String? alasanPenolakan;
  final String? fotoUrl;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  PendingWargaModel({
    this.id,
    required this.name,
    required this.nik,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.tempatLahir,
    this.agama = 'Islam',
    this.statusPerkawinan = 'Belum Kawin',
    this.pekerjaan = 'Belum Bekerja',
    this.kewarganegaraan = 'WNI',
    this.golonganDarah = 'O',
    required this.alamat,
    this.rt = '',
    this.rw = '',
    required this.nomorKK,
    this.hubunganKeluarga = 'Anak',
    this.pendidikan = 'SD',
    this.noTelepon = '',
    this.email = '',
    this.status = 'pending',
    this.alasanPenolakan,
    this.fotoUrl,
    this.createdBy = 'user',
    this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  /// From Firestore
  factory PendingWargaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PendingWargaModel(
      id: doc.id,
      name: data['name'] ?? '',
      nik: data['nik'] ?? '',
      jenisKelamin: data['jenisKelamin'] ?? 'Laki-laki',
      tanggalLahir: (data['tanggalLahir'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tempatLahir: data['tempatLahir'] ?? '',
      agama: data['agama'] ?? 'Islam',
      statusPerkawinan: data['statusPerkawinan'] ?? 'Belum Kawin',
      pekerjaan: data['pekerjaan'] ?? 'Belum Bekerja',
      kewarganegaraan: data['kewarganegaraan'] ?? 'WNI',
      golonganDarah: data['golonganDarah'] ?? 'O',
      alamat: data['alamat'] ?? '',
      rt: data['rt'] ?? '',
      rw: data['rw'] ?? '',
      nomorKK: data['nomorKK'] ?? '',
      hubunganKeluarga: data['hubunganKeluarga'] ?? 'Anak',
      pendidikan: data['pendidikan'] ?? 'SD',
      noTelepon: data['noTelepon'] ?? '',
      email: data['email'] ?? '',
      status: data['status'] ?? 'pending',
      alasanPenolakan: data['alasanPenolakan'],
      fotoUrl: data['fotoUrl'],
      createdBy: data['createdBy'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      approvedBy: data['approvedBy'],
    );
  }

  /// To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nik': nik,
      'jenisKelamin': jenisKelamin,
      'tanggalLahir': Timestamp.fromDate(tanggalLahir),
      'tempatLahir': tempatLahir,
      'agama': agama,
      'statusPerkawinan': statusPerkawinan,
      'pekerjaan': pekerjaan,
      'kewarganegaraan': kewarganegaraan,
      'golonganDarah': golonganDarah,
      'alamat': alamat,
      'rt': rt,
      'rw': rw,
      'nomorKK': nomorKK,
      'hubunganKeluarga': hubunganKeluarga,
      'pendidikan': pendidikan,
      'noTelepon': noTelepon,
      'email': email,
      'status': status,
      'alasanPenolakan': alasanPenolakan,
      'fotoUrl': fotoUrl,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
    };
  }

  /// Copy with
  PendingWargaModel copyWith({
    String? id,
    String? name,
    String? nik,
    String? jenisKelamin,
    DateTime? tanggalLahir,
    String? tempatLahir,
    String? agama,
    String? statusPerkawinan,
    String? pekerjaan,
    String? kewarganegaraan,
    String? golonganDarah,
    String? alamat,
    String? rt,
    String? rw,
    String? nomorKK,
    String? hubunganKeluarga,
    String? pendidikan,
    String? noTelepon,
    String? email,
    String? status,
    String? alasanPenolakan,
    String? fotoUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return PendingWargaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nik: nik ?? this.nik,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      agama: agama ?? this.agama,
      statusPerkawinan: statusPerkawinan ?? this.statusPerkawinan,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      kewarganegaraan: kewarganegaraan ?? this.kewarganegaraan,
      golonganDarah: golonganDarah ?? this.golonganDarah,
      alamat: alamat ?? this.alamat,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      nomorKK: nomorKK ?? this.nomorKK,
      hubunganKeluarga: hubunganKeluarga ?? this.hubunganKeluarga,
      pendidikan: pendidikan ?? this.pendidikan,
      noTelepon: noTelepon ?? this.noTelepon,
      email: email ?? this.email,
      status: status ?? this.status,
      alasanPenolakan: alasanPenolakan ?? this.alasanPenolakan,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  /// Get formatted address
  String get formattedAddress {
    if (rt.isEmpty && rw.isEmpty) return alamat;
    return '$alamat, RT $rt RW $rw';
  }

  /// Get umur
  int get umur {
    final now = DateTime.now();
    int age = now.year - tanggalLahir.year;
    if (now.month < tanggalLahir.month ||
        (now.month == tanggalLahir.month && now.day < tanggalLahir.day)) {
      age--;
    }
    return age;
  }
}

