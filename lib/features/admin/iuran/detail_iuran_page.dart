// filepath: lib/features/admin/iuran/detail_iuran_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/iuran_model.dart';
import '../../../core/services/iuran_service.dart';
import 'tambah_iuran_page.dart';

class DetailIuranPage extends StatefulWidget {
  final IuranModel iuran;

  const DetailIuranPage({super.key, required this.iuran});

  @override
  State<DetailIuranPage> createState() => _DetailIuranPageState();
}

class _DetailIuranPageState extends State<DetailIuranPage> {
  final IuranService _iuranService = IuranService();
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = ['Semua', 'Belum Bayar', 'Sudah Bayar', 'Terlambat'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatistics(),
            _buildFilterTabs(),
            Expanded(
              child: _buildTagihanList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2F80ED),
            Color(0xFF1E6FD9),
            Color(0xFF0F5FCC),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.iuran.judul,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.iuran.deskripsi,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TambahIuranPage(iuran: widget.iuran),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog();
                  } else if (value == 'toggle_status') {
                    _toggleStatus();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text('Edit', style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: Row(
                      children: [
                        Icon(
                          widget.iuran.status == 'aktif'
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.iuran.status == 'aktif' ? 'Nonaktifkan' : 'Aktifkan',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.payments_rounded,
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(widget.iuran.nominal),
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.event_repeat_rounded,
                widget.iuran.tipe[0].toUpperCase() + widget.iuran.tipe.substring(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _iuranService.getIuranStatistics(widget.iuran.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;
        final totalTagihan = stats['totalTagihan'] ?? 0;
        final sudahBayar = stats['sudahBayar'] ?? 0;
        final belumBayar = stats['belumBayar'] ?? 0;
        final persentase = stats['persentasePembayaran'] ?? 0.0;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Total Tagihan', totalTagihan.toString(), Icons.receipt_long_rounded),
                  _buildStatItem('Sudah Bayar', sudahBayar.toString(), Icons.check_circle_outline_rounded),
                  _buildStatItem('Belum Bayar', belumBayar.toString(), Icons.pending_outlined),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Persentase Pembayaran',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: persentase / 100,
                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${persentase.toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // ⭐ NEW: Regenerate button if tagihan count seems wrong
                    if (totalTagihan < 5) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _regenerateTagihan(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: Text(
                            'Generate Ulang Tagihan untuk Semua Warga',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTagihanList() {
    return StreamBuilder<List<TagihanModel>>(
      stream: _iuranService.getTagihanByIuran(widget.iuran.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F80ED)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        List<TagihanModel> tagihanList = snapshot.data!;

        // Filter by status
        if (_selectedFilter != 'Semua') {
          tagihanList = tagihanList.where((tagihan) {
            if (_selectedFilter == 'Belum Bayar') {
              return tagihan.status == 'belum_bayar' || tagihan.status == 'Belum Dibayar';
            } else if (_selectedFilter == 'Sudah Bayar') {
              return tagihan.status == 'sudah_bayar' || tagihan.status == 'Lunas';
            } else if (_selectedFilter == 'Terlambat') {
              return tagihan.status == 'terlambat' || tagihan.status == 'Terlambat';
            }
            return true;
          }).toList();
        }

        if (tagihanList.isEmpty) {
          return _buildEmptyFilterState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: tagihanList.length,
          itemBuilder: (context, index) {
            return _buildTagihanCard(tagihanList[index]);
          },
        );
      },
    );
  }

  Widget _buildTagihanCard(TagihanModel tagihan) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (tagihan.status) {
      case 'sudah_bayar':
      case 'Lunas':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Lunas';
        break;
      case 'terlambat':
      case 'Terlambat':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.error_rounded;
        statusText = 'Terlambat';
        break;
      default:
        statusColor = const Color(0xFFFBBF24);
        statusIcon = Icons.pending_rounded;
        statusText = 'Belum Bayar';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tagihan.userName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(tagihan.nominal),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F80ED),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                // ⭐ UPDATED: Show "Lihat Bukti" button for Lunas status (monitoring only)
                if (tagihan.status == 'Lunas' &&
                    tagihan.buktiPembayaran != null &&
                    tagihan.buktiPembayaran!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showBuktiPembayaran(tagihan.buktiPembayaran!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 14),
                    label: Text(
                      'Lihat Bukti',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                // Show "Menunggu Pembayaran" if no payment yet
                if ((tagihan.status == 'belum_bayar' || tagihan.status == 'Belum Dibayar') &&
                    (tagihan.buktiPembayaran == null ||
                     tagihan.buktiPembayaran!.isEmpty)) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Menunggu\nPembayaran',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Tagihan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate tagihan untuk warga',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Data',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba filter lain',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ NEW: Show payment proof dialog (monitoring only)
  void _showBuktiPembayaran(String imageUrl) {
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
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 400,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat gambar',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPayment(TagihanModel tagihan) async {
    // Show confirmation dialog with payment proof
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Verifikasi Pembayaran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warga: ${tagihan.userName}',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Nominal: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(tagihan.nominal)}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              'Bukti Pembayaran:',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (tagihan.buktiPembayaran != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    tagihan.buktiPembayaran!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text('Gagal memuat gambar'),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Verifikasi pembayaran ini?',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Verifikasi',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Get current admin ID from FirebaseAuth
        final currentUser = FirebaseAuth.instance.currentUser;

        await _iuranService.updateTagihanStatus(
          tagihan.id,
          'sudah_bayar',
          metodePembayaran: tagihan.metodePembayaran ?? 'transfer',
          buktiPembayaran: tagihan.buktiPembayaran,
          verifiedBy: currentUser?.uid,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pembayaran berhasil diverifikasi',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal memverifikasi pembayaran: $e',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _regenerateTagihan() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Generate Ulang Tagihan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Ini akan membuat tagihan untuk semua warga yang belum punya tagihan untuk iuran ini.\n\nTagihan yang sudah ada TIDAK akan terhapus.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Generate',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Generating tagihan...',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );
      }

      try {
        // Generate tagihan untuk semua warga yang belum punya
        final count = await _iuranService.generateTagihanForAllUsers(widget.iuran.id);

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Berhasil! $count tagihan baru telah di-generate.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Refresh page
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal generate tagihan: $e',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleStatus() async {
    try {
      final newStatus = widget.iuran.status == 'aktif' ? 'nonaktif' : 'aktif';
      await _iuranService.updateStatusIuran(widget.iuran.id, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status iuran berhasil diubah menjadi $newStatus',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengubah status: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Iuran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus iuran ini? Semua tagihan terkait juga akan dihapus.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _iuranService.deleteIuran(widget.iuran.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Iuran berhasil dihapus',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menghapus iuran: $e',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

