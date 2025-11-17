import 'package:cloud_firestore/cloud_firestore.dart';

/// Warga Model
/// Model data untuk warga/penduduk
/// Updated with full CRUD support
class WargaModel {
  final String id;
  final String nik;
  final String nomorKK;
  final String name;
  final String tempatLahir;
  final DateTime? birthDate;
  final String jenisKelamin; // 'Laki-laki' or 'Perempuan'
  final String agama;
  final String golonganDarah;
  final String pendidikan;
  final String pekerjaan;
  final String statusPerkawinan; // 'Kawin', 'Belum Kawin', 'Cerai Hidup', 'Cerai Mati'
  final String statusPenduduk; // 'Aktif' or 'Nonaktif'
  final String statusHidup; // 'Hidup' or 'Wafat'
  final String peranKeluarga; // 'Kepala Keluarga', 'Istri', 'Anak', etc.
  final String namaIbu;
  final String namaAyah;
  final String rt;
  final String rw;
  final String alamat;
  final String phone;
  final String kewarganegaraan;
  final String namaKeluarga;
  final String photoUrl;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WargaModel({
    required this.id,
    required this.nik,
    this.nomorKK = '',
    required this.name,
    this.tempatLahir = '',
    this.birthDate,
    required this.jenisKelamin,
    this.agama = '',
    this.golonganDarah = '',
    this.pendidikan = '',
    this.pekerjaan = '',
    this.statusPerkawinan = '',
    this.statusPenduduk = 'Aktif',
    this.statusHidup = 'Hidup',
    this.peranKeluarga = '',
    this.namaIbu = '',
    this.namaAyah = '',
    this.rt = '',
    this.rw = '',
    this.alamat = '',
    this.phone = '',
    this.kewarganegaraan = 'Indonesia',
    this.namaKeluarga = '',
    this.photoUrl = '',
    this.createdBy = '',
    this.createdAt,
    this.updatedAt,
  });

  // From Firestore
  factory WargaModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) {
        throw Exception('Document data is null');
      }

      return WargaModel(
        id: doc.id,
        nik: data['nik']?.toString() ?? '',
        nomorKK: data['nomorKK']?.toString() ?? '',
        name: data['name']?.toString() ?? data['nama']?.toString() ?? '',
        tempatLahir: data['tempatLahir']?.toString() ?? '',
        birthDate: (data['birthDate'] as Timestamp?)?.toDate() ??
                   (data['tanggalLahir'] as Timestamp?)?.toDate(),
        jenisKelamin: data['jenisKelamin']?.toString() ?? data['gender']?.toString() ?? '',
        agama: data['agama']?.toString() ?? '',
        golonganDarah: data['golonganDarah']?.toString() ?? '',
        pendidikan: data['pendidikan']?.toString() ?? '',
        pekerjaan: data['pekerjaan']?.toString() ?? data['occupation']?.toString() ?? '',
        statusPerkawinan: data['statusPerkawinan']?.toString() ?? data['status']?.toString() ?? '',
        statusPenduduk: data['statusPenduduk']?.toString() ?? 'Aktif',
        statusHidup: data['statusHidup']?.toString() ?? 'Hidup',
        peranKeluarga: data['peranKeluarga']?.toString() ?? '',
        namaIbu: data['namaIbu']?.toString() ?? '',
        namaAyah: data['namaAyah']?.toString() ?? '',
        rt: data['rt']?.toString() ?? '',
        rw: data['rw']?.toString() ?? '',
        alamat: data['alamat']?.toString() ?? data['address']?.toString() ?? '',
        phone: data['phone']?.toString() ?? data['telepon']?.toString() ?? '',
        kewarganegaraan: data['kewarganegaraan']?.toString() ?? 'Indonesia',
        namaKeluarga: data['namaKeluarga']?.toString() ?? '',
        photoUrl: data['photoUrl']?.toString() ?? '',
        createdBy: data['createdBy']?.toString() ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      print('❌ Error parsing WargaModel from Firestore: $e');
      print('Document ID: ${doc.id}');
      print('Document data: ${doc.data()}');
      rethrow;
    }
  }

  // From Map
  factory WargaModel.fromMap(Map<String, dynamic> map, String id) {
    return WargaModel(
      id: id,
      nik: map['nik'] ?? '',
      nomorKK: map['nomorKK'] ?? '',
      name: map['name'] ?? map['nama'] ?? '',
      tempatLahir: map['tempatLahir'] ?? '',
      birthDate: (map['birthDate'] as Timestamp?)?.toDate() ??
                 (map['tanggalLahir'] as Timestamp?)?.toDate(),
      jenisKelamin: map['jenisKelamin'] ?? map['gender'] ?? '',
      agama: map['agama'] ?? '',
      golonganDarah: map['golonganDarah'] ?? '',
      pendidikan: map['pendidikan'] ?? '',
      pekerjaan: map['pekerjaan'] ?? map['occupation'] ?? '',
      statusPerkawinan: map['statusPerkawinan'] ?? map['status'] ?? '',
      statusPenduduk: map['statusPenduduk'] ?? 'Aktif',
      statusHidup: map['statusHidup'] ?? 'Hidup',
      peranKeluarga: map['peranKeluarga'] ?? '',
      namaIbu: map['namaIbu'] ?? '',
      namaAyah: map['namaAyah'] ?? '',
      rt: map['rt'] ?? '',
      rw: map['rw'] ?? '',
      alamat: map['alamat'] ?? map['address'] ?? '',
      phone: map['phone'] ?? map['telepon'] ?? '',
      kewarganegaraan: map['kewarganegaraan'] ?? 'Indonesia',
      namaKeluarga: map['namaKeluarga'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'nik': nik,
      'nomorKK': nomorKK,
      'name': name,
      'tempatLahir': tempatLahir,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'jenisKelamin': jenisKelamin,
      'agama': agama,
      'golonganDarah': golonganDarah,
      'pendidikan': pendidikan,
      'pekerjaan': pekerjaan,
      'statusPerkawinan': statusPerkawinan,
      'statusPenduduk': statusPenduduk,
      'statusHidup': statusHidup,
      'peranKeluarga': peranKeluarga,
      'namaIbu': namaIbu,
      'namaAyah': namaAyah,
      'rt': rt,
      'rw': rw,
      'alamat': alamat,
      'phone': phone,
      'kewarganegaraan': kewarganegaraan,
      'namaKeluarga': namaKeluarga,
      'photoUrl': photoUrl,
      'createdBy': createdBy,
    };
  }

  // Copy with
  WargaModel copyWith({
    String? nik,
    String? nomorKK,
    String? name,
    String? tempatLahir,
    DateTime? birthDate,
    String? jenisKelamin,
    String? agama,
    String? golonganDarah,
    String? pendidikan,
    String? pekerjaan,
    String? statusPerkawinan,
    String? statusPenduduk,
    String? statusHidup,
    String? peranKeluarga,
    String? namaIbu,
    String? namaAyah,
    String? rt,
    String? rw,
    String? alamat,
    String? phone,
    String? kewarganegaraan,
    String? namaKeluarga,
    String? photoUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WargaModel(
      id: id,
      nik: nik ?? this.nik,
      nomorKK: nomorKK ?? this.nomorKK,
      name: name ?? this.name,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      birthDate: birthDate ?? this.birthDate,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      agama: agama ?? this.agama,
      golonganDarah: golonganDarah ?? this.golonganDarah,
      pendidikan: pendidikan ?? this.pendidikan,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      statusPerkawinan: statusPerkawinan ?? this.statusPerkawinan,
      statusPenduduk: statusPenduduk ?? this.statusPenduduk,
      statusHidup: statusHidup ?? this.statusHidup,
      peranKeluarga: peranKeluarga ?? this.peranKeluarga,
      namaIbu: namaIbu ?? this.namaIbu,
      namaAyah: namaAyah ?? this.namaAyah,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      alamat: alamat ?? this.alamat,
      phone: phone ?? this.phone,
      kewarganegaraan: kewarganegaraan ?? this.kewarganegaraan,
      namaKeluarga: namaKeluarga ?? this.namaKeluarga,
      photoUrl: photoUrl ?? this.photoUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get age from birthDate
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // Get formatted birthDate
  String get formattedBirthDate {
    if (birthDate == null) return '-';
    return '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}';
  }

  // Get formatted birthplace and date
  String get formattedBirthInfo {
    if (tempatLahir.isEmpty && birthDate == null) return '-';
    if (tempatLahir.isEmpty) return formattedBirthDate;
    if (birthDate == null) return tempatLahir;
    return '$tempatLahir, $formattedBirthDate';
  }

  // Check if warga is active
  bool get isActive => statusPenduduk.toLowerCase() == 'aktif';

  // Check if warga is alive
  bool get isAlive => statusHidup.toLowerCase() == 'hidup';
}

