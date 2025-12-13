// ============================================================================
// POLL CARD WIDGET
// ============================================================================
// Card untuk menampilkan polling dalam list
// Mendukung official dan community poll dengan badge berbeda
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/models/poll_model.dart';
import 'package:intl/intl.dart';

class PollCard extends StatelessWidget {
  final Poll poll;
  final bool hasVoted;
  final VoidCallback onTap;
  final bool showCreator;

  const PollCard({
    super.key,
    required this.poll,
    this.hasVoted = false,
    required this.onTap,
    this.showCreator = true,
  });

  @override
  Widget build(BuildContext context) {
    final isOfficial = poll.pollLevel == 'official';
    final isActive = poll.isActive;
    final isClosed = poll.isClosed;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Badge + Status
              Row(
                children: [
                  // Poll Level Badge
                  _buildBadge(
                    label: isOfficial ? 'RESMI' : 'KOMUNITAS',
                    icon: isOfficial ? Icons.verified_rounded : Icons.groups_rounded,
                    gradient: isOfficial
                        ? const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                          ),
                  ),
                  const Spacer(),

                  // Status Badge
                  if (isClosed)
                    _buildStatusBadge(
                      label: 'DITUTUP',
                      color: Colors.grey.shade400,
                    )
                  else if (hasVoted)
                    _buildStatusBadge(
                      label: 'SUDAH VOTE',
                      color: const Color(0xFF10B981),
                    )
                  else if (poll.isEndingSoon)
                    _buildStatusBadge(
                      label: 'SEGERA BERAKHIR',
                      color: const Color(0xFFEF4444),
                    ),
                ],
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

              // Description
              Text(
                poll.description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Creator Info (for community polls)
              if (showCreator && !isOfficial) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundImage: poll.createdByPhoto != null
                          ? NetworkImage(poll.createdByPhoto!)
                          : null,
                      child: poll.createdByPhoto == null
                          ? const Icon(Icons.person, size: 12)
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Oleh ${poll.createdByName}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Stats Row
              Row(
                children: [
                  // Vote Count
                  _buildStatChip(
                    icon: Icons.how_to_vote_rounded,
                    label: '${poll.totalVotes} suara',
                    color: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),

                  // Time Remaining
                  if (isActive)
                    _buildStatChip(
                      icon: Icons.access_time_rounded,
                      label: _formatTimeRemaining(poll.timeRemaining),
                      color: poll.isEndingSoon
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF6B7280),
                    ),

                  const Spacer(),

                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),

              // Progress Bar
              if (isActive) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: poll.totalVotes > 0 ? poll.totalVotes / 100 : 0,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOfficial
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build badge untuk poll level
  Widget _buildBadge({
    required String label,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// Build stat chip
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Format time remaining
  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}h lagi';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}j lagi';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m lagi';
    } else {
      return 'Segera berakhir';
    }
  }
}

