import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, SystemChrome;
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:wargago/core/constants/app_routes.dart';

const Color _kAccent = Color(0xFF2F80ED);
const Color _kAccentLight = Color(0xFF5BA3FF);
const Color _kBackground = Color(0xFFFAFBFC);

class PreAuthPage extends StatefulWidget {
  const PreAuthPage({super.key});

  @override
  State<PreAuthPage> createState() => _PreAuthPageState();
}

class _PreAuthPageState extends State<PreAuthPage>
    with TickerProviderStateMixin {
  late final AnimationController _backgroundController;
  late final AnimationController _entranceController;
  late final Animation<double> _backgroundProgress;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    // Background animation (slow, continuous)
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addStatusListener(_handleBackgroundStatus);
    _backgroundProgress = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );
    _backgroundController.forward(from: 0);

    // Entrance animation (one-time)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    // Start entrance animation
    _entranceController.forward();
  }

  void _handleBackgroundStatus(AnimationStatus status) {
    if (!mounted) return;
    if (status == AnimationStatus.completed) {
      _isForward = false;
      _backgroundController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _isForward = true;
      _backgroundController.forward();
    }
  }

  @override
  void dispose() {
    _backgroundController.removeStatusListener(_handleBackgroundStatus);
    _backgroundController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_backgroundProgress, _fadeAnimation]),
          builder: (context, _) {
            return Stack(
              children: [
                // Modern Gradient Background
                _ModernGradientBackground(
                  progress: _backgroundProgress.value,
                ),

                // Minimal Floating Particles
                _MinimalParticles(
                  progress: _backgroundProgress.value,
                ),

                // Main Content with Fade & Slide Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          // Hero Logo Section
                          _buildHeroSection(),

                          const SizedBox(height: 60),

                          // Glassmorphism Content Card
                          _buildContentCard(context),

                          const Spacer(flex: 3),

                          // Modern Action Buttons
                          _buildActionButtons(context),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Logo with Subtle Glow
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.15),
                blurRadius: 32,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.08),
                blurRadius: 64,
                spreadRadius: 16,
              ),
            ],
          ),
          child: Image.asset(
            'assets/icons/icon.png',
            height: 64,
            width: 64,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.fingerprint,
              size: 64,
              color: _kAccent,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // App Name with Gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [_kAccent, _kAccentLight],
          ).createShader(bounds),
          child: Text(
            'WargaGO',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Column(
            children: [
              // Title
              Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Kelola data dan layanan warga\ndengan mudah dan efisien',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  height: 1.6,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 24),

              // Features Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureItem(
                    Icons.security_rounded,
                    'Aman',
                  ),
                  _buildFeatureItem(
                    Icons.flash_on_rounded,
                    'Cepat',
                  ),
                  _buildFeatureItem(
                    Icons.workspace_premium_rounded,
                    'Terpercaya',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 28,
            color: _kAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Login Button (Primary)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: _kAccent.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            onPressed: () {
              context.push(
                AppRoutes.login,
                extra: {
                  'initialProgress': _backgroundController.value,
                  'isForward': _isForward,
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Masuk ke Akun'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Sign Up Button (Secondary)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: _kAccent,
              side: BorderSide(
                color: _kAccent.withValues(alpha: 0.4),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            onPressed: () {
              context.push(AppRoutes.wargaRegister);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_rounded, size: 20),
                const SizedBox(width: 8),
                const Text('Daftar Sekarang'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Modern Gradient Background with Smooth Animation
class _ModernGradientBackground extends StatelessWidget {
  const _ModernGradientBackground({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GradientBackgroundPainter(
          progress: progress,
          color: _kAccent,
        ),
      ),
    );
  }
}

class _GradientBackgroundPainter extends CustomPainter {
  _GradientBackgroundPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = progress;

    // Smooth wave calculations
    final double wave1 = math.sin(t * 2 * math.pi);
    final double wave2 = math.cos(t * 2 * math.pi);

    // Animated center position
    final center1 = Offset(
      size.width * (0.3 + 0.15 * wave1),
      size.height * (0.2 + 0.1 * wave2),
    );

    final center2 = Offset(
      size.width * (0.7 + 0.12 * wave2),
      size.height * (0.8 + 0.08 * wave1),
    );

    // Gradient 1 (top)
    final gradient1 = RadialGradient(
      center: Alignment(
        (center1.dx - size.width / 2) / (size.width / 2),
        (center1.dy - size.height / 2) / (size.height / 2),
      ),
      radius: 0.8,
      colors: [
        color.withValues(alpha: 0.15),
        color.withValues(alpha: 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    // Gradient 2 (bottom)
    final gradient2 = RadialGradient(
      center: Alignment(
        (center2.dx - size.width / 2) / (size.width / 2),
        (center2.dy - size.height / 2) / (size.height / 2),
      ),
      radius: 0.9,
      colors: [
        _kAccentLight.withValues(alpha: 0.12),
        _kAccentLight.withValues(alpha: 0.04),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final paint1 = Paint()..shader = gradient1.createShader(Offset.zero & size);
    final paint2 = Paint()..shader = gradient2.createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint1);
    canvas.drawRect(Offset.zero & size, paint2);
  }

  @override
  bool shouldRepaint(covariant _GradientBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// Minimal Floating Particles
class _MinimalParticles extends StatelessWidget {
  const _MinimalParticles({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _ParticlesPainter(
          progress: progress,
          color: _kAccent,
        ),
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    // Only 15 particles for minimal, elegant look
    for (int i = 0; i < 15; i++) {
      final seed = i * 0.1;
      final x = size.width * random.nextDouble();
      final baseY = size.height * random.nextDouble();

      // Slow vertical float
      final floatOffset = math.sin((progress + seed) * 2 * math.pi) * 30;
      final y = baseY + floatOffset;

      // Small particle size
      final radius = 1.5 + random.nextDouble() * 3.0;

      // Subtle fade based on position
      final opacity = 0.1 + (math.sin((progress + seed) * math.pi) * 0.15).abs();

      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
