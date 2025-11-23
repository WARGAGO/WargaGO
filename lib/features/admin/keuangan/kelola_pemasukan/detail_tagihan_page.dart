// ============================================================================
// DETAIL TAGIHAN PAGE (CLEAN CODE VERSION)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/detail_tagihan_widgets.dart';
import '../widgets/keuangan_constants.dart';

class DetailTagihanPage extends StatefulWidget {
  const DetailTagihanPage({
    super.key,
    required this.tagihanData,
  });

  final Map<String, dynamic> tagihanData;

  @override
  State<DetailTagihanPage> createState() => _DetailTagihanPageState();
}

class _DetailTagihanPageState extends State<DetailTagihanPage> {
  final TextEditingController _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  void _handleShowRiwayatPembayaran() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur Riwayat Pembayaran', style: GoogleFonts.poppins()),
        backgroundColor: KeuanganColors.primary,
      ),
    );
  }

  void _handleSubmitRejection() {
    if (_rejectionReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alasan penolakan tidak boleh kosong', style: GoogleFonts.poppins()),
          backgroundColor: KeuanganColors.error,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => const TagihanRejectionDialog(),
    );
  }

  void _handleApproval() {
    showDialog(
      context: context,
      builder: (context) => const TagihanSuccessDialog(
        title: 'Pembayaran Disetujui!',
        message: 'Pembayaran berhasil diverifikasi',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KeuanganColors.primary,
      body: Column(
        children: [
          _buildHeader(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2988EA), Color(0xFF1E6FD8)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeaderActionButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  _HeaderActionButton(
                    icon: Icons.history_rounded,
                    label: 'Riwayat',
                    onTap: _handleShowRiwayatPembayaran,
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
                    child: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Tagihan',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Informasi lengkap pembayaran',
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
    );
  }

  Widget _buildContent() {
    return Expanded(
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
              Center(
                child: TagihanStatusBadge(
                  status: widget.tagihanData['status'],
                  color: widget.tagihanData['color'] as Color,
                ),
              ),
              const SizedBox(height: 32),
              const TagihanSectionTitle(
                title: 'Informasi Tagihan',
                icon: Icons.receipt_outlined,
              ),
              const SizedBox(height: 16),
              TagihanInfoCard(
                children: [
                  TagihanDetailRow(
                    label: 'Kode Iuran',
                    value: widget.tagihanData['kodeTagihan'],
                    icon: Icons.qr_code_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                  const Divider(height: 24),
                  TagihanDetailRow(
                    label: 'Nama Iuran',
                    value: widget.tagihanData['iuran'],
                    icon: Icons.payment_rounded,
                    color: KeuanganColors.success,
                  ),
                  const Divider(height: 24),
                  const TagihanDetailRow(
                    label: 'Kategori Iuran',
                    value: 'Iuran Rutin',
                    icon: Icons.category_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                  const Divider(height: 24),
                  TagihanDetailRow(
                    label: 'Periode',
                    value: widget.tagihanData['periode'],
                    icon: Icons.calendar_today_rounded,
                    color: const Color(0xFF8B5CF6),
                  ),
                  const Divider(height: 24),
                  TagihanDetailRow(
                    label: 'Nominal',
                    value: widget.tagihanData['nominal'],
                    icon: Icons.attach_money_rounded,
                    color: const Color(0xFFEC4899),
                    isBold: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const TagihanSectionTitle(
                title: 'Informasi Warga',
                icon: Icons.people_outline,
              ),
              const SizedBox(height: 16),
              TagihanInfoCard(
                children: [
                  TagihanDetailRow(
                    label: 'Nama KK',
                    value: widget.tagihanData['name'],
                    icon: Icons.person_outline,
                    color: const Color(0xFF3B82F6),
                  ),
                  const Divider(height: 24),
                  const TagihanDetailRow(
                    label: 'Alamat',
                    value: 'Jl. Raya Karangploso No. 123, RT 08 RW 05',
                    icon: Icons.location_on_outlined,
                    color: KeuanganColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const TagihanSectionTitle(
                title: 'Informasi Pembayaran',
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 16),
              TagihanInfoCard(
                children: [
                  const TagihanDetailRow(
                    label: 'Metode Pembayaran',
                    value: 'Transfer Bank BCA',
                    icon: Icons.credit_card_rounded,
                    color: Color(0xFF3B82F6),
                  ),
                  const Divider(height: 24),
                  TagihanDetailRow(
                    label: 'Status',
                    value: widget.tagihanData['status'],
                    icon: Icons.info_outline,
                    color: widget.tagihanData['color'] as Color,
                    isBold: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const TagihanSectionTitle(
                title: 'Bukti Pembayaran / Alasan Penolakan',
                icon: Icons.description_outlined,
              ),
              const SizedBox(height: 16),
              TagihanRejectionForm(
                controller: _rejectionReasonController,
                onSubmit: _handleSubmitRejection,
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: KeuanganColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Kembali',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: KeuanganColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleApproval,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KeuanganColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Setujui',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label != null ? 16 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (label != null) ...[
              const SizedBox(width: 8),
              Text(
                label!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

