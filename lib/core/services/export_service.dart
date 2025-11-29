import 'dart:io';
import 'dart:async';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class ExportService {
  static final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final dateFormat = DateFormat('dd/MM/yyyy');

  /// Get Downloads directory for saving files (public access)
  static Future<Directory> _getExportDirectory() async {
    try {
      debugPrint('📁 Getting Downloads directory...');

      if (Platform.isAndroid) {
        // Use public Downloads directory - directly accessible by user
        final downloadsPath = '/storage/emulated/0/Download';
        final directory = Directory(downloadsPath);

        if (!await directory.exists()) {
          debugPrint('⚠️  Downloads directory not found, creating...');
          await directory.create(recursive: true);
        }

        debugPrint('✅ Downloads directory: ${directory.path}');
        return directory;
      } else {
        // For iOS/other platforms, use documents directory
        final directory = await getApplicationDocumentsDirectory();
        debugPrint('✅ Documents directory: ${directory.path}');
        return directory;
      }
    } catch (e) {
      debugPrint('⚠️  Error accessing Downloads: $e');
      debugPrint('   Falling back to app directory...');
      // Fallback to app documents directory
      final directory = await getApplicationDocumentsDirectory();
      debugPrint('✅ Fallback directory: ${directory.path}');
      return directory;
    }
  }

  /// Export to Excel
  static Future<File?> exportToExcel(List<Map<String, dynamic>> data, String filename) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 EXCEL EXPORT START');
      debugPrint('   📦 Items to export: ${data.length}');
      debugPrint('   📄 Filename: $filename');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // STEP 1: Get directory FIRST (with timeout)
      debugPrint('   1️⃣  Getting export directory...');
      Directory directory;
      try {
        directory = await _getExportDirectory();
        debugPrint('   ✅ Directory obtained: ${directory.path}');
      } catch (e) {
        debugPrint('   ❌ Failed to get directory: $e');
        return null;
      }

      // STEP 2: Create workbook
      debugPrint('   2️⃣  Creating workbook...');
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Laporan';
      debugPrint('   ✅ Workbook created');

      // STEP 3: Headers (minimal)
      debugPrint('   3️⃣  Adding headers...');
      final headers = ['No', 'Tanggal', 'Nama', 'Kategori', 'Nominal', 'Status'];
      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      }
      debugPrint('   ✅ Headers added');

      // STEP 4: Data rows (simplified)
      debugPrint('   4️⃣  Adding ${data.length} data rows...');
      double total = 0;
      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        final row = i + 2;
        final nominal = (item['nominal'] is num) ? (item['nominal'] as num).toDouble() : 0.0;
        total += nominal;

        sheet.getRangeByIndex(row, 1).setNumber(i + 1);
        sheet.getRangeByIndex(row, 2).setText(item['tanggal'] ?? '-');
        sheet.getRangeByIndex(row, 3).setText(item['name'] ?? '-');
        sheet.getRangeByIndex(row, 4).setText(item['category'] ?? '-');
        sheet.getRangeByIndex(row, 5).setText(currencyFormat.format(nominal));
        sheet.getRangeByIndex(row, 6).setText(item['status'] ?? '-');
      }
      debugPrint('   ✅ Data rows added');

      // STEP 5: Total row
      debugPrint('   5️⃣  Adding total...');
      final totalRow = data.length + 2;
      sheet.getRangeByIndex(totalRow, 4).setText('TOTAL:');
      sheet.getRangeByIndex(totalRow, 5).setText(currencyFormat.format(total));
      debugPrint('   ✅ Total: ${currencyFormat.format(total)}');

      // STEP 6: Save to bytes
      debugPrint('   6️⃣  Converting to bytes...');
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      debugPrint('   ✅ Converted to ${bytes.length} bytes');

      // STEP 7: Write file (with timeout)
      final path = '${directory.path}/$filename.xlsx';
      debugPrint('   7️⃣  Writing to: $path');
      try {
        final file = File(path);
        await file.writeAsBytes(bytes, flush: true).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('Timeout writing file');
          },
        );
        debugPrint('   ✅ File written: ${file.lengthSync()} bytes');

        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('✅ EXCEL EXPORT SUCCESS!');
        debugPrint('   📁 ${file.path}');
        debugPrint('   💰 Total: ${currencyFormat.format(total)}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        return file;
      } catch (e) {
        debugPrint('   ❌ Failed to write file: $e');
        return null;
      }

    } catch (e, stackTrace) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ EXCEL EXPORT FAILED');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return null;
    }
  }

  /// Export to PDF
  static Future<File?> exportToPDF(List<Map<String, dynamic>> data, String filename) async {
    try {
      final pdf = pw.Document();

      // Calculate total from nominal field (as number)
      double total = 0;
      int jenisIuranCount = 0;
      int pemasukanLainCount = 0;
      double totalJenisIuran = 0;
      double totalPemasukanLain = 0;

      for (var item in data) {
        final nominal = (item['nominal'] is num)
            ? (item['nominal'] as num).toDouble()
            : 0.0;
        total += nominal;

        // Count by category
        final category = item['category'] ?? '';
        if (category == 'Iuran') {
          jenisIuranCount++;
          totalJenisIuran += nominal;
        } else {
          pemasukanLainCount++;
          totalPemasukanLain += nominal;
        }
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📄 PDF Export Service - Data Verification:');
      debugPrint('   📦 Total items received: ${data.length}');
      debugPrint('   📊 Jenis Iuran: $jenisIuranCount items = ${currencyFormat.format(totalJenisIuran)}');
      debugPrint('   📊 Pemasukan Lain: $pemasukanLainCount items = ${currencyFormat.format(totalPemasukanLain)}');
      debugPrint('   💰 TOTAL CALCULATED: ${currencyFormat.format(total)}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Title
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN PEMASUKAN',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Tanggal Cetak: ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Table
              pw.Table.fromTextArray(
                headers: ['No', 'Tanggal', 'Nama', 'Kategori', 'Nominal', 'Status'],
                data: List.generate(data.length, (index) {
                  final item = data[index];
                  final nominal = (item['nominal'] is num)
                      ? (item['nominal'] as num).toDouble()
                      : 0.0;
                  return [
                    '${index + 1}',
                    item['tanggal'] ?? '-',
                    item['name'] ?? '-',
                    item['category'] ?? '-',
                    item['nominalFormatted'] ?? currencyFormat.format(nominal),
                    item['status'] ?? '-',
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
              ),

              pw.SizedBox(height: 20),

              // Total
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total Pemasukan:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(currencyFormat.format(total), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Save file
      final directory = await _getExportDirectory();
      final path = '${directory.path}/$filename.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      debugPrint('✅ PDF exported: $path');
      return file;
    } catch (e) {
      debugPrint('❌ Error exporting to PDF: $e');
      return null;
    }
  }

  /// Export to CSV
  static Future<File?> exportToCSV(List<Map<String, dynamic>> data, String filename) async {
    try {
      List<List<dynamic>> rows = [];

      // Header
      rows.add([
        'No',
        'Tanggal',
        'Nama',
        'Kategori',
        'Nominal',
        'Penerima',
        'Deskripsi',
        'Status',
      ]);

      // Data rows
      double total = 0;
      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        final nominal = (item['nominal'] is num)
            ? (item['nominal'] as num).toDouble()
            : 0.0;
        total += nominal;

        rows.add([
          i + 1,
          item['tanggal'] ?? '-',
          item['name'] ?? '-',
          item['category'] ?? '-',
          item['nominalFormatted'] ?? currencyFormat.format(nominal),
          item['penerima'] ?? '-',
          item['deskripsi'] ?? '-',
          item['status'] ?? '-',
        ]);
      }

      // Add total row
      rows.add([
        '',
        '',
        '',
        'TOTAL:',
        currencyFormat.format(total),
        '',
        '',
        '',
      ]);

      // Convert to CSV
      String csv = const ListToCsvConverter().convert(rows);

      // Save file
      final directory = await _getExportDirectory();
      final path = '${directory.path}/$filename.csv';
      final file = File(path);
      await file.writeAsString(csv);
      debugPrint('✅ CSV exported: $path with total: ${currencyFormat.format(total)}');
      return file;
    } catch (e) {
      debugPrint('❌ Error exporting to CSV: $e');
      return null;
    }
  }
}

