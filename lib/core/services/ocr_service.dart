// ============================================================================
// OCR SERVICE - INDONESIAN KTP & KK SPECIALIZED
// ============================================================================
// Service untuk melakukan OCR pada dokumen KYC Indonesia (KTP & KK).
// Menggunakan Google ML Kit dengan strategi ekstraksi khusus untuk layout
// yang berbeda antara KTP dan Kartu Keluarga.
// ============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// Pastikan model Anda mengakomodasi field tambahan jika perlu,
// atau gunakan model yang fleksibel.
import '../models/kyc_document_model.dart';

enum DocumentType { ktp, kk, unknown }

class OCRService {
  // Text recognizer instance
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Process image, classify document type, and extract text
  Future<OCRResult?> processImage(File imageFile) async {
    try {
      if (kDebugMode) {
        print('🔍 Starting OCR processing...');
        print('Image path: ${imageFile.path}');
      }

      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String rawText = recognizedText.text;

      // 1. Preprocessing: Bersihkan teks mentah dari kesalahan OCR umum
      rawText = _cleanRawText(rawText);

      if (kDebugMode) {
        print('📝 Raw Text Cleaned:\n$rawText\n-------------------');
      }

      // 2. Klasifikasi Tipe Dokumen
      DocumentType docType = _determineDocumentType(rawText);
      if (kDebugMode) {
        print('🗂️ Document Type Detected: $docType');
      }

      // 3. Ekstraksi Berdasarkan Tipe Dokumen
      OCRResult extractedResult;

      switch (docType) {
        case DocumentType.kk:
          print('🤖 Menggunakan Strategi Ekstraksi KK...');
          extractedResult = _extractKKData(rawText);
          // Tambahkan info tipe dokumen ke result
          extractedResult.additionalFields?['document_type'] = 'KK';
          break;
        case DocumentType.ktp:
          print('🤖 Menggunakan Strategi Ekstraksi KTP...');
          // Gunakan logika KTP Anda yang sudah ada (sedikit dirapikan)
          extractedResult = _extractKTPData(rawText);
          extractedResult.additionalFields?['document_type'] = 'KTP';
          break;
        case DocumentType.unknown:
          print('⚠️ Tipe dokumen tidak dikenali, mencoba strategi KTP sebagai fallback...');
          extractedResult = _extractKTPData(rawText);
          extractedResult.additionalFields?['document_type'] = 'UNKNOWN';
          break;
      }

      // Final validation check (terutama untuk NIK/No KK)
      if (extractedResult.nik == null || extractedResult.nik!.length != 16) {
        if (kDebugMode) print('⚠️ Validasi Akhir: NIK/No KK 16 digit tidak ditemukan di hasil utama.');
        // Upaya terakhir mencari 16 digit angka apa saja jika strategi utama gagal total
        final fallbackNik = _findAny16DigitNumber(rawText);
        if (fallbackNik != null) {
          print('🔄 Fallback: Menggunakan 16 digit angka yang ditemukan: $fallbackNik');
          return OCRResult(
            nik: fallbackNik,
            nama: extractedResult.nama,
            tempatLahir: extractedResult.tempatLahir,
            tanggalLahir: extractedResult.tanggalLahir,
            alamat: extractedResult.alamat,
            additionalFields: extractedResult.additionalFields,
          );
        }
      }

      if (kDebugMode) {
        print('✅ OCR processing complete');
        print('ID Number (NIK/KK): ${extractedResult.nik ?? "NOT FOUND"}');
        print('Nama: ${extractedResult.nama ?? "NOT FOUND"}');
      }

      return extractedResult;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing image: $e');
      }
      return null;
    }
  }

  /// Membersihkan kesalahan OCR umum pada angka dan huruf yang mirip
  String _cleanRawText(String text) {
    // Ganti 'O' besar dengan '0' jika berada di dalam rangkaian angka (untuk NIK/Tanggal)
    // Ini regex sederhana, bisa dikembangkan.
    String cleaned = text.replaceAllMapped(RegExp(r'(?<=\d)[O](?=\d)'), (match) => '0');
    // Ganti 'l' atau 'I' dengan '1' jika di dalam angka
    cleaned = cleaned.replaceAllMapped(RegExp(r'(?<=\d)[lI](?=\d)'), (match) => '1');
    // Hapus karakter aneh di awal baris yang sering muncul akibat noise gambar
    cleaned = cleaned.replaceAll(RegExp(r'^[^\w\s]+', multiLine: true), '');
    return cleaned;
  }


  /// Menentukan apakah dokumen KTP atau KK berdasarkan keyword header
  DocumentType _determineDocumentType(String fullText) {
    final upperText = fullText.toUpperCase();

    int kkScore = 0;
    int ktpScore = 0;

    // Keywords Kuat untuk KK
    if (upperText.contains('KARTU KELUARGA')) kkScore += 10;
    if (upperText.contains('NO. KK') || upperText.contains('NOMOR KK')) kkScore += 8;
    if (upperText.contains('KEPALA KELUARGA')) kkScore += 8;
    // Keywords tabel KK
    if (upperText.contains('NAMA LENGKAP') && upperText.contains('STATUS HUBUNGAN')) kkScore += 5;

    // Keywords Kuat untuk KTP
    // Cek header "PROVINSI..." dan "KABUPATEN..." di bagian atas teks
    final firstFewLines = upperText.split('\n').take(5).join('\n');
    if (firstFewLines.contains('PROVINSI') && firstFewLines.contains('NIK')) ktpScore += 10;
    if (upperText.contains('KARTU TANDA PENDUDUK')) ktpScore += 5;
    if (upperText.contains('GOL. DARAH')) ktpScore += 5;
    if (upperText.contains('BERLAKU HINGGA')) ktpScore += 5;

    if (kkScore > ktpScore && kkScore >= 10) return DocumentType.kk;
    if (ktpScore > kkScore && ktpScore >= 10) return DocumentType.ktp;

    // Fallback: Jika NIK ditemukan di dekat kata PROVINSI, asumsikan KTP
    if(ktpScore > 5) return DocumentType.ktp;

    return DocumentType.unknown;
  }

  // ==========================================================================
  // STRATEGI EKSTRAKSI KK (KARTU KELUARGA) - BARU
  // ==========================================================================
  /// Ekstraksi data khusus untuk layout Kartu Keluarga.
  /// Fokus pada Header KK (No KK, Kepala Keluarga, Alamat) dan bukan tabel anggota.
  OCRResult _extractKKData(String text) {
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    Map<String, dynamic> data = {
      'no_kk': null, // Akan disimpan di field 'nik' pada model OCRResult
      'nama_kepala': null, // Akan disimpan di field 'nama'
      'alamat': null,
      'rt_rw': null,
      'desa_kelurahan': null,
      'kecamatan': null,
      'kabupaten_kota': null,
      'kode_pos': null,
      'provinsi': null,
    };

    // 1. Cari Nomor KK (Biasanya di bagian atas, font besar)
    // Mencari pola 16 digit yang mungkin diawali label "No. KK" atau berdiri sendiri di atas
    for (int i = 0; i < lines.length && i < 10; i++) { // Cek 10 baris pertama saja
      final lineUpper = lines[i].toUpperCase();
      // Hapus label jika ada, sisakan angkanya saja
      String cleanedLine = lineUpper.replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanedLine.length == 16) {
        // Validasi tambahan: Biasanya No KK tidak diawali 00
        if(!cleanedLine.startsWith('00')) {
          data['no_kk'] = cleanedLine;
          if (kDebugMode) print('✅ KK - Nomor KK ditemukan: ${data['no_kk']}');
          break;
        }
      }

      // Jika baris mengandung label dan angka (contoh: "No. KK : 3578...")
      if (lineUpper.contains('NO.') && lineUpper.contains('KK')) {
        final match = RegExp(r'\d{16}').firstMatch(lines[i]);
        if(match != null) {
          data['no_kk'] = match.group(0);
          if (kDebugMode) print('✅ KK - Nomor KK ditemukan (dengan label): ${data['no_kk']}');
          break;
        }
      }
    }

    // 2. Ekstraksi Key-Value pada Header KK (Nama Kepala, Alamat, dll)
    // Loop melalui baris untuk mencari label di sebelah kiri
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      String lineUpper = line.toUpperCase();

      // Stop jika sudah masuk area tabel anggota keluarga
      if (lineUpper.contains('NO.') && lineUpper.contains('NAMA LENGKAP') && lineUpper.contains('NIK')) {
        break;
      }

      // Helper untuk mengambil nilai setelah titik dua ':' atau di baris berikutnya
      String? getValue(String labelKeywords, int currentIndex) {
        bool labelMatch = labelKeywords.split('|').any((kw) => lineUpper.contains(kw));
        if (!labelMatch) return null;

        // Coba ambil di baris yang sama setelah ':'
        if (line.contains(':')) {
          List<String> parts = line.split(':');
          if (parts.length > 1) {
            String val = parts.sublist(1).join(':').trim(); // Gabung kembali jika ada : lain
            if(val.isNotEmpty && val.length > 2) return val;
          }
        }

        // Jika tidak ada ':' atau nilai kosong, coba baris berikutnya (hati-hati dengan label lain)
        if (currentIndex + 1 < lines.length) {
          String nextLine = lines[currentIndex+1].trim();
          // Pastikan baris berikutnya bukan label lain
          if(!nextLine.contains(':') && nextLine.length > 3 && !RegExp(r'^[A-Z\s\./]+$').hasMatch(nextLine)) {
            return nextLine;
          }
        }
        return null;
      }


      if (data['nama_kepala'] == null) data['nama_kepala'] = getValue('NAMA KEPALA KELUARGA|KEPALA KELUARGA', i);

      // Alamat di KK seringkali multi-line. Kita ambil baris pertama dulu.
      if (data['alamat'] == null && (lineUpper.startsWith('ALAMAT') || lineUpper == 'ALAMAT')) {
        String? alamatValue = getValue('ALAMAT', i);
        if(alamatValue != null) {
          // Coba gabungkan baris berikutnya jika itu adalah kelanjutan alamat (bukan RT/RW dll)
          String fullAlamat = alamatValue;
          for(int j = i + (line.contains(':') ? 1 : 2); j < lines.length && j < i + 4; j++) {
            String nextUpper = lines[j].toUpperCase();
            if(nextUpper.contains('RT/') || nextUpper.contains('DESA') || nextUpper.contains('KECAMATAN')) break;
            fullAlamat += ' ' + lines[j];
          }
          data['alamat'] = fullAlamat;
        }
      }

      if (data['rt_rw'] == null) {
        String? val = getValue('RT/RW', i);
        // Seringkali RT/RW terbaca sebagai "005 / 008" atau "005/008"
        if (val != null) {
          data['rt_rw'] = val.replaceAll(' ', '');
        } else if (lineUpper.contains('RT') && lineUpper.contains('RW')) {
          // Coba regex jika tidak ada titik dua
          final match = RegExp(r'(\d{1,3})\s*[\/]\s*(\d{1,3})').firstMatch(line);
          if (match != null) data['rt_rw'] = match.group(0)?.replaceAll(' ', '');
        }
      }

      if (data['desa_kelurahan'] == null) data['desa_kelurahan'] = getValue('DESA/KELURAHAN|KELURAHAN|DESA', i);
      if (data['kecamatan'] == null) data['kecamatan'] = getValue('KECAMATAN', i);
      if (data['kabupaten_kota'] == null) data['kabupaten_kota'] = getValue('KABUPATEN/KOTA|KABUPATEN|KOTA', i);
      if (data['kode_pos'] == null) {
        String? pos = getValue('KODE POS', i);
        if (pos != null) {
          data['kode_pos'] = RegExp(r'\d{5}').firstMatch(pos)?.group(0); // Ambil 5 digit
        } else if (lineUpper.contains('KODE POS')) {
          data['kode_pos'] = RegExp(r'\d{5}').firstMatch(line)?.group(0);
        }
      }
      if (data['provinsi'] == null) data['provinsi'] = getValue('PROVINSI', i);
    }

    // Mapping hasil KK ke model OCRResult
    // Catatan: 'nik' pada model diisi dengan 'Nomor KK'
    // 'nama' pada model diisi dengan 'Nama Kepala Keluarga'
    return OCRResult(
      nik: data['no_kk'], // Menggunakan field NIK untuk menyimpan No KK
      nama: data['nama_kepala'], // Menggunakan field Nama untuk Nama Kepala Keluarga
      alamat: data['alamat'],
      additionalFields: {
        'rt_rw': data['rt_rw'],
        'kelurahan': data['desa_kelurahan'],
        'kecamatan': data['kecamatan'],
        'kabupaten_kota': data['kabupaten_kota'],
        'kode_pos': data['kode_pos'],
        'provinsi': data['provinsi'],
        'is_kk_document': 'true', // Flag penanda bahwa ini data KK
      },
    );
  }

  // ==========================================================================
  // STRATEGI EKSTRAKSI KTP (Menggunakan kode Anda yang sudah ada)
  // ==========================================================================
  // Saya mempertahankan sebagian besar logika KTP Anda karena sudah cukup detail
  // untuk menangani variasi KTP, terutama validasi NIK-nya bagus.
  // Hanya sedikit penyesuaian kecil.
  // ==========================================================================

  OCRResult _extractKTPData(String text) {
    // ... (Gunakan implementasi _extractKTPData dari kode asli Anda di sini)
    // ... Pastikan fungsi-fungsi pendukungnya (_extractNIK, _extractNama, dll) juga disertakan.

    // --- REPLIKA KODE ASLI ANDA UNTUK KONTEKS (Disederhanakan agar muat) ---
    final allLines = text.split('\n');
    final lines = allLines.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    Map<String, dynamic> extractedData = {
      'nik': null, 'nama': null, 'tempat_lahir': null, 'tanggal_lahir': null,
      'jenis_kelamin': null, 'alamat': null, 'rt_rw': null, 'kelurahan': null,
      'kecamatan': null, 'agama': null, 'status_perkawinan': null, 'pekerjaan': null,
    };

    // Panggil fungsi ekstraksi KTP Anda yang original
    _extractNIK(text, lines, extractedData);
    _extractNama(lines, extractedData);
    _extractJenisKelamin(lines, extractedData);
    _extractTempotTanggalLahir(lines, extractedData);
    _extractAlamat(lines, extractedData);
    _extractAdditionalFields(lines, extractedData);

    return OCRResult(
      nik: extractedData['nik'],
      nama: extractedData['nama'],
      tempatLahir: extractedData['tempat_lahir'],
      tanggalLahir: extractedData['tanggal_lahir'],
      alamat: extractedData['alamat'],
      additionalFields: {
        // Masukkan field tambahan KTP lainnya di sini seperti di kode asli Anda
        if (extractedData['jenis_kelamin'] != null) 'jenis_kelamin': extractedData['jenis_kelamin'],
        if (extractedData['rt_rw'] != null) 'rt_rw': extractedData['rt_rw'],
        // dll...
      },
    );
  }

  // --- PERBAIKAN KECIL PADA FUNGSI PENDUKUNG KTP ANDA ---

  // Saat ekstraksi Nama KTP, tambahkan blacklist agar tidak mengambil nama Kota/Provinsi di header
  // Update pada fungsi _isValidName di kode asli Anda:
  bool _isValidNameUpdated(String text) {
    if (text.isEmpty || text.length < 3) return false;
    final upper = text.toUpperCase();
    // Blacklist keywords yang diperluas
    final blacklist = [
      'NAMA', 'NIK', 'TEMPAT', 'LAHIR', 'ALAMAT', 'AGAMA', 'PEKERJAAN',
      'STATUS', 'PROVINSI', 'KABUPATEN', 'KOTA', 'INDONESIA', 'REPUBLIK', 'JAKARTA', 'JAWA', // Tambahkan nama wilayah umum
      'KTP', 'BERLAKU', 'HINGGA', 'JENIS', 'KELAMIN', 'GOL', 'DARAH',
      'KECAMATAN', 'DESA', 'KELURAHAN', 'RT', 'RW', 'KEWARGANEGARAAN',
      'LAKI-LAKI', 'PEREMPUAN', 'KAWIN', 'BELUM'
    ];
    for (final word in blacklist) {
      if (upper.contains(word) && text.split(' ').length < 2) return false; // Jika hanya 1 kata dan ada di blacklist, tolak.
    }
    if (RegExp(r'^\d').hasMatch(text)) return false;
    if (!RegExp(r'[A-Za-z]{3,}').hasMatch(text)) return false;
    return true;
  }

  // --- FUNGSI UTILITAS ---

  /// Helper fallback terakhir untuk mencari 16 digit
  String? _findAny16DigitNumber(String text) {
    final allNumbers = RegExp(r'\b\d{16}\b').allMatches(text);
    if (allNumbers.isNotEmpty) {
      // Ambil yang pertama ditemukan
      return allNumbers.first.group(0);
    }
    return null;
  }


  // ==========================================================================
  // FUNGSI EKSTRAKSI KTP - INDONESIAN OPTIMIZED
  // ==========================================================================

  /// Extract NIK with multiple aggressive strategies and validation
  void _extractNIK(String fullText, List<String> lines, Map<String, dynamic> data) {
    if (kDebugMode) print('🔍 Extracting NIK...');

    List<String> nikCandidates = [];

    // Strategy 1: Look for "NIK" label
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toUpperCase();
      if (line.contains('NIK') && !line.contains('PEMILIK') && !line.contains('ELEKTRONIK')) {
        final colonMatch = RegExp(r':\s*(\d{16})').firstMatch(lines[i]);
        if (colonMatch != null) {
          nikCandidates.add(colonMatch.group(1)!);
        }
        for (int j = i + 1; j < i + 3 && j < lines.length; j++) {
          final nextNik = RegExp(r'\b\d{16}\b').firstMatch(lines[j]);
          if (nextNik != null) nikCandidates.add(nextNik.group(0)!);
        }
      }
    }

    // Strategy 2: Find ALL 16 digits
    final allMatches = RegExp(r'\b\d{16}\b').allMatches(fullText);
    for (final match in allMatches) {
      nikCandidates.add(match.group(0)!);
    }

    // Strategy 3: Spaced format
    final spacedMatch = RegExp(r'(\d{4})[\s\-](\d{4})[\s\-](\d{4})[\s\-](\d{4})').firstMatch(fullText);
    if (spacedMatch != null) {
      nikCandidates.add('${spacedMatch.group(1)}${spacedMatch.group(2)}${spacedMatch.group(3)}${spacedMatch.group(4)}');
    }

    if (nikCandidates.isNotEmpty) {
      final bestNik = _selectBestNIK(nikCandidates);
      if (bestNik != null) {
        data['nik'] = bestNik;
        if (kDebugMode) print('✅ NIK: ${data['nik']}');
        return;
      }
    }

    if (kDebugMode) print('❌ NIK NOT FOUND');
  }

  /// Select best NIK with Indonesian validation
  String? _selectBestNIK(List<String> candidates) {
    if (candidates.isEmpty) return null;
    final unique = candidates.toSet().toList();
    Map<String, int> scores = {};

    for (final nik in unique) {
      if (nik.length != 16) continue;
      int score = 0;

      // Province code (11-94)
      final provinceCode = int.tryParse(nik.substring(0, 2));
      if (provinceCode != null && provinceCode >= 11 && provinceCode <= 94) score += 10;

      // Valid date
      final day = int.tryParse(nik.substring(6, 8));
      final month = int.tryParse(nik.substring(8, 10));
      if (day != null && month != null) {
        final actualDay = day > 40 ? day - 40 : day;
        if (actualDay >= 1 && actualDay <= 31 && month >= 1 && month <= 12) score += 15;
      }

      // Last 4 digits check
      final lastDigits = int.tryParse(nik.substring(12, 16));
      if (lastDigits != null && lastDigits > 0) score += 10;

      // Not all same digits
      if (!RegExp(r'^(\d)\1{15}$').hasMatch(nik)) score += 5;

      scores[nik] = score;
    }

    if (scores.isNotEmpty) {
      final sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      if (sorted.first.value >= 30) return sorted.first.key;
    }

    return unique.first;
  }

  /// Extract Nama
  void _extractNama(List<String> lines, Map<String, dynamic> data) {
    if (kDebugMode) print('🔍 Extracting Nama...');

    int nikLineIndex = -1;
    if (data['nik'] != null) {
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains(data['nik'])) {
          nikLineIndex = i;
          break;
        }
      }
    }

    // After NAMA keyword
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toUpperCase().contains('NAMA') && !lines[i].toUpperCase().contains('PEMILIK')) {
        if (lines[i].contains(':')) {
          final parts = lines[i].split(':');
          if (parts.length > 1 && _isValidNameUpdated(parts[1].trim())) {
            data['nama'] = parts[1].trim();
            if (kDebugMode) print('✅ Nama: ${data['nama']}');
            return;
          }
        }
        for (int j = i + 1; j < i + 3 && j < lines.length; j++) {
          if (_isValidNameUpdated(lines[j])) {
            data['nama'] = lines[j];
            if (kDebugMode) print('✅ Nama: ${data['nama']}');
            return;
          }
        }
      }
    }

    // After NIK
    if (nikLineIndex >= 0 && nikLineIndex + 1 < lines.length) {
      if (_isValidNameUpdated(lines[nikLineIndex + 1])) {
        data['nama'] = lines[nikLineIndex + 1];
        if (kDebugMode) print('✅ Nama (after NIK): ${data['nama']}');
        return;
      }
    }

    if (kDebugMode) print('❌ Nama NOT FOUND');
  }

  /// Extract Jenis Kelamin
  void _extractJenisKelamin(List<String> lines, Map<String, dynamic> data) {
    if (kDebugMode) print('🔍 Extracting Jenis Kelamin...');

    for (int i = 0; i < lines.length; i++) {
      final upper = lines[i].toUpperCase();
      if (upper.contains('JENIS') && upper.contains('KELAMIN')) {
        if (lines[i].contains(':')) {
          final value = lines[i].split(':')[1].trim().toUpperCase();
          if (value == 'LAKI-LAKI' || value == 'PEREMPUAN' || value == 'L' || value == 'P') {
            data['jenis_kelamin'] = value;
            if (kDebugMode) print('✅ Jenis Kelamin: ${data['jenis_kelamin']}');
            return;
          }
        }
        if (i + 1 < lines.length) {
          final next = lines[i + 1].trim().toUpperCase();
          if (next == 'LAKI-LAKI' || next == 'PEREMPUAN' || next == 'L' || next == 'P') {
            data['jenis_kelamin'] = next;
            if (kDebugMode) print('✅ Jenis Kelamin: ${data['jenis_kelamin']}');
            return;
          }
        }
      }
    }
  }

  /// Extract Tempat/Tanggal Lahir
  void _extractTempotTanggalLahir(List<String> lines, Map<String, dynamic> data) {
    if (kDebugMode) print('🔍 Extracting Tempat/Tanggal Lahir...');

    for (int i = 0; i < lines.length; i++) {
      final upper = lines[i].toUpperCase();
      if (upper.contains('JENIS') && upper.contains('KELAMIN')) continue;

      if (upper.contains('TEMPAT') || upper.contains('LAHIR') || upper.contains('TTL')) {
        if (lines[i].contains(':')) {
          final birthData = lines[i].split(':')[1].trim();
          if (!_isGender(birthData)) {
            _parseBirthInfo(birthData, data);
            if (data['tempat_lahir'] != null || data['tanggal_lahir'] != null) {
              if (kDebugMode) print('✅ Birth data found');
              if (data['tempat_lahir'] != null && data['tanggal_lahir'] != null) return;
            }
          }
        }

        for (int j = i + 1; j < i + 3 && j < lines.length; j++) {
          final line = lines[j].trim();
          if (_isGender(line) || line.length <= 2) continue;
          _parseBirthInfo(line, data);
          if (data['tempat_lahir'] != null && data['tanggal_lahir'] != null) return;
        }
      }
    }

    // Fallback date search
    if (data['tanggal_lahir'] == null) {
      for (final line in lines) {
        final dateMatch = RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](19\d{2}|20\d{2})').firstMatch(line);
        if (dateMatch != null) {
          data['tanggal_lahir'] = '${dateMatch.group(1)}-${dateMatch.group(2)}-${dateMatch.group(3)}';
          if (kDebugMode) print('⚠️ Tanggal Lahir (fallback): ${data['tanggal_lahir']}');
          break;
        }
      }
    }
  }

  /// Parse birth info
  void _parseBirthInfo(String text, Map<String, dynamic> data) {
    if (text.contains(',')) {
      final parts = text.split(',');
      final tempat = parts[0].trim();
      if (tempat.isNotEmpty && !_isGender(tempat)) {
        data['tempat_lahir'] = tempat;
      }
      if (parts.length > 1) {
        final dateMatch = RegExp(r'(\d{1,2})[-/\s](\d{1,2})[-/\s](19\d{2}|20\d{2})').firstMatch(parts[1]);
        if (dateMatch != null) {
          data['tanggal_lahir'] = '${dateMatch.group(1)}-${dateMatch.group(2)}-${dateMatch.group(3)}';
        }
      }
      return;
    }

    final datePattern = RegExp(r'(\d{1,2})[-/\s](\d{1,2})[-/\s](19\d{2}|20\d{2})');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      final tempat = text.substring(0, match.start).trim();
      if (tempat.isNotEmpty && !_isGender(tempat)) {
        data['tempat_lahir'] = tempat;
      }
      data['tanggal_lahir'] = '${match.group(1)}-${match.group(2)}-${match.group(3)}';
      return;
    }

    if (!text.toUpperCase().contains('KELAMIN') && text.length > 2 && !_isGender(text)) {
      data['tempat_lahir'] = text;
    }
  }

  /// Extract Alamat
  void _extractAlamat(List<String> lines, Map<String, dynamic> data) {
    if (kDebugMode) print('🔍 Extracting Alamat...');

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toUpperCase().contains('ALAMAT')) {
        String alamat = '';
        if (lines[i].contains(':')) {
          alamat = lines[i].split(':')[1].trim();
        }

        for (int j = i + 1; j < i + 5 && j < lines.length; j++) {
          final line = lines[j].trim();
          final upper = line.toUpperCase();
          if (upper.contains('RT') || upper.contains('RW') || upper.contains('KEL') ||
              upper.contains('DESA') || upper.contains('KEC') || upper.contains('AGAMA')) break;
          if (line.length > 2) {
            alamat += (alamat.isEmpty ? '' : ' ') + line;
          }
        }

        if (alamat.isNotEmpty) {
          data['alamat'] = alamat;
          if (kDebugMode) print('✅ Alamat: ${data['alamat']}');
          return;
        }
      }
    }
  }

  /// Extract additional fields
  void _extractAdditionalFields(List<String> lines, Map<String, dynamic> data) {
    if (kDebugMode) print('🔍 Extracting Additional Fields...');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final upper = line.toUpperCase();

      // RT/RW
      if (upper.contains('RT') && upper.contains('RW') && data['rt_rw'] == null) {
        final rtRwPattern = RegExp(r'(\d{3})/(\d{3})');
        final match = rtRwPattern.firstMatch(line);
        if (match != null) {
          data['rt_rw'] = match.group(0);
        } else {
          final flexMatch = RegExp(r'(\d{1,3})/(\d{1,3})').firstMatch(line);
          if (flexMatch != null) {
            final rt = flexMatch.group(1)!.padLeft(3, '0');
            final rw = flexMatch.group(2)!.padLeft(3, '0');
            data['rt_rw'] = '$rt/$rw';
          }
        }
        if (data['rt_rw'] != null && kDebugMode) print('✅ RT/RW: ${data['rt_rw']}');
      }

      // Kelurahan
      if (data['kelurahan'] == null) {
        if ((upper.contains('KEL/DESA') || (upper.contains('KEL') && upper.contains('DESA'))) &&
            !upper.contains('KELAMIN')) {
          data['kelurahan'] = _extractValue(line, lines, i);
          if (kDebugMode) print('✅ Kelurahan: ${data['kelurahan']}');
        }
      }

      // Kecamatan
      if ((upper.contains('KECAMATAN') || upper.startsWith('KEC')) && data['kecamatan'] == null) {
        data['kecamatan'] = _extractValue(line, lines, i);
        if (kDebugMode) print('✅ Kecamatan: ${data['kecamatan']}');
      }

      // Agama
      if (upper.contains('AGAMA') && data['agama'] == null) {
        final value = _extractValue(line, lines, i);
        if (value != null) {
          final validated = _validateAgama(value);
          if (validated != null) {
            data['agama'] = validated;
            if (kDebugMode) print('✅ Agama: ${data['agama']}');
          }
        }
      }

      // Status Perkawinan
      if (upper.contains('STATUS') && upper.contains('KAWIN') && data['status_perkawinan'] == null) {
        final value = _extractValue(line, lines, i);
        if (value != null) {
          final upperValue = value.toUpperCase();
          if (upperValue.contains('KAWIN') || upperValue.contains('BELUM') ||
              upperValue.contains('CERAI')) {
            data['status_perkawinan'] = value;
            if (kDebugMode) print('✅ Status Perkawinan: ${data['status_perkawinan']}');
          }
        }
      }

      // Pekerjaan
      if (upper.contains('PEKERJAAN') && data['pekerjaan'] == null) {
        data['pekerjaan'] = _extractValue(line, lines, i);
        if (kDebugMode) print('✅ Pekerjaan: ${data['pekerjaan']}');
      }
    }
  }

  /// Validate Indonesian religion
  String? _validateAgama(String value) {
    final upper = value.toUpperCase().trim();
    if (upper.contains('ISLAM')) return 'ISLAM';
    if (upper.contains('KRISTEN') && !upper.contains('KATOLIK')) return 'KRISTEN';
    if (upper.contains('KATOLIK')) return 'KATOLIK';
    if (upper.contains('HINDU')) return 'HINDU';
    if (upper.contains('BUDDHA') || upper.contains('BUDHA')) return 'BUDDHA';
    if (upper.contains('KONG')) return 'KONG HU CHU';
    return null;
  }

  /// Check if gender
  bool _isGender(String text) {
    final upper = text.trim().toUpperCase();
    return upper == 'LAKI-LAKI' || upper == 'PEREMPUAN' || upper == 'L' || upper == 'P';
  }

  /// Extract value from line
  String? _extractValue(String line, List<String> lines, int currentIndex) {
    if (line.contains(':')) {
      final parts = line.split(':');
      if (parts.length > 1) {
        final value = parts[1].trim();
        if (value.isNotEmpty) return value;
      }
    }
    if (currentIndex + 1 < lines.length) {
      final nextLine = lines[currentIndex + 1].trim();
      if (nextLine.isNotEmpty && nextLine.length > 1) return nextLine;
    }
    return null;
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
