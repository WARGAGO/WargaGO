/// ============================================================================
/// VERIFIKASI PEMBAYARAN PAGE - Admin Review Bukti Pembayaran
/// ============================================================================
/// Halaman untuk admin review bukti pembayaran dari warga
/// - Lihat daftar tagihan "Menunggu Verifikasi"
/// - View bukti pembayaran (image dari Azure Blob Storage)
/// - Approve → Status "Lunas" + Create keuangan
/// - Reject → Status "Ditolak" + Add catatan
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VerifikasiPembayaranPage extends StatefulWidget {
  const VerifikasiPembayaranPage({super.key});

  @override
  State<VerifikasiPembayaranPage> createState() => _VerifikasiPembayaranPageState();
}

class _VerifikasiPembayaranPageState extends State<VerifikasiPembayaranPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Verifikasi Pembayaran',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2988EA),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tagihan')
            .where('status', isEqualTo: 'Menunggu Verifikasi')
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final tagihanDocs = snapshot.data?.docs ?? [];

          if (tagihanDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada pembayaran yang perlu diverifikasi',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tagihanDocs.length,
            itemBuilder: (context, index) {
              final data = tagihanDocs[index].data() as Map<String, dynamic>;
              final tagihanId = tagihanDocs[index].id;

              return _buildTagihanCard(tagihanId, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildTagihanCard(String tagihanId, Map<String, dynamic> data) {
    final keluargaName = data['keluargaName'] as String? ?? 'Unknown';
    final jenisIuranName = data['jenisIuranName'] as String? ?? 'Unknown';
    final nominal = (data['nominal'] as num?)?.toDouble() ?? 0;
    final metodePembayaran = data['metodePembayaran'] as String? ?? 'Unknown';
    final buktiPembayaran = data['buktiPembayaran'] as String?;
    final tanggalBayar = (data['tanggalBayar'] as Timestamp?)?.toDate();

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.hourglass_empty_rounded,
                    color: Color(0xFFFF6B6B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        keluargaName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        jenisIuranName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pending',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Info Detail
            _buildInfoRow('Nominal', currencyFormat.format(nominal)),
            _buildInfoRow('Metode', metodePembayaran),
            if (tanggalBayar != null)
              _buildInfoRow('Tanggal Submit', dateFormat.format(tanggalBayar)),

            const SizedBox(height: 16),

            // Bukti Pembayaran
            Text(
              'Bukti Pembayaran:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),

            if (buktiPembayaran != null && buktiPembayaran.isNotEmpty)
              GestureDetector(
                onTap: () => _showBuktiPembayaranDialog(buktiPembayaran),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: buktiPembayaran,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Gagal memuat gambar',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            Text(
                              'Tap untuk coba lagi',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Tidak ada bukti pembayaran',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectPembayaran(tagihanId),
                    icon: const Icon(Icons.close_rounded),
                    label: Text(
                      'Tolak',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approvePembayaran(tagihanId, data),
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      'Approve',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  void _showBuktiPembayaranDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  height: 400,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 400,
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Gagal memuat gambar'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approvePembayaran(
    String tagihanId,
    Map<String, dynamic> tagihanData,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 1. Update tagihan status to "Lunas"
      await _firestore.collection('tagihan').doc(tagihanId).update({
        'status': 'Lunas',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Create keuangan record
      await _firestore.collection('keuangan').add({
        'jenis': 'Pemasukan',
        'kategori': 'Iuran Warga',
        'subKategori': tagihanData['jenisIuranName'],
        'nominal': tagihanData['nominal'],
        'tanggal': tagihanData['tanggalBayar'] ?? FieldValue.serverTimestamp(),
        'keterangan':
            'Pembayaran ${tagihanData['jenisIuranName']} - ${tagihanData['keluargaName']}',
        'metodePembayaran': tagihanData['metodePembayaran'],
        'buktiTransaksi': tagihanData['buktiPembayaran'],
        'keluargaId': tagihanData['keluargaId'],
        'keluargaName': tagihanData['keluargaName'],
        'jenisIuranId': tagihanData['jenisIuranId'],
        'jenisIuranName': tagihanData['jenisIuranName'],
        'tagihanId': tagihanId,
        'periode': tagihanData['periode'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Close loading
      if (mounted) Navigator.pop(context);

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Pembayaran berhasil diapprove!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectPembayaran(String tagihanId) async {
    // Show dialog for rejection reason
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Alasan Penolakan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Masukkan alasan penolakan...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Tolak', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Update tagihan status to "Ditolak"
      await _firestore.collection('tagihan').doc(tagihanId).update({
        'status': 'Ditolak',
        'catatanPenolakan': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Close loading
      if (mounted) Navigator.pop(context);

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pembayaran ditolak',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

