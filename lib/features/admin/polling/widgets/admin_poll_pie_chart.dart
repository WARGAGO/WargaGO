// ============================================================================
// ADMIN POLL PIE CHART WIDGET - MODERN & ATTRACTIVE
// ============================================================================
// Beautiful donut chart dengan gradients dan animations
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/poll_option_model.dart';

class AdminPollPieChart extends StatefulWidget {
  final List<PollOption> options;
  final int totalVotes;

  const AdminPollPieChart({
    super.key,
    required this.options,
    required this.totalVotes,
  });

  @override
  State<AdminPollPieChart> createState() => _AdminPollPieChartState();
}

class _AdminPollPieChartState extends State<AdminPollPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: Text('Tidak ada data'),
        ),
      );
    }

    return Column(
      children: [
        // Pie Chart
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 60,
              sections: _buildSections(),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Legend dengan detail
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final isTouched = index == _touchedIndex;

      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 70.0 : 60.0;
      final color = _getColor(index);

      // Calculate percentage dynamically from actual data
      final percentage = widget.totalVotes > 0
          ? (option.voteCount / widget.totalVotes * 100)
          : 0.0;

      return PieChartSectionData(
        color: color,
        value: option.voteCount.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%', // Use calculated percentage
        radius: radius,
        titleStyle: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: [
            const Shadow(
              color: Colors.black26,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${option.voteCount}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: widget.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final color = _getColor(index);

        return InkWell(
          onTap: () {
            setState(() {
              _touchedIndex = index;
            });
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _touchedIndex = -1;
                });
              }
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Option text
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    option.text,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),

                // Vote count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${option.voteCount}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getColor(int index) {
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Pink
      const Color(0xFF6366F1), // Indigo
    ];

    return colors[index % colors.length];
  }
}

