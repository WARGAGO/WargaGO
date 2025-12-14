// ============================================================================
// ADMIN POLL LIST PAGE - MODERN & BEAUTIFUL UI
// ============================================================================
// Halaman kelola polling dengan tampilan modern & menarik
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/providers/poll_provider.dart';
import 'package:wargago/core/models/poll_model.dart';
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Modern App Bar with Gradient
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 200,
              collapsedHeight: 24,
              toolbarHeight: 24,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.ballot_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kelola Polling',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manajemen & Monitoring',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Moderation Button with Badge
                              _buildModerationButton(),
                            ],
                          ),
                          const Spacer(),

                          // Search Bar (at bottom of expanded area)
                          _buildSearchBar(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: _buildModernTabs(),
                ),
              ),
            ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllPollsTab(),
              _buildOfficialPollsTab(),
              _buildCommunityPollsTab(),
              _buildClosedPollsTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildModernFAB(),
    );
  }

  // ============================================================================
  // UI COMPONENTS
  // ============================================================================

  Widget _buildModerationButton() {
    return Consumer<PollProvider>(
      builder: (context, provider, child) {
        final reportedCount = provider.activeCommunityPolls
            .where((p) => p.isReported)
            .length;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPollModerationPage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    if (reportedCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            '$reportedCount',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: 'Cari polling berdasarkan judul...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF9CA3AF),
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF3B82F6),
              size: 22,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.clear_rounded,
                      color: Color(0xFF3B82F6),
                      size: 16,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildModernTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: const Color(0xFF3B82F6),
      unselectedLabelColor: const Color(0xFF9CA3AF),
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      indicator: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF3B82F6), width: 3),
        ),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: const [
        Tab(
          icon: Icon(Icons.grid_view_rounded, size: 18),
          iconMargin: EdgeInsets.only(bottom: 4),
          text: 'Semua',
        ),
        Tab(
          icon: Icon(Icons.verified_rounded, size: 18),
          iconMargin: EdgeInsets.only(bottom: 4),
          text: 'Resmi',
        ),
        Tab(
          icon: Icon(Icons.groups_rounded, size: 18),
          iconMargin: EdgeInsets.only(bottom: 4),
          text: 'Komun.',
        ),
        Tab(
          icon: Icon(Icons.archive_rounded, size: 18),
          iconMargin: EdgeInsets.only(bottom: 4),
          text: 'Tutup',
        ),
      ],
    );
  }

  Widget _buildModernFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminPollCreatePage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Buat Polling Resmi',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // TAB VIEWS
  // ============================================================================

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
            icon: Icons.ballot_rounded,
            title: _searchQuery.isEmpty
                ? 'Belum Ada Polling'
                : 'Polling Tidak Ditemukan',
            subtitle: _searchQuery.isEmpty
                ? 'Buat polling resmi untuk memulai'
                : 'Coba kata kunci pencarian lain',
            color: const Color(0xFF3B82F6),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF3B82F6),
          onRefresh: () async {
            pollProvider.loadActiveOfficialPolls();
            pollProvider.loadActiveCommunityPolls();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredPolls.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final poll = filteredPolls[index];
              return AdminPollCard(
                poll: poll,
                onTap: () => _navigateToAnalytics(poll.pollId),
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
                ? 'Polling resmi dibuat oleh admin'
                : 'Coba kata kunci pencarian lain',
            color: const Color(0xFF3B82F6),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF3B82F6),
          onRefresh: () async {
            pollProvider.loadActiveOfficialPolls();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: polls.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final poll = polls[index];
              return AdminPollCard(
                poll: poll,
                onTap: () => _navigateToAnalytics(poll.pollId),
                onViewAnalytics: () => _navigateToAnalytics(poll.pollId),
                onPin: () => _togglePin(poll.pollId, !poll.isPinned),
                onClose: poll.status == 'active' ? () => _closePoll(poll.pollId) : null,
                onDelete: () => _deletePoll(poll.pollId),
              );
            },
          ),
        );
      },
    );
  }

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
                ? 'Polling komunitas dibuat oleh warga'
                : 'Coba kata kunci pencarian lain',
            color: const Color(0xFF10B981),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF10B981),
          onRefresh: () async {
            pollProvider.loadActiveCommunityPolls();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: polls.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final poll = polls[index];
              return AdminPollCard(
                poll: poll,
                onTap: () => _navigateToAnalytics(poll.pollId),
                onViewAnalytics: () => _navigateToAnalytics(poll.pollId),
                onPin: () => _togglePin(poll.pollId, !poll.isPinned),
                onClose: poll.status == 'active' ? () => _closePoll(poll.pollId) : null,
                onDelete: () => _deletePoll(poll.pollId),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildClosedPollsTab() {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, child) {
        // TODO: Load closed polls
        final closedPolls = <Poll>[];

        if (closedPolls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.archive_rounded,
            title: 'Belum Ada Polling Ditutup',
            subtitle: 'Polling yang sudah ditutup akan muncul di sini',
            color: const Color(0xFF9CA3AF),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: closedPolls.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final poll = closedPolls[index];
            return AdminPollCard(
              poll: poll,
              onTap: () => _navigateToAnalytics(poll.pollId),
              onViewAnalytics: () => _navigateToAnalytics(poll.pollId),
              onPin: null, // Can't pin closed polls
              onClose: null, // Already closed
              onDelete: () => _deletePoll(poll.pollId),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: color.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  List<Poll> _filterPolls(List<Poll> polls) {
    if (_searchQuery.isEmpty) return polls;

    return polls.where((poll) {
      return poll.title.toLowerCase().contains(_searchQuery) ||
          poll.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _navigateToAnalytics(String pollId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPollAnalyticsPage(pollId: pollId),
      ),
    );
  }

  void _togglePin(String pollId, bool isPinned) {
    // TODO: Implement pin/unpin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPinned ? 'Polling dipasang' : 'Polling dilepas',
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _closePoll(String pollId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Tutup Polling?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Polling yang ditutup tidak dapat dibuka kembali',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Close poll
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _deletePoll(String pollId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Polling?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Polling yang dihapus tidak dapat dikembalikan',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Delete poll
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
