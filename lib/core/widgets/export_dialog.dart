import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import '../services/export_service.dart';

class ExportDialog {
  static void show({
    required BuildContext context,
    required List<Map<String, dynamic>> data,
    required String title,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2988EA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.file_download_outlined,
                  size: 48,
                  color: const Color(0xFF2988EA),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Pilih Format Export',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih format file untuk mengexport laporan',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              // Format buttons
              _buildFormatButton(
                context: context,
                icon: Icons.table_chart,
                label: 'Excel',
                description: 'File .xlsx untuk Microsoft Excel',
                color: const Color(0xFF10B981),
                onTap: () async {
                  Navigator.pop(context);
                  await _exportData(context, data, 'excel', title);
                },
              ),
              const SizedBox(height: 12),
              _buildFormatButton(
                context: context,
                icon: Icons.picture_as_pdf,
                label: 'PDF',
                description: 'File .pdf untuk viewing/printing',
                color: const Color(0xFFEF4444),
                onTap: () async {
                  Navigator.pop(context);
                  await _exportData(context, data, 'pdf', title);
                },
              ),
              const SizedBox(height: 12),
              _buildFormatButton(
                context: context,
                icon: Icons.text_snippet,
                label: 'CSV',
                description: 'File .csv untuk spreadsheet',
                color: const Color(0xFF8B5CF6),
                onTap: () async {
                  Navigator.pop(context);
                  await _exportData(context, data, 'csv', title);
                },
              ),
              const SizedBox(height: 20),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildFormatButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  static Future<void> _exportData(
    BuildContext context,
    List<Map<String, dynamic>> data,
    String format,
    String title,
  ) async {
    if (!context.mounted) return;

    bool success = false;
    File? resultFile;
    String? errorMessage;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Membuat file...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = '${title}_$timestamp';

      // Export with timeout (10 seconds max)
      switch (format) {
        case 'excel':
          resultFile = await ExportService.exportToExcel(data, filename).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              errorMessage = 'Timeout: Operasi terlalu lama';
              return null;
            },
          );
          break;
        case 'pdf':
          resultFile = await ExportService.exportToPDF(data, filename).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              errorMessage = 'Timeout: Operasi terlalu lama';
              return null;
            },
          );
          break;
        case 'csv':
          resultFile = await ExportService.exportToCSV(data, filename).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              errorMessage = 'Timeout: Operasi terlalu lama';
              return null;
            },
          );
          break;
      }

      success = resultFile != null;
    } catch (e) {
      errorMessage = e.toString();
      success = false;
      debugPrint('❌ Export error: $e');
    }

    // FORCE CLOSE LOADING DIALOG - NO MATTER WHAT
    if (context.mounted) {
      try {
        Navigator.of(context, rootNavigator: false).pop();
      } catch (e) {
        debugPrint('⚠️  Error closing dialog: $e');
      }
    }

    // Show result AFTER dialog closed
    if (!context.mounted) return;

    if (success && resultFile != null) {
      // Show success dialog
      _showSuccessDialog(context, resultFile, format.toUpperCase());
    } else {
      _showErrorSnackBar(context, errorMessage ?? 'Gagal membuat file');
    }
  }

  static void _showSuccessDialog(BuildContext context, File file, String format) {
    final fileName = path.basename(file.path);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'File Berhasil Didownload!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'File $format tersimpan di folder Downloads',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 16,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lokasi: ${file.path}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF9CA3AF),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                // Buka File Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final result = await OpenFile.open(file.path);
                        if (result.type != ResultType.done) {
                          if (context.mounted) {
                            _showErrorSnackBar(context, 'Tidak dapat membuka file. Gunakan File Manager.');
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          _showErrorSnackBar(context, 'Error: $e');
                        }
                      }
                    },
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(
                      'Buka',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2988EA),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Bagikan Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await Share.shareXFiles(
                          [XFile(file.path)],
                          subject: 'Laporan $format',
                          text: 'Berikut file laporan dalam format $format',
                        );
                      } catch (e) {
                        if (context.mounted) {
                          _showErrorSnackBar(context, 'Error: $e');
                        }
                      }
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(
                      'Bagikan',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2988EA),
                      side: const BorderSide(
                        color: Color(0xFF2988EA),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

