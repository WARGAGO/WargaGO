// ============================================================================
// ADMIN POLL MODERATION PAGE
// ============================================================================
// Halaman untuk moderasi polling komunitas yang dilaporkan
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/providers/poll_provider.dart';
import 'package:wargago/features/admin/polling/widgets/admin_poll_card.dart';
import 'package:wargago/features/admin/polling/pages/admin_poll_analytics_page.dart';

class AdminPollModerationPage extends StatefulWidget {
  const AdminPollModerationPage({super.key});

  @override
  State<AdminPollModerationPage> createState() =>
      _AdminPollModerationPageState();
}

class _AdminPollModerationPageState extends State<AdminPollModerationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load community polls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pollProvider = context.read<PollProvider>();
      pollProvider.loadActiveCommunityPolls();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Moderasi Polling',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          indicatorColor: const Color(0xFF3B82F6),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Dilaporkan'),
            Tab(text: 'Semua Komunitas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportedPollsTab(),
          _buildAllCommunityPollsTab(),
        ],
      ),
    );
  }

  /// Tab untuk polling yang dilaporkan
  Widget _buildReportedPollsTab() {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, child) {
        final reportedPolls = pollProvider.activeCommunityPolls
            .where((p) => p.isReported)
            .toList();

        if (reportedPolls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.flag_outlined,
            title: 'Tidak Ada Laporan',
            subtitle: 'Belum ada polling komunitas yang dilaporkan',
            color: const Color(0xFF10B981),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            pollProvider.loadActiveCommunityPolls();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportedPolls.length,
            itemBuilder: (context, index) {
              final poll = reportedPolls[index];
              return _buildReportedPollCard(poll);
            },
          ),
        );
      },
    );
  }

  /// Tab untuk semua polling komunitas
  Widget _buildAllCommunityPollsTab() {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, child) {
        final communityPolls = pollProvider.activeCommunityPolls;

        if (communityPolls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.groups_rounded,
            title: 'Belum Ada Polling',
            subtitle: 'Belum ada polling komunitas yang dibuat warga',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            pollProvider.loadActiveCommunityPolls();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: communityPolls.length,
            itemBuilder: (context, index) {
              final poll = communityPolls[index];
              return AdminPollCard(
                poll: poll,
                onTap: () => _navigateToDetail(poll.pollId),
                onPin: () => _togglePin(poll.pollId, !poll.isPinned),
                onClose: poll.isActive ? () => _closePoll(poll.pollId) : null,
                onDelete: () => _deletePoll(poll.pollId),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildReportedPollCard(poll) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetail(poll.pollId),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'DILAPORKAN (${poll.reportCount})',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEF4444),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                poll.title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                  letterSpacing: -0.2,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Creator
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    'Dibuat oleh ${poll.createdByName}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Report Reasons
              if (poll.reportReasons != null && poll.reportReasons!.isNotEmpty) ...[
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  'Alasan Laporan:',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                ...poll.reportReasons!.map((reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reason,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
              ],

              // Action Buttons
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _approvePoll(poll.pollId),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(
                        'Setujui',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF10B981),
                        side: const BorderSide(color: Color(0xFF10B981)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _deletePoll(poll.pollId),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        'Hapus',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                      ),
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

  void _navigateToDetail(String pollId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPollAnalyticsPage(pollId: pollId),
      ),
    );
  }

  Future<void> _approvePoll(String pollId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Setujui Polling?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Polling akan tetap aktif dan laporan akan dihapus.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: Text(
              'Setujui',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Implement approve poll (clear reports)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Polling disetujui',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _togglePin(String pollId, bool isPinned) async {
    final pollProvider = context.read<PollProvider>();
    final success = await pollProvider.togglePinPoll(pollId, isPinned);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPinned ? 'Polling di-pin' : 'Polling di-unpin',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _closePoll(String pollId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tutup Polling?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Polling akan ditutup dan tidak bisa menerima vote lagi.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final pollProvider = context.read<PollProvider>();
      final success = await pollProvider.closePoll(pollId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Polling berhasil ditutup',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _deletePoll(String pollId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Polling?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Polling akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final pollProvider = context.read<PollProvider>();
      final success = await pollProvider.deletePoll(pollId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Polling berhasil dihapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (color ?? const Color(0xFF3B82F6)).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: color ?? const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

