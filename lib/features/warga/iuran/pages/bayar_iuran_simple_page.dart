/// ============================================================================
/// BAYAR IURAN PAGE - UPDATED WITH AZURE BLOB STORAGE
/// ============================================================================
/// Upload bukti pembayaran dengan Azure Blob Storage (URL permanen, tidak expired)
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/services/bukti_pembayaran_service.dart';

class BayarIuranSimplePage extends StatefulWidget {
  final String tagihanId; // ⭐ ADDED: Tagihan ID untuk proses pembayaran
  final String namaIuran;
  final double nominal;
  final String tanggal;

  const BayarIuranSimplePage({
    super.key,
    required this.tagihanId, // ⭐ ADDED
    required this.namaIuran,
    required this.nominal,
    required this.tanggal,
  });

  @override
  State<BayarIuranSimplePage> createState() => _BayarIuranSimplePageState();
}

class _BayarIuranSimplePageState extends State<BayarIuranSimplePage> {
  final BuktiPembayaranService _buktiService = BuktiPembayaranService(); // ⭐ Azure service

  String _selectedMetode = 'Transfer Bank';
  File? _buktiImage;
  bool _isUploading = false;

  final List<Map<String, dynamic>> _metodeOptions = [
    {
      'value': 'Transfer Bank',
      'label': 'Transfer Bank',
      'icon': Icons.account_balance
    },
    {'value': 'Tunai', 'label': 'Tunai', 'icon': Icons.money},
    {'value': 'E-Wallet', 'label': 'E-Wallet', 'icon': Icons.wallet},
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _buktiImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPembayaran() async {
    if (_buktiImage == null) {
      _showSnackBar(
        'Silakan upload bukti pembayaran terlebih dahulu',
        isError: true,
      );
      return;
    }

    // Confirm dialog
    final confirm = await _showConfirmDialog();
    if (!confirm) return;

    setState(() => _isUploading = true);

    try {
      // ⭐ Process pembayaran dengan Azure Blob Storage
      await _buktiService.prosesTagihanIuran(
        tagihanId: widget.tagihanId,
        buktiImage: _buktiImage!,
        metodePembayaran: _selectedMetode,
      );

      if (mounted) {
        _showSnackBar(
          '✅ Pembayaran berhasil! Tagihan sudah lunas.',
          isError: false,
        );

        // Return true to refresh data
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Gagal memproses pembayaran: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Pembayaran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda yakin ingin mengirim bukti pembayaran ini?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F80ED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Ya, Kirim', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
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
          'Bayar Iuran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Tagihan
            Container(
              padding: const EdgeInsets.all(16),
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
                    'Detail Tagihan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Divider(height: 20),
                  _buildInfoRow('Nama Iuran', widget.namaIuran),
                  _buildInfoRow('Nominal', currencyFormat.format(widget.nominal)),
                  _buildInfoRow('Jatuh Tempo', widget.tanggal),
                  _buildInfoRow('Status', 'Belum Dibayar'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Metode Pembayaran
            Text(
              'Metode Pembayaran',
              style:
                  GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ..._metodeOptions.map((metode) {
              final isSelected = _selectedMetode == metode['value'];
              return GestureDetector(
                onTap: () => setState(() => _selectedMetode = metode['value']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2F80ED)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        metode['icon'],
                        color: isSelected
                            ? const Color(0xFF2F80ED)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        metode['label'],
                        style: GoogleFonts.poppins(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF2F80ED)
                              : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF2F80ED)),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Upload Bukti
            Text(
              'Upload Bukti Pembayaran',
              style:
                  GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: _buktiImage != null ? 200 : 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _buktiImage != null
                        ? const Color(0xFF10B981)
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: _buktiImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            Image.file(
                              _buktiImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Text(
                                  '✓ Dipilih',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'Tap untuk upload bukti',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            if (_buktiImage != null) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.refresh),
                  label: Text('Ganti Gambar', style: GoogleFonts.poppins()),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F80ED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Kirim Bukti Pembayaran',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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

