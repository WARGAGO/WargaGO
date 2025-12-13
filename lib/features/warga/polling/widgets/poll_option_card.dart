// ============================================================================
// POLL OPTION CARD WIDGET
// ============================================================================
// Card untuk menampilkan opsi polling dengan bar chart real-time
// Support untuk voting mode dan result mode
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/models/poll_option_model.dart';

class PollOptionCard extends StatefulWidget {
  final PollOption option;
  final bool isVotingMode; // true = voting, false = showing results
  final bool isSelected;
  final bool hasVoted;
  final int totalVotes;
  final VoidCallback? onTap;
  final bool showAnimation;

  const PollOptionCard({
    super.key,
    required this.option,
    this.isVotingMode = true,
    this.isSelected = false,
    this.hasVoted = false,
    this.totalVotes = 0,
    this.onTap,
    this.showAnimation = true,
  });

  @override
  State<PollOptionCard> createState() => _PollOptionCardState();
}

class _PollOptionCardState extends State<PollOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Initialize animation with starting value
    final targetPercentage = widget.option.percentage / 100;
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: targetPercentage.clamp(0.0, 1.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _previousValue = targetPercentage;

    // Start animation if enabled
    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PollOptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.option.percentage != widget.option.percentage) {
      // Schedule animation for next frame to avoid layout conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateAnimation();
        }
      });
    }
  }

  void _updateAnimation() {
    if (!mounted) return;

    final targetPercentage = widget.option.percentage / 100;
    _progressAnimation = Tween<double>(
      begin: _previousValue,
      end: targetPercentage.clamp(0.0, 1.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _previousValue = targetPercentage;

    if (widget.showAnimation && mounted) {
      _animationController.forward(from: 0);
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWinning = widget.option.voteCount > 0 &&
        widget.totalVotes > 0 &&
        widget.option.percentage >= 50;

    return GestureDetector(
      onTap: widget.isVotingMode && !widget.hasVoted ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF3B82F6)
                : widget.isVotingMode
                    ? Colors.grey.shade300
                    : Colors.transparent,
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: widget.isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Progress Bar (untuk result mode)
              if (!widget.isVotingMode)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                (isWinning
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF3B82F6))
                                    .withValues(alpha: 0.15),
                                (isWinning
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF3B82F6))
                                    .withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                  // Radio/Checkbox (voting mode only)
                  if (widget.isVotingMode) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.isSelected
                              ? const Color(0xFF3B82F6)
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: widget.isSelected
                            ? const Color(0xFF3B82F6)
                            : Colors.transparent,
                      ),
                      child: widget.isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Image (if exists)
                  if (widget.option.hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.option.imageUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.option.text,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Winning Badge
                            if (!widget.isVotingMode && isWinning) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Unggul',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.option.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.option.description!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Vote Count & Percentage (result mode)
                  if (!widget.isVotingMode) ...[
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Text(
                              '${(_progressAnimation.value * 100).toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isWinning
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF3B82F6),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.option.voteCount} suara',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

