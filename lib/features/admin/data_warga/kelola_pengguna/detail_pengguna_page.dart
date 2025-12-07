import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wargago/core/models/user_model.dart';
import 'package:wargago/core/models/KYC/kyc_document_model.dart';
import 'package:wargago/core/services/kyc_service.dart';
import 'package:wargago/core/enums/kyc_enum.dart';
import 'package:intl/intl.dart';

import 'repositories/user_repository.dart';

/// Detail Pengguna Page - Menampilkan detail akun user dan aksi management
///
/// Fitur:
/// - Lihat detail akun lengkap
/// - Approve/Reject verifikasi
/// - Ubah role (admin/user)
/// - Enable/Disable akun
/// - Hapus akun
class DetailPenggunaPage extends StatefulWidget {
  final UserModel user;

  const DetailPenggunaPage({super.key, required this.user});

  @override
  State<DetailPenggunaPage> createState() => _DetailPenggunaPageState();
}

class _DetailPenggunaPageState extends State<DetailPenggunaPage> {
  final UserRepository _userRepository = UserRepository();
  final KYCService _kycService = KYCService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.user.role.toLowerCase() == 'admin';
    final isPending = widget.user.status.toLowerCase() == 'pending' ||
        widget.user.status.toLowerCase() == 'unverified';
    final isApproved = widget.user.status.toLowerCase() == 'approved';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F80ED)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  _buildProfileCard(isAdmin),

                  const SizedBox(height: 24),

                  // Info Section
                  _buildInfoSection(),

                  const SizedBox(height: 24),

                  // KYC Documents Section (NEW!)
                  _buildKYCDocumentsSection(),

                  const SizedBox(height: 24),

                  // Status Section
                  _buildStatusSection(isPending, isApproved),

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(isAdmin, isPending, isApproved),

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Detail Pengguna',
        style: GoogleFonts.poppins(
          color: const Color(0xFF1F2937),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileCard(bool isAdmin) {
    final avatarLetter = widget.user.nama.isNotEmpty
        ? widget.user.nama[0].toUpperCase()
        : 'U';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAdmin
              ? [const Color(0xFF2F80ED), const Color(0xFF1E6FD9)]
              : [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isAdmin ? const Color(0xFF2F80ED) : const Color(0xFF10B981))
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                avatarLetter,
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Name
          Text(
            widget.user.nama,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isAdmin ? 'Administrator' : 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Akun',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),

        const SizedBox(height: 16),

        _buildInfoCard(
          icon: Icons.email_outlined,
          label: 'Email',
          value: widget.user.email,
          iconColor: const Color(0xFF2F80ED),
        ),

        if (widget.user.nik != null && widget.user.nik!.isNotEmpty)
          _buildInfoCard(
            icon: Icons.badge_outlined,
            label: 'NIK',
            value: widget.user.nik!,
            iconColor: const Color(0xFF10B981),
          ),

        if (widget.user.noTelepon != null && widget.user.noTelepon!.isNotEmpty)
          _buildInfoCard(
            icon: Icons.phone_outlined,
            label: 'No. Telepon',
            value: widget.user.noTelepon!,
            iconColor: const Color(0xFFFBBF24),
          ),

        if (widget.user.alamat != null && widget.user.alamat!.isNotEmpty)
          _buildInfoCard(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: widget.user.alamat!,
            iconColor: const Color(0xFFEF4444),
          ),

        _buildInfoCard(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal Daftar',
          value: DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
              .format(widget.user.createdAt),
          iconColor: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildStatusSection(bool isPending, bool isApproved) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (widget.user.status.toLowerCase() == 'unverified') {
      statusText = 'Belum Verifikasi KYC';
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.warning_amber_rounded;
    } else if (widget.user.status.toLowerCase() == 'pending') {
      statusText = 'Menunggu Persetujuan';
      statusColor = const Color(0xFFFBBF24);
      statusIcon = Icons.hourglass_empty_rounded;
    } else if (widget.user.status.toLowerCase() == 'approved') {
      statusText = 'Akun Terverifikasi';
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle_outline;
    } else if (widget.user.status.toLowerCase() == 'rejected') {
      statusText = 'Ditolak';
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.cancel_outlined;
    } else {
      statusText = widget.user.status;
      statusColor = Colors.grey;
      statusIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 32),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Akun',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === KYC DOCUMENTS SECTION ===

  Widget _buildKYCDocumentsSection() {
    // Don't show KYC section for admin users
    if (widget.user.role.toLowerCase() == 'admin') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dokumen KYC',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),

        const SizedBox(height: 16),

        // Stream KYC documents dari Firestore
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('kyc_documents')
              .where('userId', isEqualTo: widget.user.id)
              .orderBy('uploadedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildEmptyKYCCard('Error loading documents');
            }

            final documents = snapshot.data?.docs ?? [];

            if (documents.isEmpty) {
              return _buildEmptyKYCCard('Belum ada dokumen KYC yang diupload');
            }

            return Column(
              children: documents.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final kycDoc = KYCDocumentModel.fromMap(data, doc.id);
                return _buildKYCDocumentCard(kycDoc);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyKYCCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_open, color: Colors.grey[400], size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKYCDocumentCard(KYCDocumentModel kycDoc) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.info;
    String statusText = 'Unknown';

    switch (kycDoc.status) {
      case KYCStatus.pending:
        statusColor = const Color(0xFFFBBF24);
        statusIcon = Icons.hourglass_empty;
        statusText = 'Pending';
        break;
      case KYCStatus.approved:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        statusText = 'Approved';
        break;
      case KYCStatus.rejected:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
    }

    String docTypeName = _getDocumentTypeName(kycDoc.documentType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Document type + Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.description, color: const Color(0xFF2F80ED), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        docTypeName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Upload date
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Uploaded: ${DateFormat('dd MMM yyyy, HH:mm').format(kycDoc.uploadedAt)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          // OCR Data Section (if available)
          if (kycDoc.ktpModel != null || kycDoc.kkModel != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildOCRDataSection(kycDoc),
          ],

          // Verified info (if applicable)
          if (kycDoc.verifiedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.verified, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  'Verified: ${DateFormat('dd MMM yyyy, HH:mm').format(kycDoc.verifiedAt!)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],

          // Rejection reason (if rejected)
          if (kycDoc.status == KYCStatus.rejected && kycDoc.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alasan Ditolak:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kycDoc.rejectionReason!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons (only for pending status)
          if (kycDoc.status == KYCStatus.pending) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDocument(kycDoc),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Lihat'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2F80ED),
                      side: const BorderSide(color: Color(0xFF2F80ED)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectKYCDocument(kycDoc),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tolak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveKYCDocument(kycDoc),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Setujui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // View button for approved/rejected
          if (kycDoc.status != KYCStatus.pending) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _viewDocument(kycDoc),
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Lihat Dokumen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2F80ED),
                  side: const BorderSide(color: Color(0xFF2F80ED)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOCRDataSection(KYCDocumentModel kycDoc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F80ED).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2F80ED).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF2F80ED),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Hasil OCR',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2F80ED),
                      ),
                    ),
                    Text(
                      'Data otomatis dari scan dokumen',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // KTP Data
          if (kycDoc.ktpModel != null) _buildKTPDataFields(kycDoc.ktpModel!),

          // KK Data
          if (kycDoc.kkModel != null) _buildKKDataFields(kycDoc.kkModel!),
        ],
      ),
    );
  }

  Widget _buildKTPDataFields(dynamic ktpModel) {
    final ktp = ktpModel;

    return Column(
      children: [
        if (ktp.nik != null && ktp.nik!.isNotEmpty)
          _buildOCRField('NIK', ktp.nik!, Icons.credit_card),
        if (ktp.nama != null && ktp.nama!.isNotEmpty)
          _buildOCRField('Nama', ktp.nama!, Icons.person),
        if (ktp.tempatLahir != null && ktp.tempatLahir!.isNotEmpty)
          _buildOCRField('Tempat Lahir', ktp.tempatLahir!, Icons.location_city),
        if (ktp.tanggalLahir != null && ktp.tanggalLahir!.isNotEmpty)
          _buildOCRField('Tanggal Lahir', ktp.tanggalLahir!, Icons.cake),
        if (ktp.jenisKelamin != null && ktp.jenisKelamin!.isNotEmpty)
          _buildOCRField('Jenis Kelamin', ktp.jenisKelamin!, Icons.wc),
        if (ktp.alamat != null && ktp.alamat!.isNotEmpty)
          _buildOCRField('Alamat', ktp.alamat!, Icons.home, isLast: false),
        if (ktp.agama != null && ktp.agama!.isNotEmpty)
          _buildOCRField('Agama', ktp.agama!, Icons.church),
        if (ktp.pekerjaan != null && ktp.pekerjaan!.isNotEmpty)
          _buildOCRField('Pekerjaan', ktp.pekerjaan!, Icons.work),
        if (ktp.statusPerkawinan != null && ktp.statusPerkawinan!.isNotEmpty)
          _buildOCRField('Status Perkawinan', ktp.statusPerkawinan!, Icons.favorite),
        if (ktp.kewarganegaraan != null && ktp.kewarganegaraan!.isNotEmpty)
          _buildOCRField('Kewarganegaraan', ktp.kewarganegaraan!, Icons.flag, isLast: true),
      ],
    );
  }

  Widget _buildKKDataFields(dynamic kkModel) {
    final kk = kkModel;

    return Column(
      children: [
        if (kk.noKK != null && kk.noKK!.isNotEmpty)
          _buildOCRField('No. KK', kk.noKK!, Icons.credit_card),
        if (kk.namaKepalaKeluarga != null && kk.namaKepalaKeluarga!.isNotEmpty)
          _buildOCRField('Kepala Keluarga', kk.namaKepalaKeluarga!, Icons.person),
        if (kk.alamat != null && kk.alamat!.isNotEmpty)
          _buildOCRField('Alamat', kk.alamat!, Icons.home, isLast: true),
      ],
    );
  }

  Widget _buildOCRField(String label, String value, IconData icon, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2F80ED)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDocumentTypeName(KYCDocumentType type) {
    switch (type) {
      case KYCDocumentType.ktp:
        return 'KTP (Kartu Tanda Penduduk)';
      case KYCDocumentType.kk:
        return 'KK (Kartu Keluarga)';
      case KYCDocumentType.akteKelahiran:
        return 'Akte Kelahiran';
    }
  }

  // === KYC ACTION METHODS ===

  Future<void> _viewDocument(KYCDocumentModel kycDoc) async {
    setState(() => _isLoading = true);

    try {
      // Get document URL from KYC service
      final url = await _kycService.getDocumentUrlFromModel(kycDoc);

      setState(() => _isLoading = false);

      if (url == null || url.isEmpty) {
        if (mounted) {
          _showErrorSnackBar('Gagal memuat dokumen. File mungkin sudah dihapus.');
        }
        return;
      }

      // Show document in dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => _buildDocumentViewerDialog(kycDoc, url),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Error loading document: $e');
      }
    }
  }

  Widget _buildDocumentViewerDialog(KYCDocumentModel kycDoc, String imageUrl) {
    final docTypeName = _getDocumentTypeName(kycDoc.documentType);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Builder(
        builder: (dialogContext) => Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            docTypeName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.nama,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),

            // Image viewer
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading image...',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The image might be deleted or unavailable',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Footer with info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Pinch to zoom • Drag to pan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Uploaded: ${DateFormat('dd MMM yyyy, HH:mm').format(kycDoc.uploadedAt)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ), // Close Builder
      ),
    );
  }

  Future<void> _approveKYCDocument(KYCDocumentModel kycDoc) async {
    final confirm = await _showConfirmDialog(
      title: 'Setujui Dokumen KYC',
      message: 'Apakah Anda yakin ingin menyetujui ${_getDocumentTypeName(kycDoc.documentType)}?\n\nUser akan otomatis ter-approve dan mendapat full access.',
      confirmText: 'Setujui',
      confirmColor: const Color(0xFF10B981),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        // Get current admin ID (you might need to get this from auth provider)
        final adminId = 'ADMIN_ID'; // TODO: Get from AuthProvider

        await _kycService.approveDocument(
          documentId: kycDoc.id!,
          adminId: adminId,
        );

        if (mounted) {
          _showSuccessSnackBar('Dokumen KYC berhasil disetujui!\nUser ${widget.user.nama} sekarang ter-approve.');
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Gagal approve dokumen: $e');
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectKYCDocument(KYCDocumentModel kycDoc) async {
    // Show dialog to input rejection reason
    final reason = await _showRejectReasonDialog();

    if (reason != null && reason.isNotEmpty) {
      setState(() => _isLoading = true);

      try {
        // Get current admin ID
        final adminId = 'ADMIN_ID'; // TODO: Get from AuthProvider

        await _kycService.rejectDocument(
          documentId: kycDoc.id!,
          adminId: adminId,
          reason: reason,
        );

        if (mounted) {
          _showSuccessSnackBar('Dokumen KYC ditolak.');
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Gagal reject dokumen: $e');
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _showRejectReasonDialog() async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Alasan Penolakan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Masukkan alasan penolakan...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isAdmin, bool isPending, bool isApproved) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),

        const SizedBox(height: 16),

        // Approve/Reject buttons (hanya untuk pending)
        if (isPending) ...[
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Approve',
                  icon: Icons.check_circle,
                  color: const Color(0xFF10B981),
                  onTap: () => _approveUser(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  label: 'Reject',
                  icon: Icons.cancel,
                  color: const Color(0xFFEF4444),
                  onTap: () => _rejectUser(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Change role button (hanya untuk approved)
        if (isApproved)
          _buildActionButton(
            label: isAdmin ? 'Ubah ke User' : 'Ubah ke Admin',
            icon: Icons.swap_horiz,
            color: const Color(0xFF8B5CF6),
            onTap: () => _changeRole(isAdmin),
          ),

        const SizedBox(height: 12),

        // Delete button
        _buildActionButton(
          label: 'Hapus Akun',
          icon: Icons.delete_outline,
          color: const Color(0xFFEF4444),
          onTap: () => _deleteUser(),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === ACTION METHODS ===

  Future<void> _approveUser() async {
    final confirm = await _showConfirmDialog(
      title: 'Approve Akun',
      message: 'Apakah Anda yakin ingin menyetujui akun ${widget.user.nama}?',
      confirmText: 'Approve',
      confirmColor: const Color(0xFF10B981),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      final success = await _userRepository.updateUserStatus(
        widget.user.id,
        'approved',
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        _showSuccessSnackBar('Akun berhasil diapprove');
        Navigator.pop(context);
      } else if (mounted) {
        _showErrorSnackBar('Gagal approve akun');
      }
    }
  }

  Future<void> _rejectUser() async {
    final confirm = await _showConfirmDialog(
      title: 'Reject Akun',
      message: 'Apakah Anda yakin ingin menolak akun ${widget.user.nama}?',
      confirmText: 'Reject',
      confirmColor: const Color(0xFFEF4444),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      final success = await _userRepository.updateUserStatus(
        widget.user.id,
        'rejected',
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        _showSuccessSnackBar('Akun berhasil ditolak');
        Navigator.pop(context);
      } else if (mounted) {
        _showErrorSnackBar('Gagal reject akun');
      }
    }
  }

  Future<void> _changeRole(bool isCurrentlyAdmin) async {
    final newRole = isCurrentlyAdmin ? 'user' : 'admin';
    final roleName = isCurrentlyAdmin ? 'User' : 'Admin';

    final confirm = await _showConfirmDialog(
      title: 'Ubah Role',
      message: 'Ubah role ${widget.user.nama} menjadi $roleName?',
      confirmText: 'Ubah',
      confirmColor: const Color(0xFF8B5CF6),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      final success = await _userRepository.updateUserRole(
        widget.user.id,
        newRole,
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        _showSuccessSnackBar('Role berhasil diubah menjadi $roleName');
        Navigator.pop(context);
      } else if (mounted) {
        _showErrorSnackBar('Gagal mengubah role');
      }
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await _showConfirmDialog(
      title: 'Hapus Akun',
      message:
          'Apakah Anda yakin ingin menghapus akun ${widget.user.nama}? Tindakan ini tidak dapat dibatalkan!',
      confirmText: 'Hapus',
      confirmColor: const Color(0xFFEF4444),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      final success = await _userRepository.deleteUser(widget.user.id);

      setState(() => _isLoading = false);

      if (success && mounted) {
        _showSuccessSnackBar('Akun berhasil dihapus');
        Navigator.pop(context);
      } else if (mounted) {
        _showErrorSnackBar('Gagal menghapus akun');
      }
    }
  }

  // === HELPER METHODS ===

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

