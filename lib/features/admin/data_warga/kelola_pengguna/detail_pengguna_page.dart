import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jawara/core/models/user_model.dart';
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

