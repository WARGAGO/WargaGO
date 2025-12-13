// ============================================================================
// HOME POLL ALERT WIDGET
// ============================================================================
// Alert banner untuk menampilkan polling aktif di home page
// Mendukung polling resmi (official) dan komunitas (community)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/models/poll_model.dart';

class HomePollAlert extends StatelessWidget {
  final Poll? activeOfficialPoll;
  final int communityPollCount;
  final bool hasUserVoted;
  final VoidCallback onViewPollTap;
  final VoidCallback onVoteTap;  // Changed to required (no ?)
  final VoidCallback onViewAllCommunityTap;  // Changed to required (no ?)

  const HomePollAlert({
    super.key,
    this.activeOfficialPoll,
    this.communityPollCount = 0,
    this.hasUserVoted = false,
    required this.onViewPollTap,
    required this.onVoteTap,  // Now required
    required this.onViewAllCommunityTap,  // Now required
  });

  @override
  Widget build(BuildContext context) {
    // Jika tidak ada polling aktif sama sekali
    if (activeOfficialPoll == null && communityPollCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Official Poll Alert
        if (activeOfficialPoll != null) ...[
          _buildOfficialPollAlert(context),
          if (communityPollCount > 0) const SizedBox(height: 12),
        ],

        // Community Polls Alert
        if (communityPollCount > 0) _buildCommunityPollsAlert(context),
      ],
    );
  }

  /// Build official poll alert (prioritas tinggi)
  Widget _buildOfficialPollAlert(BuildContext context) {
    final poll = activeOfficialPoll!;
    final timeRemaining = poll.endDate.difference(DateTime.now());
    final daysLeft = timeRemaining.inDays;
    final hoursLeft = timeRemaining.inHours % 24;

    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('🗳️ [HomePollAlert] Official poll card tapped');
        }
        if (hasUserVoted) {
          onViewPollTap();
        } else {
          onVoteTap();
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
                onPressed: () {
                  if (kDebugMode) {
                    print('🗳️ [HomePollAlert] Official poll button tapped');
                    print('   hasUserVoted: $hasUserVoted');
                    print('   Calling: ${hasUserVoted ? "onViewPollTap" : "onVoteTap"}');
                  }
                  if (hasUserVoted) {
                    onViewPollTap();
                  } else {
                    onVoteTap();
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
                      hasUserVoted
                          ? Icons.poll_rounded
                          : Icons.how_to_vote_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasUserVoted ? 'Lihat Hasil' : 'Vote Sekarang',
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
      onTap: () {
        if (kDebugMode) {
          print('🗳️ [HomePollAlert] Community polls card tapped');
        }
        onViewAllCommunityTap();
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
                          '$communityPollCount',
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
                    print('   communityPollCount: $communityPollCount');
                    print('   Calling: onViewAllCommunityTap');
                  }
                  onViewAllCommunityTap();
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

