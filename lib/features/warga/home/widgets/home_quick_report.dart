// ============================================================================
// HOME QUICK REPORT WIDGET
// ============================================================================
// Quick report untuk lapor masalah RT (sampah, lampu, jalan rusak, dll)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeQuickReport extends StatelessWidget {
  const HomeQuickReport({super.key});

  @override
  Widget build(BuildContext context) {
    final reportTypes = [
      ReportType(
        icon: Icons.delete_rounded,
        label: 'Sampah',
        color: const Color(0xFF2F80ED),
      ),
      ReportType(
        icon: Icons.lightbulb_rounded,
        label: 'Lampu',
        color: const Color(0xFF3B8FF3),
      ),
      ReportType(
        icon: Icons.construction_rounded,
        label: 'Jalan',
        color: const Color(0xFF4B9EFF),
      ),
      ReportType(
        icon: Icons.more_horiz_rounded,
        label: 'Lainnya',
        color: const Color(0xFF6B7280),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.report_problem_rounded,
                  color: Color(0xFF2F80ED),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Lapor Masalah',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: reportTypes.map((type) {
              return _buildReportButton(type, context);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(ReportType type, BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lapor ${type.label} - Fitur dalam pengembangan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: type.color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: type.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              type.icon,
              color: type.color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            type.label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportType {
  final IconData icon;
  final String label;
  final Color color;

  ReportType({
    required this.icon,
    required this.label,
    required this.color,
  });
}

