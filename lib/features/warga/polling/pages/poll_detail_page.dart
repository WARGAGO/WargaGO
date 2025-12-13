// ============================================================================
// POLL DETAIL PAGE
// ============================================================================
// Halaman detail polling dengan real-time results & bar chart animation
// Support voting dan melihat hasil secara real-time
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/providers/poll_provider.dart';
import 'package:wargago/core/providers/auth_provider.dart';
import 'package:wargago/features/warga/polling/widgets/poll_option_card.dart';
import 'package:wargago/features/warga/polling/widgets/poll_countdown_timer.dart';
import 'package:intl/intl.dart';

class PollDetailPage extends StatefulWidget {
  final String pollId;

  const PollDetailPage({
    super.key,
    required this.pollId,
  });

  @override
  State<PollDetailPage> createState() => _PollDetailPageState();
}

class _PollDetailPageState extends State<PollDetailPage> {
  String? _selectedOptionId;

  @override
  void initState() {
    super.initState();

    // Load poll detail dengan real-time updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pollProvider = context.read<PollProvider>();
      final authProvider = context.read<AuthProvider>();

      pollProvider.loadPollDetail(widget.pollId);

      if (authProvider.userModel != null) {
        pollProvider.checkUserVoteStatus(
          widget.pollId,
          authProvider.userModel!.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Detail Polling',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Share functionality
            },
            icon: const Icon(Icons.share_rounded, color: Color(0xFF6B7280)),
          ),
          IconButton(
            onPressed: () {
              _showMoreOptions(context);
            },
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF6B7280)),
          ),
        ],
      ),
      body: Consumer2<PollProvider, AuthProvider>(
        builder: (context, pollProvider, authProvider, child) {
          final poll = pollProvider.currentPoll;
          final options = pollProvider.currentOptions;
          final hasVoted = pollProvider.hasUserVoted;
          final userVote = pollProvider.userVote;

          if (poll == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isActive = poll.isActive;
          final isOfficial = poll.isOfficial;
          final canVote = isActive && !hasVoted;

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poll Header
                        _buildPollHeader(poll, isOfficial),

                        // Poll Info
                        _buildPollInfo(poll),

                        // Options/Results Section
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    canVote ? Icons.how_to_vote_rounded : Icons.poll_rounded,
                                    size: 20,
                                    color: const Color(0xFF3B82F6),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    canVote ? 'Pilih Opsi' : 'Hasil Voting',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (!canVote)
                                    Text(
                                      '${poll.totalVotes} suara',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF3B82F6),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Options List (REAL-TIME!)
                              if (options.isEmpty)
                                const SizedBox(
                                  height: 100,
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              else
                                ...options.asMap().entries.map((entry) {
                                  final option = entry.value;
                                  final isSelected = _selectedOptionId == option.optionId;
                                  final isUserVote = userVote?.optionId == option.optionId;

                                  return Padding(
                                    key: ValueKey('poll_option_${option.optionId}'),
                                    padding: EdgeInsets.only(
                                      bottom: entry.key < options.length - 1 ? 12 : 0,
                                    ),
                                    child: PollOptionCard(
                                      key: ValueKey('option_card_${option.optionId}'),
                                      option: option,
                                      isVotingMode: canVote,
                                      isSelected: isSelected || isUserVote,
                                      hasVoted: hasVoted,
                                      totalVotes: poll.totalVotes,
                                      showAnimation: true,
                                      onTap: canVote ? () {
                                        setState(() {
                                          _selectedOptionId = option.optionId;
                                        });
                                      } : null,
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Vote Info (if already voted)
                        if (hasVoted && userVote != null)
                          _buildVoteInfo(userVote.votedAt),

                        // Voter List Preview
                        _buildVoterListPreview(pollProvider),

                        const SizedBox(height: 80), // Space for button
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer2<PollProvider, AuthProvider>(
        builder: (context, pollProvider, authProvider, child) {
          final poll = pollProvider.currentPoll;
          final hasVoted = pollProvider.hasUserVoted;
          final isSubmitting = pollProvider.isSubmittingVote;

          if (poll == null) return const SizedBox.shrink();

          final canVote = poll.isActive && !hasVoted;

          if (!canVote) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedOptionId != null && !isSubmitting
                      ? () => _submitVote(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.how_to_vote_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Kirim Vote',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build poll header
  Widget _buildPollHeader(poll, bool isOfficial) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOfficial
                        ? [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)]
                        : [const Color(0xFFF59E0B), const Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOfficial ? Icons.verified_rounded : Icons.groups_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOfficial ? 'POLLING RESMI' : 'POLLING KOMUNITAS',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            poll.title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              letterSpacing: -0.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            poll.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // Countdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PollCountdownTimer(
              endDate: poll.endDate,
              showIcon: true,
            ),
          ),
        ],
      ),
    );
  }

  /// Build poll info
  Widget _buildPollInfo(poll) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Polling',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Dibuat',
            value: DateFormat('dd MMM yyyy, HH:mm').format(poll.createdAt),
          ),
          _buildInfoRow(
            icon: Icons.person_rounded,
            label: 'Pembuat',
            value: poll.createdByName,
          ),
          if (poll.targetRT != null)
            _buildInfoRow(
              icon: Icons.location_on_rounded,
              label: 'Target',
              value: 'RT ${poll.targetRT}',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build vote info (if already voted)
  Widget _buildVoteInfo(DateTime votedAt) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anda Sudah Vote',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
                Text(
                  'Pada ${DateFormat('dd MMM yyyy, HH:mm').format(votedAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build voter list preview
  Widget _buildVoterListPreview(PollProvider pollProvider) {
    final votes = pollProvider.currentVotes;

    if (votes.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_rounded,
                size: 20,
                color: Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              Text(
                'Yang Sudah Vote',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Text(
                '${votes.length}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Show first 5 voters
          ...votes.take(5).map((vote) => _buildVoterItem(vote)),
          if (votes.length > 5)
            TextButton(
              onPressed: () {
                // TODO: Show all voters
              },
              child: Text(
                'Lihat semua (${votes.length})',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoterItem(vote) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: vote.userPhoto != null && vote.userPhoto!.isNotEmpty
                ? NetworkImage(vote.userPhoto!)
                : null,
            child: vote.userPhoto == null || vote.userPhoto!.isEmpty
                ? const Icon(Icons.person, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vote.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  vote.optionText,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Submit vote
  Future<void> _submitVote(BuildContext context) async {
    if (_selectedOptionId == null) return;

    final pollProvider = context.read<PollProvider>();
    final authProvider = context.read<AuthProvider>();
    final poll = pollProvider.currentPoll;

    if (poll == null || authProvider.userModel == null) return;

    // ⚠️ CRITICAL: Double-check user hasn't voted
    if (pollProvider.hasUserVoted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Anda sudah melakukan voting sebelumnya!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final selectedOption = pollProvider.currentOptions.firstWhere(
      (opt) => opt.optionId == _selectedOptionId,
    );

    final success = await pollProvider.submitVote(
      pollId: widget.pollId,
      optionId: _selectedOptionId!,
      userId: authProvider.userModel!.id,
      userName: authProvider.userModel!.nama,
      userPhoto: null, // UserModel doesn't have photo
      userRT: null, // Will get from keluarga
      userRW: null, // Will get from keluarga
      optionText: selectedOption.text,
      isAnonymous: poll.isAnonymous,
      metadata: {
        'hasKYC': authProvider.userModel!.status == 'approved',
      },
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vote berhasil dikirim!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else if (!success && mounted) {
      // Show error message
      final errorMsg = pollProvider.errorMessage ?? 'Gagal mengirim vote';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show more options menu
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.report_rounded),
                title: Text(
                  'Laporkan Polling',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Report functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

