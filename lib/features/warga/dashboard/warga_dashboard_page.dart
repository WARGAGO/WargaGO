// ============================================================================
// WARGA DASHBOARD PAGE
// ============================================================================
// Dashboard untuk warga dengan status verifikasi
// - Unverified: Akses terbatas, bisa upload KYC
// - Verified: Akses penuh
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/models/kyc_document_model.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import 'package:jawara/core/services/kyc_service.dart';
import 'package:jawara/features/common/auth/presentation/widgets/auth_constants.dart';
import 'package:jawara/features/common/auth/presentation/pages/warga/kyc_upload_page.dart';

class WargaDashboardPage extends StatefulWidget {
  const WargaDashboardPage({super.key});

  @override
  State<WargaDashboardPage> createState() => _WargaDashboardPageState();
}

class _WargaDashboardPageState extends State<WargaDashboardPage> {
  final KYCService _kycService = KYCService();
  bool _isVerified = false;
  List<KYCDocumentModel> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userModel?.id;

    if (userId == null) return;

    setState(() => _isLoading = true);

    final isVerified = await _kycService.isUserVerified(userId);
    final documents = await _kycService.getUserDocuments(userId);

    setState(() {
      _isVerified = isVerified;
      _documents = documents;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: AuthColors.background,
      appBar: AppBar(
        backgroundColor: AuthColors.primary,
        elevation: 0,
        title: Text(
          'Dashboard Warga',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AuthSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(user?.nama ?? 'Warga'),
                  const SizedBox(height: AuthSpacing.xl),
                  _buildVerificationStatusCard(),
                  const SizedBox(height: AuthSpacing.xl),
                  _buildDocumentsList(),
                  const SizedBox(height: AuthSpacing.xl),
                  _buildFeaturesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeCard(String nama) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AuthSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AuthColors.primary, AuthColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AuthSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: AuthColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang,',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AuthSpacing.xs),
          Text(
            nama,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AuthSpacing.lg),
      decoration: BoxDecoration(
        color: _isVerified ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(AuthSpacing.md),
        border: Border.all(
          color: _isVerified ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isVerified ? Icons.verified_user : Icons.warning_amber,
                color: _isVerified ? Colors.green.shade700 : Colors.orange.shade700,
                size: 32,
              ),
              const SizedBox(width: AuthSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isVerified ? 'Akun Terverifikasi' : 'Akun Belum Terverifikasi',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isVerified ? Colors.green.shade900 : Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: AuthSpacing.xs),
                    Text(
                      _isVerified
                          ? 'Anda memiliki akses penuh ke semua fitur'
                          : 'Upload dokumen KYC untuk mendapatkan akses penuh',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _isVerified ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_isVerified && _documents.isEmpty) ...[
            const SizedBox(height: AuthSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KYCUploadPage()),
                  ).then((_) => _checkVerificationStatus());
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Dokumen KYC'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    if (_documents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dokumen KYC',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AuthSpacing.md),
        ...(_documents.map((doc) => _buildDocumentItem(doc)).toList()),
      ],
    );
  }

  Widget _buildDocumentItem(KYCDocumentModel doc) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (doc.status) {
      case KYCStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Disetujui';
        break;
      case KYCStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Ditolak';
        break;
      case KYCStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AuthSpacing.md),
      padding: const EdgeInsets.all(AuthSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AuthSpacing.md),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: AuthColors.primary, size: 32),
          const SizedBox(width: AuthSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.documentTypeName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (doc.status == KYCStatus.rejected && doc.rejectionReason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Alasan: ${doc.rejectionReason}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitur Tersedia',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AuthSpacing.md),
        _buildFeatureItem(
          icon: Icons.calendar_today,
          title: 'Lihat Agenda',
          description: 'Lihat jadwal kegiatan warga',
          isEnabled: true,
        ),
        _buildFeatureItem(
          icon: Icons.notifications,
          title: 'Notifikasi',
          description: 'Terima pemberitahuan penting',
          isEnabled: true,
        ),
        _buildFeatureItem(
          icon: Icons.receipt,
          title: 'Tagihan & Iuran',
          description: 'Bayar tagihan dan iuran warga',
          isEnabled: _isVerified,
        ),
        _buildFeatureItem(
          icon: Icons.people,
          title: 'Data Warga',
          description: 'Lihat data lengkap warga',
          isEnabled: _isVerified,
        ),
        _buildFeatureItem(
          icon: Icons.store,
          title: 'Lapak Warga',
          description: 'Jual beli antar warga',
          isEnabled: _isVerified,
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isEnabled,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: AuthSpacing.md),
        padding: const EdgeInsets.all(AuthSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AuthSpacing.md),
          border: Border.all(
            color: isEnabled ? AuthColors.primary.withValues(alpha: 0.3) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AuthSpacing.md),
              decoration: BoxDecoration(
                color: isEnabled ? AuthColors.primary.withValues(alpha: 0.1) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(AuthSpacing.sm),
              ),
              child: Icon(
                icon,
                color: isEnabled ? AuthColors.primary : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: AuthSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isEnabled ? AuthColors.textTertiary : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (!isEnabled)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuthSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(AuthSpacing.xs),
                ),
                child: Text(
                  'Perlu KYC',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

