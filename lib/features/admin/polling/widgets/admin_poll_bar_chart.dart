// ============================================================================
// ADMIN POLL BAR CHART WIDGET
// ============================================================================
// Real-time bar chart untuk menampilkan hasil voting
// Menggunakan fl_chart package
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/poll_option_model.dart';

class AdminPollBarChart extends StatelessWidget {
  final List<PollOption> options;
  final int totalVotes;

  const AdminPollBarChart({
    super.key,
    required this.options,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Tidak ada data')),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final option = options[group.x.toInt()];
                return BarTooltipItem(
                  '${option.text}\n${option.voteCount} suara\n${option.percentage.toStringAsFixed(1)}%',
                  GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= options.length) return const SizedBox();

                  final option = options[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _shortenText(option.text, 10),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF6B7280),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getMaxY() / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200],
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey[300]!, width: 1),
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          barGroups: _buildBarGroups(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: option.voteCount.toDouble(),
            color: _getBarColor(index),
            width: 30,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Colors.grey[100],
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  double _getMaxY() {
    if (options.isEmpty) return 10;

    final maxVotes = options
        .map((o) => o.voteCount)
        .reduce((a, b) => a > b ? a : b);

    // Add 20% padding to max
    return (maxVotes * 1.2).ceilToDouble();
  }

  Color _getBarColor(int index) {
    final colors = [
      Colors.blue[600]!,
      Colors.green[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
      Colors.red[600]!,
      Colors.teal[600]!,
      Colors.pink[600]!,
      Colors.indigo[600]!,
    ];

    return colors[index % colors.length];
  }

  String _shortenText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

