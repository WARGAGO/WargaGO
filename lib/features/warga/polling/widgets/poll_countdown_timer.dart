// ============================================================================
// POLL COUNTDOWN TIMER WIDGET
// ============================================================================
// Real-time countdown timer untuk polling
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PollCountdownTimer extends StatefulWidget {
  final DateTime endDate;
  final TextStyle? textStyle;
  final Color? iconColor;
  final bool showIcon;

  const PollCountdownTimer({
    super.key,
    required this.endDate,
    this.textStyle,
    this.iconColor,
    this.showIcon = true,
  });

  @override
  State<PollCountdownTimer> createState() => _PollCountdownTimerState();
}

class _PollCountdownTimerState extends State<PollCountdownTimer> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    if (!mounted) return;

    final remaining = widget.endDate.difference(DateTime.now());

    if (remaining.isNegative) {
      _timer?.cancel();
      if (mounted) {
        setState(() {
          _timeRemaining = Duration.zero;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _timeRemaining = remaining;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeRemaining == Duration.zero) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIcon) ...[
            Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: widget.iconColor ?? const Color(0xFF10B981),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            'Polling Ditutup',
            style: widget.textStyle ??
                GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
          ),
        ],
      );
    }

    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    // Determine color based on urgency
    Color urgencyColor;
    if (days == 0 && hours < 1) {
      urgencyColor = const Color(0xFFEF4444); // Red - very urgent
    } else if (days == 0 && hours < 24) {
      urgencyColor = const Color(0xFFF59E0B); // Orange - urgent
    } else {
      urgencyColor = const Color(0xFF3B82F6); // Blue - normal
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIcon) ...[
          Icon(
            Icons.access_time_rounded,
            size: 16,
            color: widget.iconColor ?? urgencyColor,
          ),
          const SizedBox(width: 6),
        ],
        if (days > 0)
          _buildTimeUnit('${days}h', urgencyColor)
        else if (hours > 0)
          _buildTimeUnit('${hours}j ${minutes}m', urgencyColor)
        else if (minutes > 0)
          _buildTimeUnit('${minutes}m ${seconds}d', urgencyColor)
        else
          _buildTimeUnit('${seconds}d', urgencyColor),
        Text(
          ' lagi',
          style: widget.textStyle ??
              GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: urgencyColor,
              ),
        ),
      ],
    );
  }

  Widget _buildTimeUnit(String time, Color color) {
    return Text(
      time,
      style: widget.textStyle ??
          GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
    );
  }
}

