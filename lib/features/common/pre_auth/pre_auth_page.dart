import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, SystemChrome;
import 'package:google_fonts/google_fonts.dart';
import 'package:jawara/core/constants/app_routes.dart';

const Color _kAccent = Color(0xFF2F80ED);

class PreAuthPage extends StatefulWidget {
  const PreAuthPage({super.key});

  @override
  State<PreAuthPage> createState() => _PreAuthPageState();
}

class _PreAuthPageState extends State<PreAuthPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  bool _isForward = true;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.white,
      ),
    );
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addStatusListener(_handleStatus);
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward(from: 0);
  }

  void _handleStatus(AnimationStatus status) {
    if (!mounted) return;
    if (status == AnimationStatus.completed) {
      _isForward = false;
      _controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _isForward = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            return Stack(
              children: [
                _BlobBackground(progress: _progress.value),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/icon.png',
                              height: 72,
                              width: 72,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.fingerprint,
                                size: 72,
                                color: _kAccent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Jawara',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: _kAccent,
                              ),
                            ),
                            const SizedBox(height: 36),
                            Text(
                              'Masuk ke Akun Jawara',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F1F1F),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'Kelola data dan layanan dengan mudah dari satu dashboard.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: const Color(0xFF8D8D8D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.adminLogin,
                              arguments: {
                                'initialProgress': _controller.value,
                                'isForward': _isForward,
                              },
                            );
                          },
                          child: const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _kAccent,
                            side: const BorderSide(color: _kAccent, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.wargaRegister,
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BlobBackground extends StatelessWidget {
  const _BlobBackground({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _BlobPainter(
            baseColor: _kAccent.withValues(alpha: 0.12),
            accentColor: _kAccent.withValues(alpha: 0.35),
            progress: progress,
          ),
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({
    required this.baseColor,
    required this.accentColor,
    required this.progress,
  });

  final Color baseColor;
  final Color accentColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = progress;
    final double wave1 = math.sin(t * 2 * math.pi);
    final double wave2 = math.cos((t + 0.25) * 2 * math.pi);
    final double wave3 = math.sin((t + 0.5) * 2 * math.pi);

    final circle1Center = Offset(
      -size.width * (0.33 + 0.02 * wave2) + wave1 * 32,
      size.height * (0.06 + 0.01 * wave3) + wave2 * 20,
    );
    final circle2Center = Offset(
      size.width * (0.95 + 0.02 * wave3) + wave2 * 42,
      size.height * (-0.2 + 0.015 * wave1) + wave1 * 24,
    );

    final paintBase = Paint()..color = baseColor;
    final paintAccent = Paint()..color = accentColor;

    final circle1Radius = size.width * 0.58 * (0.92 + wave1 * 0.08);
    final circle2Radius = size.width * 0.62 * (0.9 + wave2 * 0.07);

    canvas.drawCircle(circle1Center, circle1Radius, paintBase);
    canvas.drawCircle(circle2Center, circle2Radius, paintBase);

    final secondary1 = circle1Center.translate(
      140 + wave2 * 26,
      150 + wave1 * 22,
    );
    final secondary2 = circle2Center.translate(
      -60 + wave1 * 22,
      150 + wave3 * 18,
    );

    final double accentRadius1 = size.width * 0.32 * (0.9 + wave3 * 0.06);
    final double accentRadius2 = size.width * 0.28 * (0.9 + wave2 * 0.06);

    canvas.drawCircle(secondary2, accentRadius1, paintAccent);
    canvas.drawCircle(secondary1, accentRadius2, paintAccent);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor ||
          oldDelegate.accentColor != accentColor ||
          oldDelegate.progress != progress;
}