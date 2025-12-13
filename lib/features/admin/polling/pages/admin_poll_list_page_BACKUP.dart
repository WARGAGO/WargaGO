// ============================================================================
// ADMIN POLL LIST PAGE
// ============================================================================
// Halaman untuk admin manage semua polling
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/providers/poll_provider.dart';
import 'package:wargago/features/admin/polling/widgets/admin_poll_card.dart';
import 'package:wargago/features/admin/polling/pages/admin_poll_create_page.dart';
import 'package:wargago/features/admin/polling/pages/admin_poll_analytics_page.dart';
import 'package:wargago/features/admin/polling/pages/admin_poll_moderation_page.dart';

class AdminPollListPage extends StatefulWidget {
  const AdminPollListPage({super.key});

  @override
  State<AdminPollListPage> createState() => _AdminPollListPageState();
}

class _AdminPollListPageState extends State<AdminPollListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load polls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pollProvider = context.read<PollProvider>();
      pollProvider.loadActiveOfficialPolls();
      pollProvider.loadActiveCommunityPolls();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
          'Kelola Polling',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        actions: [
          // Moderation button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPollModerationPage(),
                ),
              );
            },
            icon: Stack(
              children: [
                const Icon(Icons.flag_outlined, color: Color(0xFF6B7280)),
                Consumer<PollProvider>(
                  builder: (context, provider, child) {
                    final reportedCount = provider.activeCommunityPolls
                        .where((p) => p.isReported)
                        .length;

                    if (reportedCount == 0) return const SizedBox.shrink();

                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$reportedCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari polling...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF9CA3AF),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF3B82F6),
                unselectedLabelColor: const Color(0xFF9CA3AF),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                indicatorColor: const Color(0xFF3B82F6),
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Semua'),
                  Tab(text: 'Resmi'),
                  Tab(text: 'Komunitas'),
                  Tab(text: 'Ditutup'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllPollsTab(),
          _buildOfficialPollsTab(),
          _buildCommunityPollsTab(),
          _buildClosedPollsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminPollCreatePage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Buat Polling Resmi',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Tab untuk semua polling
  Widget _buildAllPollsTab() {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, child) {
        final allPolls = [
          ...pollProvider.activeOfficialPolls,
          ...pollProvider.activeCommunityPolls,
        ];

        final filteredPolls = _filterPolls(allPolls);

        if (filteredPolls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.how_to_vote_rounded,
            title: _searchQuery.isEmpty
                ? 'Belum Ada Polling'
                : 'Polling Tidak Ditemukan',
            subtitle: _searchQuery.isEmpty
                ? 'Buat polling resmi untuk dimulai'
                : 'Coba kata kunci lain',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            pollProvider.loadActiveOfficialPolls();
            pollProvider.loadActiveCommunityPolls();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredPolls.length,
            itemBuilder: (context, index) {
              final poll = filteredPolls[index];
              return AdminPollCard(
                poll: poll,
                onTap: () => _navigateToDetail(poll.pollId),
                onViewAnalytics: () => _navigateToAnalytics(poll.pollId),
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

  /// Tab untuk polling resmi
  Widget _buildOfficialPollsTab() {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, child) {
        final polls = _filterPolls(pollProvider.activeOfficialPolls);

        if (polls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.verified_rounded,
            title: _searchQuery.isEmpty
                ? 'Belum Ada Polling Resmi'
                : 'Polling Tidak Ditemukan',
            subtitle: _searchQuery.isEmpty
                ? 'Buat polling resmi dari admin'
                : 'Coba kata kunci lain',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            pollProvider.loadActiveOfficialPolls();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              return AdminPollCard(
                poll: poll,
                onTap: () => _navigateToDetail(poll.pollId),
                onViewAnalytics: () => _navigateToAnalytics(poll.pollId),
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

  /// Tab untuk polling komunitas
  Widget _buildCommunityPollsTab() {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, child) {
        final polls = _filterPolls(pollProvider.activeCommunityPolls);

        if (polls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.groups_rounded,
            title: _searchQuery.isEmpty
                ? 'Belum Ada Polling Komunitas'
                : 'Polling Tidak Ditemukan',
            subtitle: _searchQuery.isEmpty
                ? 'Warga belum membuat polling komunitas'
                : 'Coba kata kunci lain',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            pollProvider.loadActiveCommunityPolls();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              return AdminPollCard(
                poll: poll,
                onTap: () => _navigateToDetail(poll.pollId),
                onViewAnalytics: () => _navigateToAnalytics(poll.pollId),
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

  /// Tab untuk polling yang ditutup
  Widget _buildClosedPollsTab() {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, child) {
        final closedPolls = [
          ...pollProvider.activeOfficialPolls,
          ...pollProvider.activeCommunityPolls,
        ].where((p) => p.isClosed).toList();

        final filteredPolls = _filterPolls(closedPolls);

        if (filteredPolls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_rounded,
            title: 'Belum Ada Polling Ditutup',
            subtitle: 'Polling yang sudah ditutup akan muncul di sini',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredPolls.length,
          itemBuilder: (context, index) {
            final poll = filteredPolls[index];
            return AdminPollCard(
              poll: poll,
              onTap: () => _navigateToDetail(poll.pollId),
              onViewAnalytics: () => _navigateToAnalytics(poll.pollId),
              onDelete: () => _deletePoll(poll.pollId),
            );
          },
        );
      },
    );
  }

  /// Filter polls by search query
  List _filterPolls(List polls) {
    if (_searchQuery.isEmpty) return polls;

    return polls.where((poll) {
      return poll.title.toLowerCase().contains(_searchQuery) ||
          poll.description.toLowerCase().contains(_searchQuery) ||
          poll.createdByName.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  /// Navigate to analytics page (Admin hanya analytics, tidak detail!)
  void _navigateToDetail(String pollId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPollAnalyticsPage(pollId: pollId),
      ),
    );
  }

  /// Navigate to analytics page
  void _navigateToAnalytics(String pollId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPollAnalyticsPage(pollId: pollId),
      ),
    );
  }

  /// Toggle pin poll
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

  /// Close poll
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

  /// Delete poll
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

  /// Build empty state
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
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
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: const Color(0xFF3B82F6),
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

