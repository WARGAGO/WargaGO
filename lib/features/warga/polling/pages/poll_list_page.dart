// ============================================================================
// POLL LIST PAGE
// ============================================================================
// Halaman utama untuk melihat list polling
// Tab: Resmi, Komunitas, Saya Buat, Riwayat
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/providers/poll_provider.dart';
import 'package:wargago/core/providers/auth_provider.dart';
import 'package:wargago/features/warga/polling/widgets/poll_card.dart';
import 'package:wargago/features/warga/polling/pages/poll_detail_page.dart';
import 'package:wargago/features/warga/polling/pages/poll_create_page.dart';

class PollListPage extends StatefulWidget {
  const PollListPage({super.key});

  @override
  State<PollListPage> createState() => _PollListPageState();
}

class _PollListPageState extends State<PollListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load polls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pollProvider = context.read<PollProvider>();
      final authProvider = context.read<AuthProvider>();

      pollProvider.loadActiveOfficialPolls();
      pollProvider.loadActiveCommunityPolls();

      if (authProvider.userModel != null) {
        pollProvider.loadMyPolls(authProvider.userModel!.id);
      }
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
          'Polling',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
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
                    setState(() {});
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
                  Tab(text: 'Resmi'),
                  Tab(text: 'Komunitas'),
                  Tab(text: 'Saya Buat'),
                  Tab(text: 'Riwayat'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOfficialPollsTab(),
          _buildCommunityPollsTab(),
          _buildMyPollsTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PollCreatePage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Buat Polling',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Tab untuk polling resmi
  Widget _buildOfficialPollsTab() {
    return Consumer2<PollProvider, AuthProvider>(
      builder: (context, pollProvider, authProvider, child) {
        final polls = pollProvider.activeOfficialPolls;

        if (polls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.how_to_vote_rounded,
            title: 'Belum Ada Polling Resmi',
            subtitle: 'Polling resmi dari admin akan muncul di sini',
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
              return PollCard(
                poll: poll,
                hasVoted: false, // TODO: Check if user has voted
                showCreator: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PollDetailPage(pollId: poll.pollId),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Tab untuk polling komunitas
  Widget _buildCommunityPollsTab() {
    return Consumer2<PollProvider, AuthProvider>(
      builder: (context, pollProvider, authProvider, child) {
        final polls = pollProvider.activeCommunityPolls;

        if (polls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.groups_rounded,
            title: 'Belum Ada Polling Komunitas',
            subtitle: 'Buat polling komunitas untuk kesepakatan bersama',
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
              return PollCard(
                poll: poll,
                hasVoted: false, // TODO: Check if user has voted
                showCreator: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PollDetailPage(pollId: poll.pollId),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Tab untuk polling yang saya buat
  Widget _buildMyPollsTab() {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, child) {
        final polls = pollProvider.myPolls;

        if (polls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.ballot_rounded,
            title: 'Belum Ada Polling',
            subtitle: 'Anda belum membuat polling. Buat sekarang!',
            actionLabel: 'Buat Polling',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PollCreatePage(),
                ),
              );
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final authProvider = context.read<AuthProvider>();
            if (authProvider.userModel != null) {
              pollProvider.loadMyPolls(authProvider.userModel!.id);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              return PollCard(
                poll: poll,
                hasVoted: false,
                showCreator: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PollDetailPage(pollId: poll.pollId),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Tab untuk riwayat polling
  Widget _buildHistoryTab() {
    return Consumer<PollProvider>(
      builder: (context, pollProvider, child) {
        final polls = pollProvider.pollHistory;

        if (polls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_rounded,
            title: 'Belum Ada Riwayat',
            subtitle: 'Polling yang sudah ditutup akan muncul di sini',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: polls.length,
          itemBuilder: (context, index) {
            final poll = polls[index];
            return PollCard(
              poll: poll,
              hasVoted: true,
              showCreator: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PollDetailPage(pollId: poll.pollId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  actionLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

