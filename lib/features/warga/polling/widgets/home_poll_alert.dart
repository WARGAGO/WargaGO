// ============================================================================
// HOME POLL ALERT WIDGET
// ============================================================================
// Alert banner untuk menampilkan polling aktif di home page
// Mendukung polling resmi (official) dan komunitas (community)
// ⭐ FITUR BARU: Auto-dismiss setelah user buka halaman polling
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wargago/core/models/poll_model.dart';

class HomePollAlert extends StatefulWidget {
  final Poll? activeOfficialPoll;
  final int communityPollCount;
  final bool hasUserVoted;
  final VoidCallback onViewPollTap;
  final VoidCallback onVoteTap;
  final VoidCallback onViewAllCommunityTap;

  const HomePollAlert({
    super.key,
    this.activeOfficialPoll,
    this.communityPollCount = 0,
    this.hasUserVoted = false,
    required this.onViewPollTap,
    required this.onVoteTap,
    required this.onViewAllCommunityTap,
  });

  @override
  State<HomePollAlert> createState() => _HomePollAlertState();
}

class _HomePollAlertState extends State<HomePollAlert> {
  bool _isOfficialDismissed = false;
  bool _isCommunityDismissed = false;

  @override
  void initState() {
    super.initState();
    _loadDismissedState();
  }

  /// Load dismissed state dari SharedPreferences
  Future<void> _loadDismissedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check official poll dismissed state
      if (widget.activeOfficialPoll != null) {
        final key = 'poll_dismissed_${widget.activeOfficialPoll!.pollId}';
        final isDismissed = prefs.getBool(key) ?? false;

        if (mounted) {
          setState(() {
            _isOfficialDismissed = isDismissed;
          });
        }
      }

      // Check community polls dismissed state
      final communityKey = 'community_polls_dismissed';
      final lastDismissed = prefs.getInt(communityKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Auto show lagi setelah 1 jam
      if (now - lastDismissed < 3600000) {
        if (mounted) {
          setState(() {
            _isCommunityDismissed = true;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading dismissed state: $e');
      }
    }
  }

  /// Mark official poll sebagai dismissed (sementara)
  Future<void> _dismissOfficialPoll() async {
    if (widget.activeOfficialPoll == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'poll_dismissed_${widget.activeOfficialPoll!.pollId}';
      await prefs.setBool(key, true);

      if (mounted) {
        setState(() {
          _isOfficialDismissed = true;
        });
      }

      if (kDebugMode) {
        print('✅ Official poll dismissed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error dismissing official poll: $e');
      }
    }
  }

  /// Mark community polls sebagai dismissed (sementara - 1 jam)
  Future<void> _dismissCommunityPolls() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'community_polls_dismissed';
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(key, now);

      if (mounted) {
        setState(() {
          _isCommunityDismissed = true;
        });
      }

      if (kDebugMode) {
        print('✅ Community polls dismissed for 1 hour');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error dismissing community polls: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika tidak ada polling aktif sama sekali
    final hasOfficialPoll = widget.activeOfficialPoll != null && !_isOfficialDismissed;
    final hasCommunityPolls = widget.communityPollCount > 0 && !_isCommunityDismissed;

    if (!hasOfficialPoll && !hasCommunityPolls) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Official Poll Alert
        if (hasOfficialPoll) ...[
          _buildOfficialPollAlert(context),
          if (hasCommunityPolls) const SizedBox(height: 12),
        ],

        // Community Polls Alert
        if (hasCommunityPolls) _buildCommunityPollsAlert(context),
      ],
    );
  }

  /// Build official poll alert (prioritas tinggi)
  Widget _buildOfficialPollAlert(BuildContext context) {
    final poll = widget.activeOfficialPoll!;
    final timeRemaining = poll.endDate.difference(DateTime.now());
    final daysLeft = timeRemaining.inDays;
    final hoursLeft = timeRemaining.inHours % 24;

    return GestureDetector(
      onTap: () async {
        if (kDebugMode) {
          print('🗳️ [HomePollAlert] Official poll card tapped');
        }

        // ⭐ Dismiss alert setelah diklik
        await _dismissOfficialPoll();

        // Navigate ke halaman poll
        if (widget.hasUserVoted) {
          widget.onViewPollTap();
        } else {
          widget.onVoteTap();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3B82F6), // Blue-500
              Color(0xFF8B5CF6), // Purple-500
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.how_to_vote_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),

                // Badge
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'POLLING RESMI AKTIF',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              poll.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.2,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Stats Row
            Row(
              children: [
                // Timer
                _buildStatItem(
                  icon: Icons.access_time_rounded,
                  label: daysLeft > 0
                      ? 'Berakhir dalam $daysLeft hari ${hoursLeft}j'
                      : hoursLeft > 0
                          ? 'Berakhir dalam $hoursLeft jam'
                          : 'Berakhir dalam ${timeRemaining.inMinutes} menit',
                ),
                const SizedBox(width: 16),

                // Voters
                _buildStatItem(
                  icon: Icons.people_rounded,
                  label: '${poll.totalVotes} suara',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () async {
                  if (kDebugMode) {
                    print('🗳️ [HomePollAlert] Official poll button tapped');
                    print('   hasUserVoted: ${widget.hasUserVoted}');
                    print('   Calling: ${widget.hasUserVoted ? "onViewPollTap" : "onVoteTap"}');
                  }

                  // ⭐ Dismiss alert setelah diklik
                  await _dismissOfficialPoll();

                  // Navigate ke halaman poll
                  if (widget.hasUserVoted) {
                    widget.onViewPollTap();
                  } else {
                    widget.onVoteTap();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.hasUserVoted
                          ? Icons.poll_rounded
                          : Icons.how_to_vote_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.hasUserVoted ? 'Lihat Hasil' : 'Vote Sekarang',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build community polls alert
  Widget _buildCommunityPollsAlert(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (kDebugMode) {
          print('🗳️ [HomePollAlert] Community polls card tapped');
        }

        // ⭐ Dismiss alert setelah diklik (1 jam)
        await _dismissCommunityPolls();

        // Navigate ke halaman community polls
        widget.onViewAllCommunityTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF59E0B), // Orange-500
              Color(0xFFEC4899), // Pink-500
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.groups_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.communityPollCount}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'POLLING KOMUNITAS AKTIF',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Arisan, Kerja Bakti & Lainnya',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  if (kDebugMode) {
                    print('🗳️ [HomePollAlert] Community polls button tapped');
                    print('   communityPollCount: ${widget.communityPollCount}');
                    print('   Calling: onViewAllCommunityTap');
                  }
                  widget.onViewAllCommunityTap();
                },
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build stat item untuk info kecil
  Widget _buildStatItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

