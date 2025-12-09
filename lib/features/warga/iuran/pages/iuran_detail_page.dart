// filepath: c:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025\lib\features\warga\iuran\pages\iuran_detail_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'bayar_iuran_simple_page.dart'; // ✅ Use original file (now with Azure)

class IuranDetailPage extends StatelessWidget {
  final String tagihanId; // ⭐ ADDED for payment
  final String namaIuran;
  final int jumlah;
  final String tanggal;
  final String status;
  final String? keterangan;

  const IuranDetailPage({
    super.key,
    required this.tagihanId, // ⭐ ADDED
    required this.namaIuran,
    required this.jumlah,
    required this.tanggal,
    required this.status,
    this.keterangan,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'Lunas':
        return const Color(0xFF10B981);
      case 'Terlambat':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFFBBF24);
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'Lunas':
        return Icons.check_circle_rounded;
      case 'Terlambat':
        return Icons.error_rounded;
      default:
        return Icons.pending_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
        title: Text(
          'Detail Iuran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getStatusColor(), width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(_getStatusIcon(), size: 50, color: _getStatusColor()),
                        const SizedBox(height: 12),
                        Text(
                          status,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Iuran',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('Nama Iuran', namaIuran),
                        _buildInfoRow('Jumlah', currencyFormat.format(jumlah)),
                        _buildInfoRow('Tanggal Jatuh Tempo', tanggal),
                        _buildInfoRow('Status', status),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Keterangan
                  if (keterangan != null && keterangan!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Keterangan',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            keterangan!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Button
          if (status != 'Lunas')
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Navigate ke halaman bayar dengan Azure Blob Storage
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BayarIuranSimplePage(
                          tagihanId: tagihanId, // ⭐ Pass tagihan ID
                          namaIuran: namaIuran,
                          nominal: jumlah.toDouble(),
                          tanggal: tanggal,
                        ),
                      ),
                    );

                    // Refresh if payment successful
                    if (result == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Bayar Sekarang',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

