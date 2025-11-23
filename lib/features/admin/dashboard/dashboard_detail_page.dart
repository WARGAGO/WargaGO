import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardDetailPage extends StatelessWidget {
  const DashboardDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F1F1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Dashboard Selengkapnya',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _SummaryCards(),
            SizedBox(height: 16),
            _StatusPendudukCard(),
            SizedBox(height: 16),
            _JenisKelaminCard(),
            SizedBox(height: 16),
            _ViewsByCountryCard(),
            SizedBox(height: 16),
            _PeranKeluargaCard(),
            SizedBox(height: 16),
            _AgamaCard(),
            SizedBox(height: 16),
            _PendidikanCard(),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _SummaryCard(
            icon: Icons.groups_outlined,
            title: 'Total Keluarga',
            value: '10',
            backgroundColor: Color(0xFFE3E9FF),
            iconColor: Color(0xFF2F80ED),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.diversity_3_outlined,
            title: 'Total Penduduk',
            value: '20',
            backgroundColor: Color(0xFFFFE8EC),
            iconColor: Color(0xFFEB5757),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPendudukCard extends StatelessWidget {
  const _StatusPendudukCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                'This year',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Penduduk',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              Text(
                '20%',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: _PieChartPainter(
                      segments: const [
                        PieSegment(percentage: 0.22, color: Color(0xFF1E3A8A), label: 'Nonaktif\n22%'),
                        PieSegment(percentage: 0.78, color: Color(0xFF2F80ED), label: 'Aktif\n78%'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JenisKelaminCard extends StatelessWidget {
  const _JenisKelaminCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                'This year',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jenis Kelamin',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              Text(
                '20%',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                size: const Size(220, 220),
                painter: _PieChartPainter(
                  segments: const [
                    PieSegment(percentage: 0.22, color: Color(0xFF1E3A8A), label: 'Wanita\n22%'),
                    PieSegment(percentage: 0.78, color: Color(0xFF2F80ED), label: 'Laki-laki\n78%'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewsByCountryCard extends StatelessWidget {
  const _ViewsByCountryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Row(
                children: [
                  Text(
                    '2021',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF9CA3AF)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Views by country',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  size: const Size(140, 140),
                  painter: _DonutChartPainter(
                    segments: const [
                      DonutSegment(percentage: 0.3911, color: Color(0xFF2F80ED)),
                      DonutSegment(percentage: 0.2802, color: Color(0xFF93C5FD)),
                      DonutSegment(percentage: 0.2313, color: Color(0xFF1E3A8A)),
                      DonutSegment(percentage: 0.0603, color: Color(0xFFE5E7EB)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: Color(0xFF1E3A8A),
                      label: 'petani',
                      percentage: '39.11%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: Color(0xFF2F80ED),
                      label: 'inatonal',
                      percentage: '28.02%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: Color(0xFF1E3A8A),
                      label: 'PNS',
                      percentage: '23.13%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: Color(0xFFE5E7EB),
                      label: 'Lain lain',
                      percentage: '6.03%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
  });

  final Color color;
  final String label;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        const Spacer(),
        Text(
          percentage,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
      ],
    );
  }
}

class _PeranKeluargaCard extends StatelessWidget {
  const _PeranKeluargaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Peran Keluarga',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(240, 240),
                    painter: _BubbleChartPainter(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BubbleLegend(color: Color(0xFF2F80ED), label: 'Kepala Keluarga'),
              const SizedBox(width: 16),
              _BubbleLegend(color: Color(0xFFD8B4FE), label: 'Anak'),
              const SizedBox(width: 16),
              _BubbleLegend(color: Color(0xFF1F1F1F), label: 'Lainnya'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BubbleLegend extends StatelessWidget {
  const _BubbleLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _AgamaCard extends StatelessWidget {
  const _AgamaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agama',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  size: const Size(160, 160),
                  painter: _ConcentricCirclesPainter(),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AgamaLegendItem(color: Color(0xFF2F80ED), label: 'Islam', percentage: '20%'),
                    const SizedBox(height: 12),
                    _AgamaLegendItem(color: Color(0xFF8B5CF6), label: 'Kristen', percentage: '50%'),
                    const SizedBox(height: 12),
                    _AgamaLegendItem(color: Color(0xFF1F1F1F), label: 'Lainnya', percentage: '10%'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgamaLegendItem extends StatelessWidget {
  const _AgamaLegendItem({
    required this.color,
    required this.label,
    required this.percentage,
  });

  final Color color;
  final String label;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        const Spacer(),
        Text(
          percentage,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
      ],
    );
  }
}

class _PendidikanCard extends StatelessWidget {
  const _PendidikanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pendidikan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: _GaugeChartPainter(progress: 0.65),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '100',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F1F1F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PendidikanLegend(color: Color(0xFF2F80ED), label: 'Sarjana/Diploma', percentage: '65%'),
              const SizedBox(width: 20),
              _PendidikanLegend(color: Color(0xFFE5E7EB), label: 'SMA/SMK', percentage: '35%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendidikanLegend extends StatelessWidget {
  const _PendidikanLegend({
    required this.color,
    required this.label,
    required this.percentage,
  });

  final Color color;
  final String label;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label $percentage',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

// Custom Painters

class PieSegment {
  final double percentage;
  final Color color;
  final String label;

  const PieSegment({
    required this.percentage,
    required this.color,
    required this.label,
  });
}

class _PieChartPainter extends CustomPainter {
  final List<PieSegment> segments;

  const _PieChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final sweepAngle = 2 * math.pi * segment.percentage;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw label
      final labelAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius * 0.65;
      final labelX = center.dx + labelRadius * math.cos(labelAngle);
      final labelY = center.dy + labelRadius * math.sin(labelAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: segment.label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DonutSegment {
  final double percentage;
  final Color color;

  const DonutSegment({
    required this.percentage,
    required this.color,
  });
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;

  const _DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;

    double startAngle = -math.pi / 2;

    for (final segment in segments) {
      final sweepAngle = 2 * math.pi * segment.percentage;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BubbleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Large blue circle (70%)
    final largePaint = Paint()
      ..color = const Color(0xFF2F80ED)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 20, center.dy + 10), 70, largePaint);

    final largeText = TextPainter(
      text: TextSpan(
        text: '70%',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    largeText.layout();
    largeText.paint(
      canvas,
      Offset(center.dx - 20 - largeText.width / 2, center.dy + 10 - largeText.height / 2),
    );

    // Medium purple circle (20%)
    final mediumPaint = Paint()
      ..color = const Color(0xFFD8B4FE)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx + 60, center.dy - 30), 50, mediumPaint);

    final mediumText = TextPainter(
      text: TextSpan(
        text: '20%',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    mediumText.layout();
    mediumText.paint(
      canvas,
      Offset(center.dx + 60 - mediumText.width / 2, center.dy - 30 - mediumText.height / 2),
    );

    // Small black circle (10%)
    final smallPaint = Paint()
      ..color = const Color(0xFF1F1F1F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx + 30, center.dy + 60), 35, smallPaint);

    final smallText = TextPainter(
      text: TextSpan(
        text: '10%',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    smallText.layout();
    smallText.paint(
      canvas,
      Offset(center.dx + 30 - smallText.width / 2, center.dy + 60 - smallText.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer light gray circle
    final outerPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawCircle(center, size.width / 2 - 10, outerPaint);

    // Middle purple arc
    final middlePaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2 - 30),
      -math.pi / 2,
      math.pi,
      false,
      middlePaint,
    );

    // Inner blue arc
    final innerPaint = Paint()
      ..color = const Color(0xFF2F80ED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2 - 50),
      -math.pi / 2,
      math.pi * 0.4,
      false,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GaugeChartPainter extends CustomPainter {
  final double progress;

  const _GaugeChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background arc
    final bgPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 14),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFF2F80ED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 14),
      -math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeChartPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
