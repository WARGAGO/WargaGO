import 'package:jawara/core/models/OCR/ocr_response.dart';

class KTPModel {
  final String? nik;
  final String? nama;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? alamat;
  final String? jenisKelamin;
  final String? agama;
  final String? pekerjaan;
  final String? statusPerkawinan;
  final String? kewarganegaraan;

  KTPModel({
    this.nik,
    this.nama,
    this.tempatLahir,
    this.tanggalLahir,
    this.alamat,
    this.jenisKelamin,
    this.agama,
    this.pekerjaan,
    this.statusPerkawinan,
    this.kewarganegaraan,
  });

  factory KTPModel.fromMap(Map<String, dynamic> map) {
    return KTPModel(
      nik: map['nik'],
      nama: map['nama'],
      tempatLahir: map['tempatLahir'],
      tanggalLahir: map['tanggalLahir'],
      alamat: map['alamat'],
      jenisKelamin: map['jenisKelamin'],
      agama: map['agama'],
      pekerjaan: map['pekerjaan'],
      statusPerkawinan: map['statusPerkawinan'],
      kewarganegaraan: map['kewarganegaraan'],
    );
  }

  factory KTPModel.fromOCR(List<OcrResult> ocrResults) {
    String? nik;
    String? nama;
    String? tempatLahir;
    String? tanggalLahir;
    String? alamat;
    String? jenisKelamin;
    String? agama;
    String? pekerjaan;
    String? statusPerkawinan;
    String? kewarganegaraan;

    // Helper function to find value based on bbox proximity
    String? findValueByBbox(OcrResult label, List<OcrResult> results) {
      final textLabel = label.text.toUpperCase();
      if (textLabel.contains(':')) {
        final parts = textLabel.split(':');
        if (parts.last.length > 2) {
          return parts.last.trim();
        }
      }

      final labelY = label.bbox[0][1]; // Y coordinate of label
      final labelRightX = label.bbox[1][0]; // Right X coordinate of label

      // Look for text on the same line (similar Y coordinate) and to the right
      for (var result in results) {
        if (result == label) continue;

        final resultY = result.bbox[0][1];
        final resultX = result.bbox[0][0];

        // Check if on same line (Y coordinate difference < 20 pixels)
        // and to the right of the label
        if ((resultY - labelY).abs() < 20 && resultX > labelRightX) {
          return result.text.replaceAll(':', '').trim();
        }
      }
      return null;
    }

    for (var result in ocrResults) {
      final text = result.text.toUpperCase();

      if (text == 'NIK') {
        nik = findValueByBbox(result, ocrResults);
      } else if (text == 'NAMA') {
        nama = findValueByBbox(result, ocrResults);
      } else if (text.contains('TEMPATTGL') || text.contains('TEMPAT')) {
        final birthData = findValueByBbox(result, ocrResults);
        if (birthData != null) {
          final parts = birthData.split('.');
          if (parts.length == 2) {
            tempatLahir = parts[0].trim();
            tanggalLahir = parts[1].trim();
          } else if (parts.length == 1) {
            // Handle formats like "BOGOR, 30-10-2002" or "BOGOR 30-10-2002"
            final spaceOrComma = birthData.split(RegExp(r'[,\s]+'));
            if (spaceOrComma.length >= 2) {
              tempatLahir = spaceOrComma[0].trim();
              tanggalLahir = spaceOrComma.sublist(1).join(' ').trim();
            }
          }
        }
      } else if (text == 'ALAMAT') {
        alamat = findValueByBbox(result, ocrResults);
      } else if (text.contains('KELAMIN') || text.contains('JENIS KELAMIN')) {
        jenisKelamin = findValueByBbox(result, ocrResults);
      } else if (text.contains('AGAMA')) {
        agama = findValueByBbox(result, ocrResults);
      } else if (text.contains('PEKERJAAN')) {
        pekerjaan = findValueByBbox(result, ocrResults);
      } else if (text.contains('STATUS PERKAWINAN') ||
          text.contains('PERKAWINAN')) {
        statusPerkawinan = findValueByBbox(result, ocrResults);
      } else if (text.contains('KEWARGANEGARAAN')) {
        kewarganegaraan = findValueByBbox(result, ocrResults);
      }
    }

    return KTPModel(
      nik: nik,
      nama: nama,
      tempatLahir: tempatLahir,
      tanggalLahir: tanggalLahir,
      alamat: alamat,
      jenisKelamin: jenisKelamin,
      agama: agama,
      pekerjaan: pekerjaan,
      statusPerkawinan: statusPerkawinan,
      kewarganegaraan: kewarganegaraan,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nik': nik,
      'nama': nama,
      'tempatLahir': tempatLahir,
      'tanggalLahir': tanggalLahir,
      'alamat': alamat,
      'jenisKelamin': jenisKelamin,
      'agama': agama,
      'pekerjaan': pekerjaan,
      'statusPerkawinan': statusPerkawinan,
      'kewarganegaraan': kewarganegaraan,
    };
  }
}
