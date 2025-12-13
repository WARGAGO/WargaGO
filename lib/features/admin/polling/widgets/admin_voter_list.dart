// ============================================================================
// ADMIN VOTER LIST WIDGET
// ============================================================================
// List pemilih dengan detail siapa memilih apa
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/poll_vote_model.dart';

class AdminVoterList extends StatelessWidget {
  final List<PollVote> votes;

  const AdminVoterList({
    super.key,
    required this.votes,
  });

  @override
  Widget build(BuildContext context) {
    // Sort by latest first
    final sortedVotes = List<PollVote>.from(votes)
      ..sort((a, b) => b.votedAt.compareTo(a.votedAt));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: sortedVotes.length > 10 ? 10 : sortedVotes.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final vote = sortedVotes[index];
        return _buildVoterItem(vote);
      },
    );
  }

  Widget _buildVoterItem(PollVote vote) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue[100],
            backgroundImage: vote.userPhoto != null
                ? NetworkImage(vote.userPhoto!)
                : null,
            child: vote.userPhoto == null
                ? Text(
                    vote.userName.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vote.userName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        vote.optionText,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(vote.votedAt),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                DateFormat('dd MMM').format(vote.votedAt),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

