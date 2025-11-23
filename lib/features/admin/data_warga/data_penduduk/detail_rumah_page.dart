import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailRumahPage extends StatelessWidget {
  final Map<String, dynamic> rumahData;

  const DetailRumahPage({
    super.key,
    required this.rumahData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2988EA),
      body: Column(
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2988EA),
                  const Color(0xFF1E6FD8),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title & Icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.home_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detail Rumah',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Informasi lengkap rumah',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Rumah
                    _buildSectionTitle('Informasi Rumah', Icons.info_outline),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8EAF2), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Alamat',
                            rumahData['alamat'] ?? 'Jl. Merbabu No. 123, RT 08 RW 05',
                            Icons.location_on_outlined,
                            const Color(0xFF3B82F6),
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Status',
                            rumahData['status'] ?? 'Tersedia',
                            Icons.check_circle_outline,
                            rumahData['status'] == 'Tersedia'
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Riwayat Penghuni
                    _buildSectionTitle('Riwayat Penghuni', Icons.history_outlined),
                    const SizedBox(height: 16),

                    // List Riwayat Penghuni
                    _buildRiwayatCard(
                      keluarga: 'Keluarga Budi Santoso',
                      kepalaKeluarga: 'Budi Santoso',
                      tanggalMasuk: '15 Januari 2023',
                      tanggalKeluar: null,
                      isActive: true,
                    ),
                    const SizedBox(height: 12),
                    _buildRiwayatCard(
                      keluarga: 'Keluarga Ahmad Rahman',
                      kepalaKeluarga: 'Ahmad Rahman',
                      tanggalMasuk: '10 Maret 2022',
                      tanggalKeluar: '30 Desember 2022',
                      isActive: false,
                    ),
                    const SizedBox(height: 12),
                    _buildRiwayatCard(
                      keluarga: 'Keluarga Siti Nurhaliza',
                      kepalaKeluarga: 'Siti Nurhaliza',
                      tanggalMasuk: '5 Agustus 2021',
                      tanggalKeluar: '15 Februari 2022',
                      isActive: false,
                    ),

                    const SizedBox(height: 32),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF2988EA), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Kembali',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2988EA),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2988EA).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF2988EA),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatCard({
    required String keluarga,
    required String kepalaKeluarga,
    required String tanggalMasuk,
    String? tanggalKeluar,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color(0xFF2988EA).withValues(alpha: 0.3)
              : const Color(0xFFE8EAF2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan icon dan badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                      : const Color(0xFF6B7280).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.family_restroom_rounded,
                  color: isActive ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  keluarga,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Aktif',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Kepala Keluarga
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 8),
              Text(
                'Kepala Keluarga: ',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Expanded(
                child: Text(
                  kepalaKeluarga,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tanggal Masuk
          Row(
            children: [
              Icon(
                Icons.login_rounded,
                size: 16,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Text(
                'Tanggal Masuk: ',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                tanggalMasuk,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),

          // Tanggal Keluar (jika ada)
          if (tanggalKeluar != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 16,
                  color: const Color(0xFFEF4444),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tanggal Keluar: ',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  tanggalKeluar,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

