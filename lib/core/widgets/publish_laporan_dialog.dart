import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/laporan_keuangan_service.dart';
import '../providers/auth_provider.dart';

class PublishLaporanDialog extends StatefulWidget {
  final List<Map<String, dynamic>> dataPemasukan;
  final List<Map<String, dynamic>> dataPengeluaran;
  final String defaultTitle;

  const PublishLaporanDialog({
    super.key,
    required this.dataPemasukan,
    required this.dataPengeluaran,
    required this.defaultTitle,
  });

  @override
  State<PublishLaporanDialog> createState() => _PublishLaporanDialogState();
}

class _PublishLaporanDialogState extends State<PublishLaporanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _keteranganController = TextEditingController();

  int _selectedBulan = DateTime.now().month;
  int _selectedTahun = DateTime.now().year;
  String _selectedJenis = 'gabungan';

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _judulController.text = widget.defaultTitle;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    double total = 0;
    if (_selectedJenis == 'pemasukan' || _selectedJenis == 'gabungan') {
      for (var item in widget.dataPemasukan) {
        total += (item['nominal'] ?? 0).toDouble();
      }
    }
    if (_selectedJenis == 'pengeluaran' || _selectedJenis == 'gabungan') {
      for (var item in widget.dataPengeluaran) {
        total += (item['nominal'] ?? 0).toDouble();
      }
    }
    return total;
  }

  int _calculateJumlahTransaksi() {
    int count = 0;
    if (_selectedJenis == 'pemasukan' || _selectedJenis == 'gabungan') {
      count += widget.dataPemasukan.length;
    }
    if (_selectedJenis == 'pengeluaran' || _selectedJenis == 'gabungan') {
      count += widget.dataPengeluaran.length;
    }
    return count;
  }

  Future<void> _publishLaporan() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.userModel;

    if (user == null) {
      _showError('User tidak ditemukan');
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
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
                  'Mempublikasi laporan...',
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
      final service = LaporanKeuanganService();

      // Determine data to publish
      List<Map<String, dynamic>> pemasukan = [];
      List<Map<String, dynamic>> pengeluaran = [];

      if (_selectedJenis == 'pemasukan' || _selectedJenis == 'gabungan') {
        pemasukan = widget.dataPemasukan;
      }
      if (_selectedJenis == 'pengeluaran' || _selectedJenis == 'gabungan') {
        pengeluaran = widget.dataPengeluaran;
      }

      final success = await service.publishLaporan(
        judul: _judulController.text.trim(),
        keterangan: _keteranganController.text.trim(),
        bulan: _selectedBulan,
        tahun: _selectedTahun,
        jenisLaporan: _selectedJenis,
        dataPemasukan: pemasukan,
        dataPengeluaran: pengeluaran,
        adminId: user.id,
        adminNama: user.nama,
        adminRole: user.role,
      );

      // Close loading
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Close dialog with success
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Laporan berhasil dipublikasikan!',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        _showError('Gagal mempublikasikan laporan');
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.of(context).pop();
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2988EA), Color(0xFF1E6FBA)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.publish_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Publish Laporan Keuangan',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Judul Laporan
                Text(
                  'Judul Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _judulController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan judul laporan',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2988EA),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Periode
                Text(
                  'Periode Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedBulan,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8F9FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8EAF2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8EAF2),
                            ),
                          ),
                        ),
                        items: List.generate(12, (index) {
                          final bulan = index + 1;
                          final label = DateFormat.MMMM(
                            'id_ID',
                          ).format(DateTime(2025, bulan));
                          return DropdownMenuItem(
                            value: bulan,
                            child: Text(label, overflow: TextOverflow.ellipsis),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _selectedBulan = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedTahun,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8F9FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8EAF2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8EAF2),
                            ),
                          ),
                        ),
                        items: List.generate(5, (index) {
                          final tahun = DateTime.now().year - 2 + index;
                          return DropdownMenuItem(
                            value: tahun,
                            child: Text(
                              '$tahun',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _selectedTahun = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Jenis Laporan
                Text(
                  'Jenis Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(
                        'Pemasukan Saja',
                        style: GoogleFonts.poppins(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: 'pemasukan',
                      groupValue: _selectedJenis,
                      onChanged: (value) {
                        setState(() {
                          _selectedJenis = value!;
                        });
                      },
                      activeColor: const Color(0xFF2988EA),
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String>(
                      title: Text(
                        'Pengeluaran Saja',
                        style: GoogleFonts.poppins(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: 'pengeluaran',
                      groupValue: _selectedJenis,
                      onChanged: (value) {
                        setState(() {
                          _selectedJenis = value!;
                        });
                      },
                      activeColor: const Color(0xFF2988EA),
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String>(
                      title: Text(
                        'Gabungan (Pemasukan + Pengeluaran)',
                        style: GoogleFonts.poppins(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: 'gabungan',
                      groupValue: _selectedJenis,
                      onChanged: (value) {
                        setState(() {
                          _selectedJenis = value!;
                        });
                      },
                      activeColor: const Color(0xFF2988EA),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Keterangan
                Text(
                  'Keterangan (Opsional)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _keteranganController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan keterangan laporan...',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2988EA),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2988EA).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.preview_rounded,
                            color: Color(0xFF2988EA),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Preview Ringkasan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2988EA),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPreviewItem(
                        'Total Transaksi',
                        '${_calculateJumlahTransaksi()}',
                      ),
                      _buildPreviewItem(
                        'Total Nominal',
                        currencyFormat.format(_calculateTotal()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _publishLaporan,
                        icon: const Icon(Icons.publish_rounded, size: 20),
                        label: Text(
                          'Publish Laporan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2988EA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
