// ============================================================================
// POLL ANALYTICS CHART WIDGET
// ============================================================================
// Chart untuk menampilkan analytics polling
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/models/poll_result_model.dart';

class PollAnalyticsChart extends StatelessWidget {
  final PollResult result;
  final String chartType; // 'bar' | 'pie' | 'demographics'

  const PollAnalyticsChart({
    super.key,
    required this.result,
    this.chartType = 'bar',
  });

  @override
  Widget build(BuildContext context) {
    switch (chartType) {
      case 'bar':
        return _buildBarChart();
      case 'pie':
        return _buildPieChart();
      case 'demographics':
        return _buildDemographicsChart();
      default:
        return _buildBarChart();
    }
  }

  /// Build bar chart
  Widget _buildBarChart() {
    if (result.options.isEmpty) {
      return _buildEmptyState();
    }

    final sortedOptions = result.options.toList()
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChartHeader('Hasil Voting'),
        const SizedBox(height: 16),
        ...sortedOptions.map((option) => _buildBarChartItem(option)),
      ],
    );
  }

  Widget _buildBarChartItem(OptionResult option) {
    final isWinner = option == result.winner;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  option.text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  if (isWinner)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
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
                  Text(
                    '${option.percentage.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isWinner
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: option.percentage / 100,
                    minHeight: 24,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isWinner
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${option.voteCount}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build pie chart (simplified circular representation)
  Widget _buildPieChart() {
    if (result.options.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildChartHeader('Distribusi Suara'),
        const SizedBox(height: 24),

        // Circular representation
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _PieChartPainter(result.options),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${result.totalVotes}',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    'Total Suara',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: result.options.map((option) {
            return _buildLegendItem(option);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(OptionResult option) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
    ];
    final index = result.options.indexOf(option);
    final color = colors[index % colors.length];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${option.text} (${option.percentage.toStringAsFixed(1)}%)',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  /// Build demographics chart
  Widget _buildDemographicsChart() {
    if (result.demographics == null) {
      return _buildEmptyState(message: 'Data demografis tidak tersedia');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChartHeader('Demografis Voters'),
        const SizedBox(height: 16),

        // By RT
        if (result.demographics!.byRT.isNotEmpty) ...[
          Text(
            'Per RT',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          ...result.demographics!.byRT.entries.map((entry) {
            return _buildDemographicItem(
              label: 'RT ${entry.key}',
              value: entry.value,
              total: result.totalVotes,
              color: const Color(0xFF3B82F6),
            );
          }),
          const SizedBox(height: 16),
        ],

        // By Gender
        if (result.demographics!.byGender.isNotEmpty) ...[
          Text(
            'Per Jenis Kelamin',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          ...result.demographics!.byGender.entries.map((entry) {
            return _buildDemographicItem(
              label: entry.key == 'L' ? 'Laki-laki' : 'Perempuan',
              value: entry.value,
              total: result.totalVotes,
              color: entry.key == 'L'
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFEC4899),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildDemographicItem({
    required String label,
    required int value,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 16,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              '$value (${percentage.toStringAsFixed(1)}%)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Belum ada data',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter untuk pie chart
class _PieChartPainter extends CustomPainter {
  final List<OptionResult> options;

  _PieChartPainter(this.options);

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
    ];

    double startAngle = -90 * 3.14159 / 180; // Start from top

    for (var i = 0; i < options.length; i++) {
      final option = options[i];
      final sweepAngle = (option.percentage / 100) * 2 * 3.14159;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw white circle in center
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

