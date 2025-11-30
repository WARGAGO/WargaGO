import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wargago/core/constants/app_routes.dart';

const _wordmarkText = 'WargaGO';
const _accentColor = Color(0xFF2F80ED);
const _accentColorDark = Color(0xFF1E5BB8);
const _accentColorLight = Color(0xFF5BA3FF);

const TextStyle _wordmarkStyle = TextStyle(
  fontSize: 42,
  letterSpacing: 2.0,
  fontFamily: 'Fendysa',
  fontWeight: FontWeight.w700,
  color: _accentColor,
  shadows: [
    Shadow(
      color: Color(0x402F80ED),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ],
);

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  // ENHANCED TIMELINE (ms)
  // 0–200   : gradient animation starts + particles spawn
  // 200–900 : big bounce logo with 3D rotation + glow pulse
  // 900–1000: hold 100ms
  // 1000–1500: radial ripple waves expand
  // 1500–1900: "WargaGO" text appears with shimmer effect
  // 1900–2300: logo and text align to row formation
  // 2300–2700: particles scatter + gradient intensifies
  // 2700–3000: fade out transition

  static const totalMs = 3000.0;
  static const _logoSize = 110.0;
  static const _spacing = 20.0;
  static const _entryOvershoot = 40.0;

  late final AnimationController c;
  late final AnimationController particleController;
  late final AnimationController glowController;
  late final AnimationController gradientController;

  // F1 - Enhanced logo animations
  late final Animation<double> logoScale;
  late final Animation<double> logoOpacity;
  late final Animation<double> logoRotation; // 3D-like rotation
  late final Animation<double> logoGlow;

  // F2 — Ripple waves effect
  late final Animation<double> rippleProgress;

  // F3 - text animations with shimmer
  late final Animation<double> textOpacity;
  late final Animation<double> textScale;
  late final Animation<double> textSlide;
  late final Animation<double> shimmerProgress;

  // F4 - pair alignment
  late final Animation<double> logoSlide;

  // F5 - particles animation
  late final List<_Particle> particles = [];

  // F6 - gradient animation
  late final Animation<double> gradientShift;

  // Layout metrics
  late final double _wordmarkWidth;
  late final double _wordmarkHeight;
  late final double _pairWidth;
  late final double _pairHeight;
  late final double _logoStartX;
  late final double _logoTop;
  late final double _textStartX;
  late final double _textEndX;
  late final double _textTop;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs.toInt()),
    );

    // Particle animation (continuous)
    particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // Glow pulse animation (continuous)
    glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Gradient animation (continuous)
    gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Initialize particles
    final random = math.Random();
    for (int i = 0; i < 25; i++) {
      particles.add(_Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 6 + 2,
        speed: random.nextDouble() * 0.5 + 0.3,
        opacity: random.nextDouble() * 0.6 + 0.2,
      ));
    }

    final textPainter = TextPainter(
      text: const TextSpan(text: _wordmarkText, style: _wordmarkStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    _wordmarkWidth = textPainter.width;
    _wordmarkHeight = textPainter.height;
    _pairWidth = _logoSize + _spacing + _wordmarkWidth;
    _pairHeight = math.max(_logoSize, _wordmarkHeight);
    _logoStartX = (_pairWidth - _logoSize) / 2;
    _logoTop = (_pairHeight - _logoSize) / 2;
    _textStartX = _pairWidth + _entryOvershoot;
    _textEndX = _logoSize + _spacing;
    _textTop = (_pairHeight - _wordmarkHeight) / 2;

    // ===== F1: Enhanced logo bounce with 3D rotation (200–900ms) =====
    final f1 = CurvedAnimation(
      parent: c,
      curve: const Interval(200 / totalMs, 900 / totalMs),
    );

    logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 0.85)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.00)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
    ]).animate(f1);

    logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: const Interval(200 / totalMs, 400 / totalMs, curve: Curves.easeOut),
      ),
    );

    logoRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -math.pi / 4, end: math.pi / 8)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: math.pi / 8, end: -math.pi / 12)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -math.pi / 12, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(f1);

    logoGlow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: const Interval(200 / totalMs, 900 / totalMs, curve: Curves.easeInOut),
      ),
    );

    // ===== F2: Ripple waves (1000–1500ms) =====
    rippleProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          1000 / totalMs,
          1500 / totalMs,
          curve: Curves.easeOut,
        ),
      ),
    );

    // ===== F3: Text with shimmer (1500-2300ms) =====
    textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          1500 / totalMs,
          1800 / totalMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    textScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          1500 / totalMs,
          1900 / totalMs,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    textSlide = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          1500 / totalMs,
          2300 / totalMs,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    shimmerProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          1500 / totalMs,
          2000 / totalMs,
          curve: Curves.linear,
        ),
      ),
    );

    // ===== F4: Logo slide to form row (1900–2300ms) =====
    logoSlide = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: c,
        curve: Interval(
          1900 / totalMs,
          2300 / totalMs,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );

    // ===== F6: Gradient animation =====
    gradientShift = Tween<double>(begin: 0, end: 1).animate(gradientController);

    c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        context.go(AppRoutes.onboarding);
      }
    });

    c.forward();
  }

  @override
  void dispose() {
    c.dispose();
    particleController.dispose();
    glowController.dispose();
    gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: Listenable.merge([c, particleController, glowController, gradientController]),
      builder: (_, __) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Animated gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(Colors.white, _accentColorLight.withValues(alpha: 0.1),
                          gradientShift.value * 0.3)!,
                      Colors.white,
                      Color.lerp(Colors.white, _accentColor.withValues(alpha: 0.08),
                          gradientShift.value * 0.4)!,
                    ],
                    stops: [
                      0.0,
                      0.5 + (gradientShift.value * 0.2),
                      1.0,
                    ],
                  ),
                ),
              ),

              // Floating particles in background
              CustomPaint(
                painter: _ParticlesPainter(
                  particles: particles,
                  progress: particleController.value,
                  color: _accentColor.withValues(alpha: 0.15),
                ),
              ),

              // Ripple waves effect from center
              if (rippleProgress.value > 0)
                CustomPaint(
                  painter: _RippleWavesPainter(
                    center: Offset(size.width / 2, size.height / 2),
                    progress: rippleProgress.value,
                    color: _accentColor,
                  ),
                ),

              // Content
              Center(
                child: SizedBox(
                  width: _pairWidth,
                  height: _pairHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Text with shimmer effect
                      Positioned(
                        left: ui.lerpDouble(
                          _textStartX,
                          _textEndX,
                          textSlide.value,
                        )!,
                        top: _textTop,
                        child: Opacity(
                          opacity: textOpacity.value,
                          child: Transform.scale(
                            scale: textScale.value,
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    _accentColor,
                                    _accentColorLight,
                                    _accentColor,
                                  ],
                                  stops: [
                                    shimmerProgress.value - 0.3,
                                    shimmerProgress.value,
                                    shimmerProgress.value + 0.3,
                                  ],
                                  tileMode: TileMode.clamp,
                                ).createShader(bounds);
                              },
                              child: const _JawaraWordmark(),
                            ),
                          ),
                        ),
                      ),

                      // Logo with glow and 3D rotation
                      Positioned(
                        left: ui.lerpDouble(_logoStartX, 0, logoSlide.value)!,
                        top: _logoTop,
                        child: FadeTransition(
                          opacity: logoOpacity,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // perspective
                              ..rotateY(logoRotation.value)
                              ..rotateZ(logoRotation.value * 0.3),
                            child: Transform.scale(
                              scale: logoScale.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer glow effect
                                  if (logoGlow.value > 0)
                                    Container(
                                      width: _logoSize + (glowController.value * 20),
                                      height: _logoSize + (glowController.value * 20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _accentColor.withValues(
                                                alpha: logoGlow.value * 0.4 * glowController.value),
                                            blurRadius: 30 + (glowController.value * 15),
                                            spreadRadius: 5 + (glowController.value * 5),
                                          ),
                                          BoxShadow(
                                            color: _accentColorLight.withValues(
                                                alpha: logoGlow.value * 0.3 * glowController.value),
                                            blurRadius: 50,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Inner glow
                                  Container(
                                    width: _logoSize,
                                    height: _logoSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Logo image
                                  Image.asset(
                                    'assets/icons/icon.png',
                                    width: _logoSize,
                                    height: _logoSize,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: _logoSize,
                                        height: _logoSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              _accentColorLight,
                                              _accentColor,
                                              _accentColorDark,
                                            ],
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.fingerprint,
                                          size: _logoSize * 0.6,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Foreground particles (on top)
              CustomPaint(
                painter: _ParticlesPainter(
                  particles: particles.sublist(0, 10),
                  progress: particleController.value,
                  color: _accentColorLight.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Particle data class
class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

/// Paints floating particles that move upward
class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  const _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (var particle in particles) {
      final x = particle.x * size.width;
      final yOffset = (progress * particle.speed) % 1.0;
      final y = (particle.y + yOffset) * size.height % size.height;

      final opacity = particle.opacity * (1 - (yOffset * 0.5));
      paint.color = color.withValues(alpha: color.a * opacity);

      // Draw particle with slight glow
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );

      // Add a subtle glow
      paint.color = color.withValues(alpha: color.a * opacity * 0.3);
      canvas.drawCircle(
        Offset(x, y),
        particle.size * 1.8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter old) =>
      old.progress != progress;
}

/// Paints ripple waves expanding from center
class _RippleWavesPainter extends CustomPainter {
  final Offset center;
  final double progress;
  final Color color;

  const _RippleWavesPainter({
    required this.center,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    ) / 2;

    // Draw multiple ripple waves
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress - (i * 0.15)).clamp(0.0, 1.0);
      if (waveProgress <= 0) continue;

      final radius = maxRadius * waveProgress * 1.2;
      final opacity = (1 - waveProgress) * 0.3;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 - (waveProgress * 2);

      canvas.drawCircle(center, radius, paint);

      // Add inner glow
      paint.strokeWidth = 1.5;
      paint.color = color.withValues(alpha: opacity * 0.5);
      canvas.drawCircle(center, radius - 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RippleWavesPainter old) =>
      old.progress != progress;
}

class _JawaraWordmark extends StatelessWidget {
  const _JawaraWordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(_wordmarkText, style: _wordmarkStyle);
  }
}

