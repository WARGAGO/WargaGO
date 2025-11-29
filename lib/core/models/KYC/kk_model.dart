import 'package:jawara/core/models/KYC/ktp_model.dart';
import 'package:jawara/core/models/OCR/ocr_response.dart';

class KKMember extends KTPModel {
  String? pendidikan;
  String? statusKeluarga;
  String? noPaspor;
  String? noKitap;
  String? ayah;
  String? ibu;

  KKMember({
    super.nik,
    super.nama,
    super.tempatLahir,
    super.tanggalLahir,
    super.jenisKelamin,
    super.agama,
    super.pekerjaan,
    super.statusPerkawinan,
    super.kewarganegaraan,
    this.pendidikan,
    this.statusKeluarga,
    this.noPaspor,
    this.noKitap,
    this.ayah,
    this.ibu,
  });

  factory KKMember.fromMap(Map<String, dynamic> map) {
    return KKMember(
      nik: map['nik'],
      nama: map['nama'],
      tempatLahir: map['tempatLahir'],
      tanggalLahir: map['tanggalLahir'],
      jenisKelamin: map['jenisKelamin'],
      agama: map['agama'],
      pekerjaan: map['pekerjaan'],
      statusPerkawinan: map['statusPerkawinan'],
      kewarganegaraan: map['kewarganegaraan'],
      pendidikan: map['pendidikan'],
      statusKeluarga: map['statusKeluarga'],
      noPaspor: map['noPaspor'],
      noKitap: map['noKitap'],
      ayah: map['ayah'],
      ibu: map['ibu'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'nik': nik,
      'nama': nama,
      'tempatLahir': tempatLahir,
      'tanggalLahir': tanggalLahir,
      'jenisKelamin': jenisKelamin,
      'agama': agama,
      'pekerjaan': pekerjaan,
      'statusPerkawinan': statusPerkawinan,
      'kewarganegaraan': kewarganegaraan,
      'pendidikan': pendidikan,
      'statusKeluarga': statusKeluarga,
      'noPaspor': noPaspor,
      'noKitap': noKitap,
      'ayah': ayah,
      'ibu': ibu,
    };
  }
}

class KKModel {
  final String? no;
  final List<KKMember> members;

  KKModel({this.no, required this.members});

  factory KKModel.fromMap(Map<String, dynamic> map) {
    return KKModel(
      no: map['no'],
      members:
          (map['members'] as List<dynamic>?)
              ?.map(
                (memberMap) =>
                    KKMember.fromMap(memberMap as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  factory KKModel.fromOCR(
    List<OcrResult> ocrResults, {
    bool skipMmebers = true,
  }) {
    String? no;
    List<KKMember> members = [];

    // Helper function to find value based on bbox proximity
    String? findValueByBbox(
      OcrResult label,
      List<OcrResult> results, {
      bool preferBelow = false,
    }) {
      final labelY = label.bbox[0][1]; // Y coordinate of label
      final labelRightX = label.bbox[1][0]; // Right X coordinate of label
      final labelBottomY = label.bbox[2][1]; // Bottom Y coordinate of label

      OcrResult? bestMatch;
      double bestDistance = double.infinity;

      for (var result in results) {
        if (result == label) continue;

        final resultY = result.bbox[0][1];
        final resultX = result.bbox[0][0];

        if (preferBelow) {
          // Look for text below the label (for table headers)
          final verticalDistance = resultY - labelBottomY;
          if (verticalDistance > 0 && verticalDistance < 500) {
            // Within 500 pixels below
            final horizontalDistance = (resultX - label.bbox[0][0]).abs();
            final totalDistance = verticalDistance + horizontalDistance * 0.5;

            if (totalDistance < bestDistance) {
              bestDistance = totalDistance;
              bestMatch = result;
            }
          }
        } else {
          // Look for text on the same line and to the right
          if ((resultY - labelY).abs() < 20 && resultX > labelRightX) {
            final distance = resultX - labelRightX;
            if (distance < bestDistance) {
              bestDistance = distance;
              bestMatch = result;
            }
          }
        }
      }
      return bestMatch?.text;
    }

    // Extract KK number - look for number after "KARTU KELUARGA" or starting with "No."
    for (var result in ocrResults) {
      final text = result.text.toUpperCase();
      if (text.startsWith('NO.') ||
          (text.contains('NO') &&
              (text.contains('KK') ||
                  text.contains('KARTU') ||
                  text.contains('KELUARGA')))) {
        // Try to extract number from the text itself
        final match = RegExp(r'NO\.?\s*(\d+)').firstMatch(text);
        if (match != null) {
          no = match.group(1);
        } else {
          // Look for number on the same line or below
          no = findValueByBbox(result, ocrResults);
        }
        if (no != null) break;
      }
      // Also check for standalone numbers that look like KK numbers (16 digits)
      if (RegExp(r'^\d{16}$').hasMatch(text) && no == null) {
        no = text;
      }
    }

    // Extract family members from table structure
    // First, identify table headers and their positions - separated by table
    Map<String, OcrResult> topTableHeaders = {};
    Map<String, OcrResult> bottomTableHeaders = {};

    if (!skipMmebers) {
      for (var result in ocrResults) {
        final text = result.text.toUpperCase().replaceAll(RegExp(r'\s+'), '');

        // Top table headers - be more flexible with matching
        if (text.contains('NAMA') &&
            (text.contains('LENGKAP') || text.contains('(1)'))) {
          topTableHeaders['nama'] = result;
        } else if ((text.contains('NIK') || text.contains('(2)')) &&
            !text.contains('NAMA')) {
          topTableHeaders['nik'] = result;
        } else if ((text.contains('JENIS') && text.contains('KELAMIN')) ||
            text.contains('(3)')) {
          topTableHeaders['jenisKelamin'] = result;
        } else if ((text.contains('TEMPAT') && text.contains('LAHIR')) ||
            text.contains('(4)')) {
          topTableHeaders['tempatLahir'] = result;
        } else if ((text.contains('TANGGAL') && text.contains('LAHIR')) ||
            text.contains('(5)')) {
          topTableHeaders['tanggalLahir'] = result;
        } else if ((text == 'AGAMA' || text.contains('(6)')) &&
            !text.contains('NAMA')) {
          topTableHeaders['agama'] = result;
        } else if (text.contains('PENDIDIKAN') || text.contains('(7)')) {
          topTableHeaders['pendidikan'] = result;
        } else if ((text.contains('JENIS') && text.contains('PEKERJAAN')) ||
            (text.contains('PEKERJAAN') && text.contains('(8)'))) {
          topTableHeaders['pekerjaan'] = result;
        }
        // Bottom table headers
        else if ((text.contains('STATUS') && text.contains('PERKAWINAN')) ||
            text.contains('(9)')) {
          bottomTableHeaders['statusPerkawinan'] = result;
        } else if ((text.contains('STATUS') && text.contains('HUBUNGAN')) ||
            text.contains('DALAMKELUARGA') ||
            text.contains('(10)')) {
          bottomTableHeaders['statusKeluarga'] = result;
        } else if (text.contains('KEWARGANEGARAAN') || text.contains('(11)')) {
          bottomTableHeaders['kewarganegaraan'] = result;
        } else if ((text.contains('PASPOR') && !text.contains('NO.PASPOR')) ||
            text.contains('(12)')) {
          bottomTableHeaders['noPaspor'] = result;
        } else if (text.contains('KITAP') || text.contains('(13)')) {
          bottomTableHeaders['noKitap'] = result;
        } else if ((text.contains('AYAH') || text.contains('(14)')) &&
            !text.contains('IBU')) {
          bottomTableHeaders['ayah'] = result;
        } else if (text.contains('IBU') || text.contains('(15)')) {
          bottomTableHeaders['ibu'] = result;
        }
      }

      // Determine Y threshold to separate top and bottom tables
      double tableYThreshold = 400; // Default threshold
      if (topTableHeaders.isNotEmpty && bottomTableHeaders.isNotEmpty) {
        final topMaxY = topTableHeaders.values
            .map((h) => h.bbox[2][1])
            .reduce((a, b) => a > b ? a : b);
        final bottomMinY = bottomTableHeaders.values
            .map((h) => h.bbox[0][1])
            .reduce((a, b) => a < b ? a : b);
        tableYThreshold = (topMaxY + bottomMinY) / 2;
      } else if (topTableHeaders.isNotEmpty) {
        // If no bottom table headers found, use top table bottom + some offset
        final topMaxY = topTableHeaders.values
            .map((h) => h.bbox[2][1])
            .reduce((a, b) => a > b ? a : b);
        tableYThreshold = topMaxY + 200; // Offset after top table
      }

      // Create a list of all header results for filtering
      List<OcrResult> allHeaders = [
        ...topTableHeaders.values,
        ...bottomTableHeaders.values,
      ];

      // Separate rows into top table and bottom table
      Map<int, List<OcrResult>> topTableRows = {};
      Map<int, List<OcrResult>> bottomTableRows = {};

      for (var result in ocrResults) {
        // Skip if this is a header, the KK number, or other header text
        final upperText = result.text.toUpperCase();
        if (allHeaders.contains(result) ||
            result.text == no ||
            upperText.contains('KARTU') ||
            upperText.contains('KELUARGA') ||
            upperText.contains('NAMA KEPALA') ||
            upperText.contains('RT/RW') ||
            upperText.contains('KODE POS') ||
            upperText.contains('DESA') ||
            upperText.contains('KECAMATAN') ||
            upperText.contains('KABUPATEN') ||
            upperText.contains('PROVINSI') ||
            upperText.contains('DIKELUARKAN') ||
            upperText.contains('LEMBAR') ||
            upperText.contains('KEPALA DINAS')) {
          continue;
        }

        final y = result.bbox[0][1];
        final x = result.bbox[0][0];

        // Determine if this belongs to top or bottom table based on Y threshold
        if (y < tableYThreshold && topTableHeaders.isNotEmpty) {
          // Check if X coordinate is within the range of top table headers
          final minHeaderX = topTableHeaders.values
              .map((h) => h.bbox[0][0])
              .reduce((a, b) => a < b ? a : b);
          final maxHeaderX = topTableHeaders.values
              .map((h) => h.bbox[1][0])
              .reduce((a, b) => a > b ? a : b);

          // Only include if within horizontal bounds of the table (with tolerance)
          if (x >= minHeaderX - 500 && x <= maxHeaderX + 500) {
            final rowKey = (y / 30).round(); // Slightly larger tolerance
            topTableRows[rowKey] = topTableRows[rowKey] ?? [];
            topTableRows[rowKey]!.add(result);
          }
        } else if (y >= tableYThreshold && bottomTableHeaders.isNotEmpty) {
          // Check if X coordinate is within the range of bottom table headers
          final minHeaderX = bottomTableHeaders.values
              .map((h) => h.bbox[0][0])
              .reduce((a, b) => a < b ? a : b);
          final maxHeaderX = bottomTableHeaders.values
              .map((h) => h.bbox[1][0])
              .reduce((a, b) => a > b ? a : b);

          // Only include if within horizontal bounds of the table (with tolerance)
          if (x >= minHeaderX - 500 && x <= maxHeaderX + 500) {
            final rowKey = (y / 30).round(); // Slightly larger tolerance
            bottomTableRows[rowKey] = bottomTableRows[rowKey] ?? [];
            bottomTableRows[rowKey]!.add(result);
          }
        }
      } // Sort rows by Y coordinate
      final sortedTopRowKeys = topTableRows.keys.toList()..sort();
      final sortedBottomRowKeys = bottomTableRows.keys.toList()..sort();

      // Helper to find closest header by X position
      String? findHeaderKey(double x, Map<String, OcrResult> headers) {
        String? bestKey;
        double minDistance = double.infinity;

        for (var entry in headers.entries) {
          final headerX = entry.value.bbox[0][0];
          final distance = (x - headerX).abs();
          if (distance < minDistance && distance < 150) {
            // Within 150 pixels
            minDistance = distance;
            bestKey = entry.key;
          }
        }
        return bestKey;
      }

      // Track members by row number from top table
      Map<int, Map<String, dynamic>> membersByRow = {};

      // Process top table
      for (var rowKey in sortedTopRowKeys) {
        final rowResults = topTableRows[rowKey]!;
        if (rowResults.isEmpty) continue;

        // Sort by X coordinate to read left to right
        rowResults.sort((a, b) => a.bbox[0][0].compareTo(b.bbox[0][0]));

        // Limit to max 10 cells per row (excluding row number)
        final limitedResults = rowResults.take(11).toList();

        // Try to find row number (first element, usually 1-10)
        int? rowNumber;
        for (var result in limitedResults) {
          if (RegExp(r'^\d{1,2}$').hasMatch(result.text)) {
            rowNumber = int.tryParse(result.text);
            break;
          }
        }

        if (rowNumber == null) continue;

        // Process each cell in the row
        for (var result in limitedResults) {
          final text = result.text.trim();
          if (text.isEmpty || text == '-') continue;

          // Skip row numbers
          if (RegExp(r'^\d{1,2}$').hasMatch(text) && text.length <= 2) continue;

          final resultX = result.bbox[0][0];
          final headerKey = findHeaderKey(resultX, topTableHeaders);

          if (headerKey != null) {
            membersByRow[rowNumber] = membersByRow[rowNumber] ?? {};
            membersByRow[rowNumber]![headerKey] = text;
          }
        }
      }

      // Process bottom table
      for (var rowKey in sortedBottomRowKeys) {
        final rowResults = bottomTableRows[rowKey]!;
        if (rowResults.isEmpty) continue;

        // Sort by X coordinate to read left to right
        rowResults.sort((a, b) => a.bbox[0][0].compareTo(b.bbox[0][0]));

        // Limit to max 10 cells per row (excluding row number)
        final limitedResults = rowResults.take(11).toList();

        // Try to find row number (first element, usually 1-10)
        int? rowNumber;
        for (var result in limitedResults) {
          if (RegExp(r'^\d{1,2}$').hasMatch(result.text)) {
            rowNumber = int.tryParse(result.text);
            break;
          }
        }

        if (rowNumber == null) continue;

        // Process each cell in the row
        for (var result in limitedResults) {
          final text = result.text.trim();
          if (text.isEmpty || text == '-') continue;

          // Skip row numbers
          if (RegExp(r'^\d{1,2}$').hasMatch(text) && text.length <= 2) continue;

          final resultX = result.bbox[0][0];
          final headerKey = findHeaderKey(resultX, bottomTableHeaders);

          if (headerKey != null) {
            membersByRow[rowNumber] = membersByRow[rowNumber] ?? {};
            membersByRow[rowNumber]![headerKey] = text;
          }
        }
      }

      // Convert member data to KKMember objects
      for (var memberData in membersByRow.values) {
        if (memberData.isEmpty) continue;

        // Parse tanggal lahir if it contains date format
        String? tanggalLahir = memberData['tanggalLahir'];
        if (tanggalLahir != null && tanggalLahir.contains('-')) {
          // Already in date format
        } else if (tanggalLahir != null) {
          // Might need parsing
          final match = RegExp(
            r'(\d{2})-(\d{2})-(\d{4})',
          ).firstMatch(tanggalLahir);
          if (match != null) {
            tanggalLahir =
                '${match.group(1)}-${match.group(2)}-${match.group(3)}';
          }
        }

        members.add(
          KKMember(
            nik: memberData['nik'],
            nama: memberData['nama'],
            tempatLahir: memberData['tempatLahir'],
            tanggalLahir: tanggalLahir,
            jenisKelamin: memberData['jenisKelamin'],
            agama: memberData['agama'],
            pekerjaan: memberData['pekerjaan'],
            statusPerkawinan: memberData['statusPerkawinan'],
            kewarganegaraan: memberData['kewarganegaraan'],
            pendidikan: memberData['pendidikan'],
            statusKeluarga: memberData['statusKeluarga'],
            noPaspor: memberData['noPaspor'],
            noKitap: memberData['noKitap'],
            ayah: memberData['ayah'],
            ibu: memberData['ibu'],
          ),
        );
      }
    }

    return KKModel(no: no, members: members);
  }

  Map<String, dynamic> toMap() => {
    'no': no,
    'members': members.map((member) => member.toMap()).toList(),
  };
}
