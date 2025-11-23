import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/models/warga_model.dart';
import 'package:jawara/core/providers/warga_provider.dart';
import 'edit_data_warga_page.dart';

class DetailDataWargaPage extends StatelessWidget {
  final WargaModel warga;

  const DetailDataWargaPage({super.key, required this.warga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detail Data Warga",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDataWargaPage(warga: warga),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailField("Nama Lengkap", warga.name),
            _buildDetailField("NIK", warga.nik),
            _buildDetailField("Nomor KK", warga.nomorKK),
            _buildDetailField("Tempat, Tanggal Lahir", warga.formattedBirthInfo),
            _buildDetailField("Jenis Kelamin", warga.jenisKelamin),
            _buildDetailField("Agama", warga.agama),
            _buildDetailField("Golongan Darah", warga.golonganDarah),
            _buildDetailField("Pendidikan Terakhir", warga.pendidikan),
            _buildDetailField("Pekerjaan", warga.pekerjaan),
            _buildDetailField("Status Perkawinan", warga.statusPerkawinan),
            _buildDetailField("Peran dalam Keluarga", warga.peranKeluarga),
            _buildDetailField("Status Penduduk", warga.statusPenduduk),
            _buildDetailField("Status Hidup", warga.statusHidup),
            _buildDetailField("Nama Ibu", warga.namaIbu),
            _buildDetailField("Nama Ayah", warga.namaAyah),
            _buildDetailField("RT", warga.rt),
            _buildDetailField("RW", warga.rw),
            _buildDetailField("Alamat", warga.alamat),
            _buildDetailField("Nomor Telepon", warga.phone),
            _buildDetailField("Kewarganegaraan", warga.kewarganegaraan),
            _buildDetailField("Keluarga", warga.namaKeluarga),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: value.isEmpty ? '-' : value,
            readOnly: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Hapus Warga',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus data warga ${warga.name}? Tindakan ini tidak dapat dibatalkan.',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ Data yang dihapus tidak dapat dikembalikan!',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteWarga(context);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWarga(BuildContext context) async {
    final provider = context.read<WargaProvider>();

    // Show loading dialog
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
                  'Menghapus data...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final success = await provider.deleteWarga(warga.id);

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      if (!context.mounted) return;

      if (success) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade600,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Berhasil Dihapus!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Data warga berhasil dihapus dari sistem',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close success dialog
                      Navigator.pop(context); // Close detail page
                    },
                    child: Text(
                      'OK',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Gagal Menghapus',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Terjadi kesalahan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'OK',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading if still showing
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!context.mounted) return;

      // Show error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Error',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
      );
    }
  }
}
